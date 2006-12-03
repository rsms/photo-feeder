
#import "PFScreenSaverView.h"
#import "PFFlickrProvider.h"
#import "PFDiskProvider.h"
#import "PFQueue.h"
#import "PFConfigureSheetController.h"


@implementation PFScreenSaverView

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    if(self = ([super initWithFrame:frame isPreview:isPreview]))
	{
		DLog(@"[PhotoFeederView initWithFrame...]");
		
		// Create the mother-queue
		queue = [[PFQueue alloc] initWithCapacity:20];
		
		// Setup providers
		providers = [[NSMutableArray alloc] initWithCapacity:2];
		//[providers addObject:[[PFFlickrProvider alloc] init]];
		[providers addObject:[[PFDiskProvider alloc] initWithPathToDirectory:[NSHomeDirectory() stringByAppendingPathComponent:@"Pictures"]]];
		
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
		renderer = [[[PFGLRenderer alloc] initWithDefaultPixelFormat] retain];
		if (!renderer) {
			NSLog(@"Failed to initialize renderer" );
			[self autorelease];
			return nil;
		}
		[self addSubview: renderer];
		
		
		// Get the screen size to be able to scale images properly
		screenSize = [self bounds].size;
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
		// Update transition if needed
		float fadeThreshold = 0.65f; // TODO: Bind to user defaults
		float percentPosition = 1-((float)[frontImage stepsLeft]/(float)[frontImage stepCount]);
		
		if( percentPosition > fadeThreshold )
		{
			//[transition setValue: [NSNumber numberWithFloat: SMOOTHSTEP((percentPosition-fadeThreshold)/(1-fadeThreshold))]
			//			  forKey: @"inputTime"];
			
			// Update back image position
			if(backImage)
				[backImage moveOneStep];
		}
		
		// Update front image position
		[frontImage moveOneStep];
		
		[self setNeedsDisplay:YES];
	}
}


/*- (void)drawRect:(NSRect)rect
{
	[[renderer openGLContext] makeCurrentContext];
	
	if( !frontImage ) {
		DLog(@"Loading frontImage...");
		PFGLImage* glImage = [[PFGLImage alloc] initWithContentsOfFile:@"/Users/rasmus/Desktop/bild_1000.jpg"];
		frontImage = [[[PFImage alloc] initWithGLImage:glImage] retain];
	}
	
	[[frontImage glImage] drawInRect:rect];
	
	glFlush();
}*/


- (void)drawRect:(NSRect)rect
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
	
	[[renderer openGLContext] makeCurrentContext];
	//[[frontImage glImage] drawInRect:rect sourceRect:[frontImage bounds]];
	//[[frontImage glImage] drawAtPoint:[frontImage bounds].origin];
	[[frontImage glImage] drawInRect:rect sourceRect:[frontImage sourceRect]];
	
	// We are done with front image and need a new back image
	if(![frontImage stepsLeft]) {
		//[transition setValue: [NSNumber numberWithFloat:0.0f] forKey: @"inputTime"];
		[imageCreatorLock lock];
		[imageCreatorLock unlockWithCondition: CL_RUN];
	}
	
	glFlush();
}


#pragma mark -- Threads

- (void)queueFillerThread:(id)obj
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	PFProvider* provider;
	PFImage* im;
	
	@try
	{
		while(1)
		{
			provider = (PFProvider*)[providers objectAtIndex:SSRandomIntBetween(0, [providers count]-1)];
			//provider = (PFProvider*)[providers objectAtIndex:0];
			
			if(im = [provider nextImage])
			{
				[queue put:im];
			}
			else {
				// TODO: implement suspension of specific providers instead of blocking the whole thread
				DLog(@"[%@ nextImage] returned nil. Suspending queue filler thread for 1 second...", provider);
				[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0f]];
			}
		}
	}
	@finally {
		[pool release];
	}
}


// This is redundant, now that we use gl-textures directly. It adds more overhead to 
// pre-resample images than to let it happen in real-time by the GPU.
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
		
		DLog(@"Taking image from queue");
		
		// Swap images - bring back to front
		PFImage* oldFrontImage = frontImage;
		frontImage = backImage;
		
		// Aquire new back image
		backImage = (PFImage*)[queue take];
		[self setupAnimationForImage:backImage];
		
		// Throw away old front image
		if(oldFrontImage)
			[oldFrontImage release];
		
		if(frontImage)
			[imageCreatorLock unlockWithCondition:CL_WAIT];
		else
			[imageCreatorLock unlock];
	}
		
	[pool release];
}


- (void) setupAnimationForImage:(PFImage*)im
{	
	//if([im stepCount])
	//	return; // already setup
	
	NSRect sourceRect = [[im glImage] bounds];
	NSSize imageSize = sourceRect.size;
	
	float screenAspectRatio = screenSize.width / screenSize.height;
	float imageAspectRatio = imageSize.width / imageSize.height;
	float pixelsOutsideScreen = 0.0f;
	
	PFMovingType movingType = PFMovingTypeNone;
	
	// Rescale image so that it fits for sliding horizontally or vertically
	if(imageAspectRatio > screenAspectRatio)
	{
		DLog(@"Image is in landscape format (-)");
		
		//resizeRate = screenSize.height / imageSize.height;
		sourceRect.size.width = imageSize.height * screenAspectRatio;
		pixelsOutsideScreen = imageSize.width - sourceRect.size.width;
		
		//pixelsOutsideScreen = (imageSize.width * resizeRate) - screenSize.width;
		movingType = pixelsOutsideScreen ? PFMovingTypeHorizontally : PFMovingTypeNone;
	}
	
	else if(imageAspectRatio < screenAspectRatio)
	{
		DLog(@"Image is in portrait format (|)");
		
		sourceRect.size.height = imageSize.width / screenAspectRatio;
		pixelsOutsideScreen = imageSize.height - sourceRect.size.height;
		
		//pixelsOutsideScreen = (imageSize.height * resizeRate) - screenSize.height;
		movingType = pixelsOutsideScreen ? PFMovingTypeVertically : PFMovingTypeNone;
	}
	
	DLog(@"screenAspectRatio: %f", screenAspectRatio);
	DLog(@"imageAspectRatio: %f", imageAspectRatio);
	DLog(@"imageSize: %f, %f", imageSize.width, imageSize.height);
	DLog(@"sourceRect.size: %f, %f", sourceRect.size.width, sourceRect.size.height);
	DLog(@"pixelsOutsideScreen: %f", pixelsOutsideScreen);
	
	
	float basedOnFPS = 1.0f / [self animationTimeInterval];
	float timeVisible = 10.0f; // Seconds to show image. TODO: bind to userdefaults
	int stepCount = timeVisible * basedOnFPS;
	
	[im setupAnimation: movingType 
			  stepSize: 1.0f / (stepCount / pixelsOutsideScreen)
			 stepCount: stepCount
			sourceRect: sourceRect];
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
	// Set frame rate
	float fps = [[NSUserDefaults standardUserDefaults] floatForKey:@"rendererFPS"];
	if(fps == 0.0f)
		fps = 60.0f;
	[self setAnimationTimeInterval: 1.0f/fps];
	[super startAnimation];
}

- (void)stopAnimation {
	[super stopAnimation];
}

@end