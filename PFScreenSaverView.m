/*
 * PhotoFeeder is the legal property of its developers.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version. You should have received a copy 
 * of the GNU General Public License along with this program; if not, 
 * write to the Free Software Foundation, Inc., 59 Temple Place, 
 * Suite 330, Boston, MA 02111-1307 USA
 */
#import "PFScreenSaverView.h"
#import "PFFlickrProvider.h"
#import "PFDiskProvider.h"
#import "PFQueue.h"
#import "PFConfigureSheetController.h"


@implementation PFScreenSaverView


static NSString* dstImageId = @"destinationImage";
static NSString* srcImageId = @"sourceImage";



- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    if(self = ([super initWithFrame:frame isPreview:isPreview]))
	{
		DLog(@"");
		
		// Create the mother-queue
		queue = [[PFQueue alloc] initWithCapacity:5];
		
		
		// Setup providers
		providers = [[NSMutableArray alloc] initWithCapacity:2];
		
		[providers addObject:[[PFDiskProvider alloc] initWithPathToDirectory:[NSHomeDirectory() 
			stringByAppendingPathComponent:@"Pictures/_temp"]]];
		
		[providers addObject:[[PFFlickrProvider alloc] init]];
		
		
		// Start filling the queue with images from providers
		[NSThread detachNewThreadSelector: @selector(queueFillerThread:)
								 toTarget: self
							   withObject: nil];
		
		// Load composition into a QCView and keep it as a subview
		qcView = [[QCView alloc] initWithFrame:frame];
		NSString* rendererQtzPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"renderer" ofType:@"qtz"];
		[qcView loadCompositionFromFile:rendererQtzPath];
		[qcView setAutostartsRendering:NO];
		[self addSubview: qcView];
		
		switchImageDispatchT = nil;
    }
    return self;
}


- (void)dealloc
{
	[qcView removeFromSuperview];
	[qcView release];
	[providers release];
	[super dealloc];
}


#pragma mark -- Animation & Rendering


- (void) startAnimation
{
	DLog(@"");
	
	NSUserDefaults* ud = [ScreenSaverDefaults defaultsForModuleWithName:@"com.flajm.PhotoFeeder"]; // TODO
	
	userFps = [ud floatForKey:@"rendererFPS"];
	if(userFps == 0.0)
		userFps = 60.0;
	
	userFadeInterval = [ud floatForKey:@"fadeInterval"];
	if(userFadeInterval == 0.0)
		userFadeInterval = 1.0;
	
	userDisplayInterval = [ud floatForKey:@"displayInterval"];
	if(userDisplayInterval == 0.0)
		userDisplayInterval = 3.0;
	
	// Berätta för Q-kompositionen hur länge bilder skall visas & fadeas
	// Regarding the "enabled" key... it has the following three states:
	// 0 means fading down and keeping it at 0% alpha
	// 1 means fading up and keeping it at 100% alpha
	// 2 means not fading at all, keeping it at 0% alpha
	[qcView setValue: [NSNumber numberWithDouble:userDisplayInterval]  forInputKey: @"timeVisible"];
	[qcView setValue: [NSNumber numberWithDouble:userFadeInterval]     forInputKey: @"timeFading"];
	[qcView setValue: [NSNumber numberWithDouble:2.0]                  forInputKey: @"statusMessageEnabled"];
	

	[qcView setMaxRenderingFrameRate: userFps];
	[qcView startRendering];
	
	// Fork the imageSwitchDispatchThread (pungsvett från räkan)
	imagePortName = dstImageId;
	if(!switchImageDispatchT)
	{
		[NSThread detachNewThreadSelector: @selector(switchImageDispatchThread:)
										 toTarget: self
									  withObject: nil];
	}
}


- (void) drawRect:(NSRect)r
{
	DLog(@"");
	[qcView setFrame:r];
}


- (void)stopAnimation
{
	DLog(@"");
	[qcView stopRendering];
	[super stopAnimation];
}



#pragma mark -- Threads

- (void)queueFillerThread:(id)obj
{
	NSAutoreleasePool *pool;
	PFProvider* provider;
	NSImage* im;
	
	@try
	{
		while(1)
		{
			pool = [[NSAutoreleasePool alloc] init];
			provider = (PFProvider*)[providers objectAtIndex:SSRandomIntBetween(0, [providers count]-1)];
			
			if(im = [provider nextImage])
			{
				[queue put:[self resizeImageIfNeeded:im]];
			}
			else
			{
				// TODO: implement suspension of specific providers instead of blocking the whole thread
				static float suspendSecs = 3.0f;
				DLog(@"[%@ nextImage] returned nil. Suspending queue filler thread for %.0f second...", provider, suspendSecs);
				[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:suspendSecs]];
			}
			
			[pool release];
		}
	}
	@finally {
		if(pool)
			[pool release];
	}
}


- (void) switchImageDispatchThread:(id)obj
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	switchImageDispatchT = [NSThread currentThread];
	@try
	{
		NSObject* firstTime = [NSThread currentThread];
		imagePortName = srcImageId;
		double delay;
		
		while(1)
		{
			delay = [self switchImage:firstTime];
			[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:delay]];
			if(firstTime)
				firstTime = nil;
		}
	}
	@finally {
		[pool release];
	}
}


#pragma mark -- Etc...

- (double) switchImage:(NSObject*)isFirstTime
{
	// Log!
	DLog(@"%@", imagePortName);
	
	// Take the next image from the image queue
	NSImage* image = (NSImage*)[queue poll];
	
	// Check if queue is empty
	if(!image)
	{
		DLog(@"Image queue is depleted");
		if(!([[qcView valueForInputKey:@"statusMessageEnabled"] doubleValue] == 1.0))
			[qcView setValue: [NSNumber numberWithDouble:1.0]  forInputKey: @"statusMessageEnabled"];

		[qcView setValue: @"Image queue is depleted.\nI will not show any new images until\nI've fetched/downloaded some..."  forInputKey: @"statusMessageText"];
		return 1.0;
	}
	else if([[qcView valueForInputKey:@"statusMessageEnabled"] doubleValue] == 1.0)
	{
		[qcView setValue: [NSNumber numberWithDouble:0.0]  forInputKey: @"statusMessageEnabled"];
	}
	
	// Pass the image to QC, which will cause the bitmap data to be copied onto a
	// texture. Takes some time...
	[qcView setValue:image forInputKey:imagePortName];
	[image release];
	
	
	// Now, let's decide on delay for the next switch
	double delay;
	double time = [[qcView valueForInputKey: @"time"] doubleValue];
	double userDisplayAndFadeInterval = userDisplayInterval + userFadeInterval;
	
	if(isFirstTime)
	{
		delay = userFadeInterval;
	}
	else
	{
		delay = (userDisplayAndFadeInterval - (time - (floor(time / userDisplayAndFadeInterval) * userDisplayAndFadeInterval))) + userFadeInterval;
		
		//DLog(@"time: %f, delay: %f \n  userDisplayAndFadeInterval = %f \n  floor(time / userDisplayAndFadeInterval) = %f \n  (floor(time / userDisplayAndFadeInterval) * userDisplayAndFadeInterval) = %f",
		//	  time, delay, userDisplayAndFadeInterval, floor(time / userDisplayAndFadeInterval), 
		//	  floor(time / userDisplayAndFadeInterval) * userDisplayAndFadeInterval);
	}
	
	
	// Switch image port name back and fourth each time
	// TODO: Fix this. Will not work with alot of large images
	//if(delay <= userDisplayAndFadeInterval)
	//{
		//DLog(@"switching im port name");
		imagePortName = (imagePortName == srcImageId) ? dstImageId : srcImageId;
	//}
	//else
	//{
	//	DLog(@"I was to slow - wont switch im port name");
	//}
	
	
	DLog(@"delay: %f", delay);
	
	return delay;
}


- (NSImage*) resizeImageIfNeeded:(NSImage*)im
{
	// TODO: if im.size > (120% of screen.size) then resize it to fit
	return im;
}


- (BOOL)hasConfigureSheet
{
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


- (BOOL) isOpaque
{
    return YES;
}


/*- (void)setFrameSize:(NSSize)newSize
{
	[qcView setFrameSize:newSize];
}*/

@end