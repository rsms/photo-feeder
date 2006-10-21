
#import "PFScreenSaverView.h"
#import "PFFlickrProvider.h"
#import "PFQueue.h"



@implementation PFScreenSaverView

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
		NSLog(@"[PhotoFeederView initWithFrame...]");
		
		screenSize = [self bounds].size;
		
		// Create the mother-queue
		queue = [[PFQueue alloc] initWithCapacity:20];
				
		// Setup providers
		providers = [[NSMutableArray alloc] initWithCapacity:2];
		[providers addObject:[[PFFlickrProvider alloc] init]];
		//[providers addObject:[[PFFlickrProvider alloc] init]];
		
		// Start filling the queue with images from providers
		[NSThread detachNewThreadSelector:@selector(queueFillerThread:) toTarget:self withObject:nil];
		
		// Start creating next and current image from queue URLs
		imageCreatorLock = [[NSConditionLock alloc] initWithCondition:CL_RUN];
		[NSThread detachNewThreadSelector:@selector(imageCreatorThread:) toTarget:self withObject:nil];
		
		// Create message text
		statusText = [[PFText alloc] initWithText:@"Loading..."];
		
		// Setup renderer
		renderer = [PFGLRenderer newRenderer];
		if (!renderer) {
			NSLog( @"Couldn't initialize OpenGL view." );
			[self autorelease];
			return nil;
		}
		[self addSubview:renderer]; 
		[renderer prepare];
		
		// Set frame rate
        [self setAnimationTimeInterval:1/30.0];
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
	// WHEN I WANT NEW SHIT
	// [imageCreatorLock lockWhenCondition:CL_WAIT];
	// [imageCreatorLock unlockWithCondition:CL_RUN];
	
	[self setNeedsDisplay:YES];
}



- (void)drawRect:(NSRect)rectangle
{
    [[renderer openGLContext] makeCurrentContext];
	
	if (ciContext == nil)
    {
		ciContext = [[CIContext contextWithCGLContext: CGLGetCurrentContext() 
										pixelFormat: [[renderer pixelFormat] CGLPixelFormatObj] 
											options: nil] retain];
    }
	
    // Fill the view black between each rendered frame (overwriting the old image)
    glColor4f (0.0f, 0.0f, 0.0f, 0.0f);
    glBegin(GL_POLYGON);
	glVertex2f (rectangle.origin.x, rectangle.origin.y);
	glVertex2f (rectangle.origin.x + rectangle.size.width, rectangle.origin.y);
	glVertex2f (rectangle.origin.x + rectangle.size.width, rectangle.origin.y + rectangle.size.height);
	glVertex2f (rectangle.origin.x, rectangle.origin.y + rectangle.size.height);
    glEnd();
	
	// Update the image being shown
	// TODO: Increment position
	frontImage.position.x += 0.5;
	
    CGRect thumbFrame = CGRectMake(rectangle.origin.x + frontImage.position.x, rectangle.origin.y, rectangle.size.width, rectangle.size.height);
	
	[ciContext drawImage: frontImage.im
				 atPoint: CGPointZero
				fromRect: thumbFrame];
    
    glFlush();
}




#pragma mark -- Threads

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


- (PFImage)createResizedImageFromCIImage:(CIImage *)im
{	
	float screenAspectRatio = screenSize.width / screenSize.height;
	CGSize imageSize = [im extent].size;
	float imageAspectRatio = imageSize.width / imageSize.height;
	float resizeRate = 0;
	
	// Rescale image so that it fits for sliding horizontally or vertically
	if(imageAspectRatio > screenAspectRatio)
	{
		NSLog(@"Image is in landscape format");
		resizeRate = screenSize.height / imageSize.height;
	}
	
	else if(imageAspectRatio <= screenAspectRatio)
	{
		NSLog(@"Image is in portrait format");
		
		resizeRate = screenSize.width / imageSize.width;
		if( (imageSize.width > screenSize.width) && (resizeRate < 1.0) )
		{
			NSLog(@"Screen narrower than image, and we need to scale down image");
			//resizeRate = 1 / resizeRate;
		}
		
		else if( (imageSize.width < screenSize.width) && (resizeRate > 1.0) )
		{
			NSLog(@"Screen wider than image, and we need to scale up image");
		}
	}
	
	NSLog(@"Doing resize a la: %f", resizeRate);
	PFImage i = PFImageCreate([im imageByApplyingTransform: CGAffineTransformMakeScale(resizeRate, resizeRate)]);
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
		backImage = [self createResizedImageFromCIImage: [CIImage imageWithContentsOfURL: url]];
		
		// Throw away old front image
		PFImageRelease(oldFrontImage);
		
		if(PFImageIsValid(frontImage))
			[imageCreatorLock unlockWithCondition:CL_WAIT];
		else
			[imageCreatorLock unlock];
	}
	
	
	[pool release];
	
	
}



#pragma mark -- Etc

- (void)setFrameSize:(NSSize)newSize { 
	[renderer setFrameSize:newSize];
}

- (BOOL) isOpaque {
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

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow*)configureSheet
{
    return nil;
}

@end
