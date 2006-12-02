
#import "PFScreenSaverView.h"
#import "PFFlickrProvider.h"
#import "PFQueue.h"
#import "PFConfigureSheetController.h"


@implementation PFScreenSaverView

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview {
    if(self = ([super initWithFrame:frame isPreview:isPreview])) {
		DLog(@"[PhotoFeederView initWithFrame...]");
		
		// Create the mother-queue
		queue = [[PFQueue alloc] initWithCapacity:20];
		
		// Setup providers
		providers = [[NSMutableArray alloc] initWithCapacity:2];
		[providers addObject:[[PFFlickrProvider alloc] init]];
		//[providers addObject:[[PFFlickrProvider alloc] init]];
		
		// Start filling the queue with images from providers
		[NSThread detachNewThreadSelector: @selector(queueFillerThread:)
								 toTarget: self
							   withObject: nil];
		
		// Start creating next and current image from queue URLs
		imageCreatorLock = [[NSConditionLock alloc] initWithCondition:CL_RUN];
		[NSThread detachNewThreadSelector: @selector(imageCreatorThread:)
								 toTarget: self
							   withObject: nil];
		
		// Create message text
		statusText = [[PFText alloc] initWithText: @"Loading..."];
		
		// Setup renderer
		renderer = [PFGLRenderer newRenderer];
		if (!renderer) {
			NSLog( @"Couldn't initialize OpenGL view." );
			[self autorelease];
			return nil;
		}
		[self addSubview: renderer]; 
		[renderer prepare];
		
		// Get the screen size to be able to scale images properly
		screenSize = [self bounds].size;
		
		// Create a transition filter
		transition = [[CIFilter filterWithName: @"CIDissolveTransition"] retain];
		[transition setDefaults];
		
		// Set frame rate
		float fps = [[NSUserDefaults standardUserDefaults] floatForKey:@"rendererFPS"];
		if(fps == 0)
			fps = 60.0;
        [self setAnimationTimeInterval: 1/fps];
    }
    return self;
}


- (void)dealloc
{
	[renderer removeFromSuperview];
	[renderer release];
	[providers release];
	[imageCreatorLock release];
	[statusText release];
	[super dealloc];
}



#pragma mark -- Animation & Rendering

- (void)animateOneFrame
{
	if( frontImage )
	{
		/*// Update transition if needed
		float fadeThreshold = .65; // TODO: Bind to user defaults
		float percentPosition = 1-((float)frontImage.stepsLeft/(float)frontImage.stepCount);
		
		if( percentPosition > fadeThreshold )
		{
			[transition setValue: [NSNumber numberWithFloat: SMOOTHSTEP((percentPosition-fadeThreshold)/(1-fadeThreshold))]
						  forKey: @"inputTime"];
			// Update back image position
			PFImageMoveOneStep(&backImage);
		}
		
		// Update front image position
		PFImageMoveOneStep(&frontImage);*/
	}
	
	[self setNeedsDisplay:YES];
}


- (void)drawRect:(NSRect)rect
{
	// Activate OpenGL context
	[[renderer openGLContext] makeCurrentContext];
	
	if( !frontImage ) {
		frontImage = [PFImage imageWithContentsOfURL:[NSURL URLWithString:@"file://localhost/Users/rasmus/Desktop/bild_1000.jpg"]];
		DLog(@"frontImage: w: %d", [frontImage bounds].width );
	}
	
	
	
	glBindTexture(GL_TEXTURE_RECTANGLE_EXT, [frontImage texture]);
	
	glTexSubImage2D(GL_TEXTURE_RECTANGLE_EXT, 0, 0, 0, 1000, 1000, GL_BGRA, GL_BGRA, [frontImage data]);
	glBegin(GL_QUADS);
	glTexCoord2f(0.0f, 0.0f);
	glVertex2f(-1.0f, 1.0f);
	
	glTexCoord2f(0.0f, 1000.0f);
	glVertex2f(-1.0f, -1.0f);
	
	glTexCoord2f(1000.0f, 1000.0f);
	glVertex2f(1.0f, -1.0f);
	
	glTexCoord2f(1000.0f, 0.0f);
	glVertex2f(1.0f, 1.0f);
	glEnd();
	
	glFlush();
	
	
	/*glClear(GL_COLOR_BUFFER_BIT);
	
	if( !frontImage ) {
		frontImage = [PFImage imageWithContentsOfURL:[NSURL URLWithString:@"file://localhost/Users/rasmus/Desktop/bild_1000.jpg"]];
		DLog(@"frontImage: w: %d", [frontImage bounds].width );
	}
	
	glBindTexture(GL_TEXTURE_RECTANGLE_EXT, [frontImage texture]);
	//glLoadIdentity();
	
	glBegin( GL_QUADS );
	glTexCoord2d(0.0,1.0); glVertex2d(0.0,0.0);
	glTexCoord2d(1.0,1.0); glVertex2d(1000.0,0.0);
	glTexCoord2d(1.0,0.0); glVertex2d(1000.0,1000.0);
	glTexCoord2d(0.0,0.0); glVertex2d(0.0,1000.0);
	glEnd();*/
	
	
	/*
	glColor3f(1.0,0,0);
	glBegin( GL_QUADS );
	glVertex2d(0.0,0.0);
	glVertex2d(100.0,0.0);
	glVertex2d(100.0,100.0);
	glVertex2d(0.0,100.0);
	glEnd();*/
}


/*- (void)drawRect:(NSRect)rect
{
	// Draw Not Loading while we are waiting for an image
	if( !frontImage )
	{
		NSSize statusTextSize = [[statusText attrString] size];
		[[NSColor blackColor] set];
		[NSBezierPath fillRect:[self frame]];
		[statusText drawAt:NSMakePoint((screenSize.width/2)-(statusTextSize.width/2), 
									   (screenSize.height/2)-(statusTextSize.height/2))];
		return;
	}
	
	// TODO: It's unnecessary to call this each frame, call only when switching images...
	[transition setValue: [frontImage.im imageByApplyingTransform: CGAffineTransformMakeTranslation(-frontImage.position.x, -frontImage.position.y)]
				  forKey: @"inputImage"];
	[transition setValue: [backImage.im imageByApplyingTransform: CGAffineTransformMakeTranslation(-backImage.position.x, -backImage.position.y)]
				  forKey: @"inputTargetImage"];
	
	// Activate OpenGL context
	[[renderer openGLContext] makeCurrentContext]; // <- This seems to be redundant, but we keep it here for now.
	if (ciContext == nil) {
		ciContext = [[CIContext contextWithCGLContext: CGLGetCurrentContext() 
													 pixelFormat: [[renderer pixelFormat] CGLPixelFormatObj] 
														  options: nil] retain];
	}
	
	// Fill the view black between each rendered frame (overwriting the old image)
	IFDEBUG(
		glColor4f( 0.0f, 0.0f, 0.0f, 0.0f );
		glBegin( GL_POLYGON );
		glVertex2f( rect.origin.x, rect.origin.y );
		glVertex2f( rect.origin.x + rect.size.width, rect.origin.y );
		glVertex2f( rect.origin.x + rect.size.width, rect.origin.y + rect.size.height );
		glVertex2f( rect.origin.x, rect.origin.y + rect.size.height );
		glEnd();
	);
	
	// Perform drawing
	CGRect myFrame = *(CGRect*)&rect; // <- We love this typecast-kinda thing!
	//NSLog(@"myFrame: %f, %f, %f, %f", myFrame.origin.x, myFrame.origin.y, myFrame.size.width, myFrame.size.height);
	[ciContext drawImage: [transition valueForKey: @"outputImage"]
					 atPoint: CGPointZero
					fromRect: myFrame];
	
	// We are done with front image and need a new back image
	if(!frontImage.stepsLeft) {
		[transition setValue: [NSNumber numberWithFloat: .0 ]
					  forKey: @"inputTime"];
		[imageCreatorLock lock];
		[imageCreatorLock unlockWithCondition: CL_RUN];
	}
	
	glFlush();
}*/


#pragma mark -- Threads

- (void)queueFillerThread:(id)obj
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	PFProvider* provider;
	while(1) {
		provider = (PFProvider*)[providers objectAtIndex:SSRandomIntBetween(0, [providers count]-1)];
		[queue put:[provider nextImage]];
		/*provider = (PFProvider*)[providers objectAtIndex:0];
		[queue put:[provider nextImage]];
		provider = (PFProvider*)[providers objectAtIndex:1];
		[queue put:[provider nextImage]];*/
	}
	[pool release];
}


/*- (PFImage*)createResizedImageFromCIImage:(CIImage *)im
{	
	float screenAspectRatio = screenSize.width / screenSize.height;
	CGSize imageSize = [im extent].size;
	float imageAspectRatio = imageSize.width / imageSize.height;
	float resizeRate = 0;

	PFMovingType movingType = PFMovingTypeNone;
	float pixelsScreenCantShow = 0;
	
	// Rescale image so that it fits for sliding horizontally or vertically
	if(imageAspectRatio > screenAspectRatio)
	{
		DLog(@"Image is in landscape format");
		resizeRate = screenSize.height / imageSize.height;

		pixelsScreenCantShow = (imageSize.width * resizeRate) - screenSize.width;
		movingType = (pixelsScreenCantShow != 0) ? PFMovingTypeHorizontally : PFMovingTypeNone;
	}
	
	else if(imageAspectRatio <= screenAspectRatio)
	{
		DLog(@"Image is in portrait format");
		
		resizeRate = screenSize.width / imageSize.width;

		pixelsScreenCantShow = (imageSize.height * resizeRate) - screenSize.height;
		movingType = (pixelsScreenCantShow != 0) ? PFMovingTypeVertically : PFMovingTypeNone;
	}
	
	DLog(@"Doing resize a la: %f", resizeRate);
	PFImage i = PFImageCreate([im imageByApplyingTransform: CGAffineTransformMakeScale(resizeRate, resizeRate)],
							  movingType,
							  pixelsScreenCantShow,
							  10.0, // Seconds to show image
							  1.0 / [self animationTimeInterval]
							  );
	// We don't need the original image anymore (we have a resized copy)
	[im release];
	
	DLog(@"Resized to: %f x %f", i.size.width, i.size.height);
	return i;
}*/


- (void)imageCreatorThread:(id)obj
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	while(1)
	{
		[imageCreatorLock lockWhenCondition:CL_RUN];
		/*DLog(@"[PhotoFeederView imageCreatorThread] Taking CIImage from queue and converting to PFImage...");
		
		// Swap images - bring back to front
		PFImage oldFrontImage = frontImage;
		frontImage = backImage;
		
		// Create new back image
		backImage = [self createResizedImageFromCIImage: (CIImage*)[queue take]];
		
		// Throw away old front image
		PFImageRelease(oldFrontImage);
		
		if(PFImageIsValid(frontImage))
			[imageCreatorLock unlockWithCondition:CL_WAIT];
		else
			[imageCreatorLock unlock];*/
	}
		
	[pool release];
}

#pragma mark -- Etc...

- (BOOL)hasConfigureSheet {
    return YES;
}

- (NSWindow*)configureSheet
{
	DLog(@"[%@ configureSheet]", self);
    if(configureSheetController == nil)
		configureSheetController = [[PFConfigureSheetController alloc] initWithWindowNibName: @"ConfigureSheet" 
																		  withReferenceToSSV: self];
	
	NSWindow* win = [configureSheetController window];
	if(win == nil)
		DLog(@"[%@ configureSheet]: win == nil", self);
	return win;
}

- (BOOL) isOpaque {
    return YES;
}

- (void)setFrameSize:(NSSize)newSize {
	[renderer setFrameSize: newSize];
}

- (void)startAnimation {
	[super startAnimation];
}

- (void)stopAnimation {
	[super stopAnimation];
}

@end