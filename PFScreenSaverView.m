
#import "PFScreenSaverView.h"
#import "PFFlickrProvider.h"
#import "PFQueue.h"

@implementation PFScreenSaverView

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
		NSLog(@"[PhotoFeederView initWithFrame...]");
		
		// Cache frame for speed
		myFrame = frame;
		
		// Create the mother-queue
		queue = [[PFQueue alloc] initWithCapacity:20];
		
		// Inti current crop position (used by animateOneFrame)
		cropPosition = NSMakePoint(0,0);
		
		// Setup providers
		providers = [[NSMutableArray alloc] initWithCapacity:2];
		[providers addObject:[[PFFlickrProvider alloc] init]];
		[providers addObject:[[PFFlickrProvider alloc] init]];
		
		// Start filling the queue with images from providers
		[NSThread detachNewThreadSelector:@selector(queueFillerThread:) toTarget:self withObject:nil];
		
		// Start creating next and current image from queue URLs
		imageCreatorLock = [[NSConditionLock alloc] initWithCondition:CL_RUN];
		[NSThread detachNewThreadSelector:@selector(imageCreatorThread:) toTarget:self withObject:nil];
		
		// Create message text
		statusText = [[PFText alloc] initWithText:@"Loading..."];
		
		// Calculate frame w/h ratio
		frameRatio = frame.size.width / frame.size.height;
		
        [self setAnimationTimeInterval:1/30.0];
    }
    return self;
}

- (void)dealloc
{
	[providers release];
	[imageCreatorLock release];
	[statusText release];
	[super dealloc];
}


- (void)queueFillerThread:(id)obj
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	PFProvider* provider;
	while(1) {
		/* TODO remove this --> */ //sleep(2);
		provider = (PFProvider*)[providers objectAtIndex:SSRandomIntBetween(0, [providers count]-1)];
		[queue put:[provider getURL]];
		/*provider = (PFProvider*)[providers objectAtIndex:0];
		[queue put:[provider getURL]];
		provider = (PFProvider*)[providers objectAtIndex:1];
		[queue put:[provider getURL]];*/
	}
	[pool release];
}


- (void)imageCreatorThread:(id)obj
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	while(1)
	{
		[imageCreatorLock lockWhenCondition:CL_RUN];
		
		NSLog(@"[PhotoFeederView nextImage] Taking url from queue and fetching image data...");
		NSImage* oldImage = currentImage;
		currentImage = nextImage;
		nextImage = [[NSImage alloc] initWithContentsOfURL:(NSURL*)[queue take]];
		if(oldImage)
			[oldImage release];
		NSLog(@"[PhotoFeederView nextImage] done");
		
		if(currentImage) {
			// Calculate stuff
			currImSize = [currentImage size];
			currImCropWidth = currImSize.width;
			currImCropHeight = currImSize.height;
			currImRatio = currImCropWidth / currImCropHeight;
			currImIsWider = (currImRatio > frameRatio);
			if(currImIsWider) // image height is less than screen height (in percentile)
				currImCropWidth = currImCropHeight * frameRatio;
			else // image width is less than screen width (in percentile)
				currImCropHeight = currImCropWidth / frameRatio;
			currImResizeFactor = currImCropWidth / myFrame.size.width;
			
			[imageCreatorLock unlockWithCondition:CL_WAIT];
		}
		else
			[imageCreatorLock unlock];
	}
	[pool release];
}


- (void)animateOneFrame
{
	if(!currentImage) {
		// TODO: text: loading...
		NSLog(@"[PhotoFeederView animateOneFrame] Loading... (waiting for an image to become available)");
		NSSize statusTextSize = [[statusText attrString] size];
		[[NSColor blackColor] set];
		[NSBezierPath fillRect:[self frame]];
		[statusText drawAt:NSMakePoint((myFrame.size.width/2)-(statusTextSize.width/2), (myFrame.size.height/2)-(statusTextSize.height/2))];
		return;
	}
	//NSLog(@"[PhotoFeederView animateOneFrame] Rendering frame...");
	
	
	// TODO: isolate in PFImage class
	/*NSSize imSize = [currentImage size];
	float imCropWidth = imSize.width;
	float imCropHeight = imSize.height;
	float imRatio = imCropWidth/imCropHeight;
	BOOL  isWider = (imRatio > frameRatio);
	
	if(isWider) // image height is less than screen height (in percentile)
		imCropWidth = imCropHeight * frameRatio;
	else // image width is less than screen width (in percentile)
		imCropHeight = imCropWidth / frameRatio;
	
	float imResizeFactor = imCropWidth / myFrame.size.width;*/
	
	// NOTE! Caching the above DID NOT DECREASE THE LOAD!
	// We need to resample the image before displaying it. Now we are
	// resampling the image each time we draw it. That's what's taking so long.
	
	
	// Do this every render/draw
	[currentImage drawInRect:myFrame 
					fromRect:NSMakeRect(cropPosition.x, cropPosition.y, currImCropWidth, currImCropHeight)
				   operation:NSCompositeSourceAtop
					fraction:1.0];
	
	if(currImIsWider && currImSize.width-(cropPosition.x+=currImResizeFactor) <= myFrame.size.width*currImResizeFactor) {
		[imageCreatorLock lockWhenCondition:CL_WAIT];
		[imageCreatorLock unlockWithCondition:CL_RUN];
		cropPosition.x = 0;
		cropPosition.y = 0;
	}
	else if((!currImIsWider) && currImSize.height-(cropPosition.y+=currImResizeFactor) <= myFrame.size.height*currImResizeFactor) {
		[imageCreatorLock lockWhenCondition:CL_WAIT];
		[imageCreatorLock unlockWithCondition:CL_RUN];
		cropPosition.x = 0;
		cropPosition.y = 0;
	}
}

// Speed things up
- (BOOL) isOpaque
{
    return YES;
}

- (void)startAnimation
{
	[super startAnimation];
}

- (void)stopAnimation
{
	[super stopAnimation];
}

- (void)drawRect:(NSRect)rect {
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow*)configureSheet
{
    return nil;
}

@end
