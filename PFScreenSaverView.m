
#import "PFScreenSaverView.h"
#import "PFFlickrProvider.h"
#import "PFQueue.h"
#import "PFConfigureSheetController.h"


@implementation PFScreenSaverView

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview {
    if(self = ([super initWithFrame:frame isPreview:isPreview])) {
		NSLog(@"[PhotoFeederView initWithFrame...]");

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



#pragma mark -- Rendering & Animation

- (void)animateOneFrame
{
	[self setNeedsDisplay:YES];
}



- (void)drawRect:(NSRect)rectangle
{
	// Draw Not Loading while we are waiting for an image
	if(!PFImageIsValid(frontImage)) {
		NSSize statusTextSize = [[statusText attrString] size];
		[[NSColor blackColor] set];
		[NSBezierPath fillRect:[self frame]];
		[statusText drawAt:NSMakePoint((screenSize.width/2)-(statusTextSize.width/2), 
									   (screenSize.height/2)-(statusTextSize.height/2))];
		return;
	}
	
	// Draw the motherfucker
	[[renderer openGLContext] makeCurrentContext];
	
	if (ciContext == nil) {
		ciContext = [[CIContext contextWithCGLContext: CGLGetCurrentContext() 
													 pixelFormat: [[renderer pixelFormat] CGLPixelFormatObj] 
														  options: nil] retain];
	}
	
	// Fill the view black between each rendered frame (overwriting the old image)
	glColor4f( 0.0f, 0.0f, 0.0f, 0.0f );
	glBegin( GL_POLYGON );
	glVertex2f( rectangle.origin.x, rectangle.origin.y );
	glVertex2f( rectangle.origin.x + rectangle.size.width, rectangle.origin.y );
	glVertex2f( rectangle.origin.x + rectangle.size.width, rectangle.origin.y + rectangle.size.height );
	glVertex2f( rectangle.origin.x, rectangle.origin.y + rectangle.size.height );
	glEnd();
	
	NSRect r = [self bounds];
	CGRect* myFrame = (CGRect*)&r;
	
	[ciContext drawImage: [frontImage.im imageByApplyingTransform: CGAffineTransformMakeTranslation(-frontImage.position.x, -frontImage.position.y)]
					 atPoint: CGPointZero
					fromRect: *myFrame];
	
	if(frontImage.movingType == PFMovingTypeHorizontally)
		frontImage.position.x += frontImage.stepSize;
	else if(frontImage.movingType == PFMovingTypeVertically)
		frontImage.position.y += frontImage.stepSize;

	if(!frontImage.stepsLeft--) {
		[imageCreatorLock lock];
		[imageCreatorLock unlockWithCondition: CL_RUN];
	}

	glFlush();
	
	// TODO: Additional "I'm loading image from service" if image isn't in cache
}




#pragma mark -- Threads

- (void)queueFillerThread:(id)obj
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	PFProvider* provider;
	while(1) {
		provider = (PFProvider*)[providers objectAtIndex:SSRandomIntBetween(0, [providers count]-1)];
		[queue put:[provider getURL]];
		/*provider = (PFProvider*)[providers objectAtIndex:0];
		[queue put:[provider getURL]];
		provider = (PFProvider*)[providers objectAtIndex:1];
		[queue put:[provider getURL]];*/
	}
	[pool release];
}


- (PFImage)createResizedImageFromCIImage:(CIImage *)im
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
		NSLog(@"Image is in landscape format");
		resizeRate = screenSize.height / imageSize.height;

		pixelsScreenCantShow = (imageSize.width * resizeRate) - screenSize.width;
		movingType = (pixelsScreenCantShow != 0) ? PFMovingTypeHorizontally : PFMovingTypeNone;
	}
	
	else if(imageAspectRatio <= screenAspectRatio)
	{
		NSLog(@"Image is in portrait format");
		
		resizeRate = screenSize.width / imageSize.width;

		pixelsScreenCantShow = (imageSize.height * resizeRate) - screenSize.height;
		movingType = (pixelsScreenCantShow != 0) ? PFMovingTypeVertically : PFMovingTypeNone;
	}
	
	NSLog(@"Doing resize a la: %f", resizeRate);
	PFImage i = PFImageCreate([im imageByApplyingTransform: CGAffineTransformMakeScale(resizeRate, resizeRate)],
							  movingType,
							  pixelsScreenCantShow,
							  5.0,
							  1.0 / [self animationTimeInterval]
							  );
	
	NSLog(@"Resized to: %f x %f", i.size.width, i.size.height);
	return i;
}


- (void)imageCreatorThread:(id)obj
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	while(1)
	{
		[imageCreatorLock lockWhenCondition:CL_RUN];
		NSLog(@"[PhotoFeederView imageCreatorThread] Taking url from queue and fetching image data...");
		
		// Swap images - bring back to front
		PFImage oldFrontImage = frontImage;
		frontImage = backImage;
		
		// Create new back image
		NSURL* url = (NSURL*)[queue take];
		NSLog(@"[PhotoFeederView imageCreatorThread] got URL: %@", url);
		backImage = [self createResizedImageFromCIImage: [CIImage imageWithContentsOfURL:url]];
		
		// Throw away old front image
		PFImageRelease(oldFrontImage);
		
		if(PFImageIsValid(frontImage))
			[imageCreatorLock unlockWithCondition:CL_WAIT];
		else
			[imageCreatorLock unlock];
	}
		
	[pool release];
}

#pragma mark -- Etc...

- (BOOL)hasConfigureSheet {
    return YES;
}

- (NSWindow*)configureSheet
{
	NSLog(@"[%@ configureSheet]", self);
    if(configureSheetController == nil)
		configureSheetController = [[PFConfigureSheetController alloc] initWithWindowNibName: @"ConfigureSheet" 
																		  withReferenceToSSV: self];
	
	NSWindow* win = [configureSheetController window];
	if(win == nil)
		NSLog(@"[%@ configureSheet]: win == nil", self);
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