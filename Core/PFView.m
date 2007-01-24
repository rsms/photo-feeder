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
#import "PFView.h"
#import "PFProvider.h"
#import "PFUIController.h"
#import "../Core/PFMain.h"
#import "../Core/PFUtil.h"

@implementation PFView

// Our two image ports
static NSString* dstImageId = @"destinationImage";
static NSString* srcImageId = @"sourceImage";



- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
	if(self = ([super initWithFrame:frame isPreview:isPreview]))
	{
		DLog(@"");
		
		// Register ourselves in PFMain
		[[PFMain instance] registerView:self isPreview:isPreview];
		
		// Load composition into a QCView and keep it as a subview
		qcView = [[QCView alloc] initWithFrame:frame];
		[qcView loadCompositionFromFile:[[[PFMain instance] bundle] pathForResource:@"standard" ofType:@"qtz"]];
		[qcView setAutostartsRendering:NO];
		[self addSubview: qcView];
		[qcView setValue: [NSNumber numberWithDouble:1.0]  forInputKey: @"statusMessageEnabled"];
    }
    return self;
}


- (void)dealloc
{
	[qcView removeFromSuperview];
	[qcView release];
	[super dealloc];
}



#pragma mark -
#pragma mark Animation & Rendering


- (void) startAnimation
{
	DLog(@"");
	
	[self renderingParametersDidChange];
	[qcView setValue: @"Loading images..." forInputKey: @"statusMessageText"];
	
	// Fork threads on first call to startAnimation (pungsvett från räkan)
	if(!switchImageThreadsAreRunning)
	{
		[NSThread detachNewThreadSelector: @selector(switchImageDispatchThread:)
										 toTarget: self
									  withObject: nil];
	}
	
	// Start animation timer and unlock "critical section"
	hasResetTimer = NO;
	isFirstTime = YES;
	[super startAnimation];
	[qcView startRendering];
	[qcView setValue:[NSNumber numberWithBool: TRUE] forInputKey:@"startTime"];
	[[PFMain instance] animationStartedByView:self];
}


- (void) renderingParametersDidChange
{
	DLog(@"");
	
	// Cache these values in the instance
	userFps = [PFUtil defaultFloatForKey:@"fps"];
	userFadeInterval = [PFUtil defaultFloatForKey:@"fadeInterval"];
	userDisplayInterval = [PFUtil defaultFloatForKey:@"displayInterval"];
	
	// Berätta för Q-kompositionen hur länge bilder skall visas & fadeas
	// Regarding the "enabled" key... it has the following three states:
	// 0 means fading down and keeping it at 0% alpha
	// 1 means fading up and keeping it at 100% alpha
	// 2 means not fading at all, keeping it at 0% alpha
	[qcView setValue: [NSNumber numberWithDouble:userDisplayInterval]  forInputKey: @"timeVisible"];
	[qcView setValue: [NSNumber numberWithDouble:userFadeInterval]     forInputKey: @"timeFading"];
	[qcView setMaxRenderingFrameRate: userFps];
	
	// Update factors needed for image port switch synchronization
	imagePortMinSrc = (userFadeInterval*2)+userDisplayInterval;
	imagePortMaxSrc = (userFadeInterval+userDisplayInterval)*2;
	imagePortMinDst = userFadeInterval;
	imagePortMaxDst = userFadeInterval+userDisplayInterval;
}


- (void) drawRect:(NSRect)r
{
	[qcView setFrame:r];
}


- (void) stopAnimation
{
	DLog(@"");
	[[PFMain instance] animationStoppedByView:self]; // need to be called first
	[qcView stopRendering];
	[super stopAnimation];
}


#pragma mark -
#pragma mark Threads

- (void) switchImageDispatchThread:(id)obj
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	switchImageThreadsAreRunning = YES;
	@try
	{
		isFirstTime = YES;
		imagePortName = srcImageId;
		double delay;
		
		while(1)
		{
			
			// Hold here if animation is stopped
			[[PFMain instance] blockWhileStopped];
			
			delay = [self switchImage:isFirstTime];
			
			// If we don't have an image yet, wait a short while before trying again.
			if (delay == -1.0)
				delay = 1.0;
			else
				isFirstTime = NO;
			
			[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:delay]];
			
		}
	}
	@finally {
		[pool release];
	}
}



#pragma mark -
#pragma mark Image switching



- (double) switchImage:(BOOL)isFirstTimee
{
	NSImage* image = nil;
	double time, delay;
	float imagePortMod;
	int imagePortState;
	
	image = [[[PFMain instance] queue] poll];
	time = [[qcView valueForInputKey: @"time"] doubleValue];
	imagePortMod = ceil(FMOD(time, (userDisplayInterval+userFadeInterval)*2));
	
	if(imagePortMod >= imagePortMinSrc && imagePortMod <= imagePortMaxSrc)
	{
		imagePortName = srcImageId;
		imagePortState = 1;
		//DLog(@"-------------------  SRC  time: %.4f  mod: %.4f  src: %.1f - %.1f  dst: %.1f - %.1f", time, imagePortMod, 
		//	  imagePortMinSrc, imagePortMaxSrc, imagePortMinDst, imagePortMaxDst);
	}
	else if(imagePortMod >= imagePortMinDst && imagePortMod <= imagePortMaxDst)
	{
		imagePortName = dstImageId;
		imagePortState = 2;
		//DLog(@"-------------------  DST  time: %.4f  mod: %.4f  src: %.1f - %.1f  dst: %.1f - %.1f", time, imagePortMod, 
		//	  imagePortMinSrc, imagePortMaxSrc, imagePortMinDst, imagePortMaxDst);
	}
	else
	{
		// Error correction - if call is out of sync, this block is executed.
		if(!isFirstTime)
			imagePortName = (imagePortName == srcImageId) ? dstImageId : srcImageId;
		imagePortState = 0;
		//DLog(@"-------------------   ?   time: %.4f  mod: %.4f  src: %.1f - %.1f  dst: %.1f - %.1f", time, imagePortMod, 
		//	  imagePortMinSrc, imagePortMaxSrc, imagePortMinDst, imagePortMaxDst);
	}
	
	
	// Check if queue is empty
	if(!image)
	{
		//DLog(@"image = nil");
		if(isFirstTime)
		{
			return -1.0;
		}
		else
		{
			[qcView setValue: @"Loading images..." forInputKey: @"statusMessageText"];
			[qcView setValue: [NSNumber numberWithDouble:1.0]  forInputKey: @"statusMessageEnabled"];
			DLog(@"Image queue is depleted");
		}
	}
	else if(imagePortState && !isFirstTime)
	{
		[qcView setValue: [NSNumber numberWithDouble:0.0]  forInputKey: @"statusMessageEnabled"];
		
		// Pass the image to QC, which will cause the bitmap data to be copied onto a
		// texture. Takes some time...
		[qcView setValue:image forInputKey:imagePortName];
		[image release];
		
		// First time, we know the exact delay:
		if(!hasResetTimer)
		{
			[qcView setValue:[NSNumber numberWithBool: TRUE] forInputKey:@"resetTime"];
			delay = userFadeInterval;
			hasResetTimer = YES;
		}
	}
	
	//time = [[qcView valueForInputKey: @"time"] doubleValue]; // we don't need the exakthet säger räkans med pungsvett
	double userDisplayAndFadeInterval = userDisplayInterval + userFadeInterval;
	delay = (userDisplayAndFadeInterval - (time - (floor(time / userDisplayAndFadeInterval) * userDisplayAndFadeInterval))) + userFadeInterval;
	
	DLog(@"Next switch will operate in %f seconds", imagePortName, delay);
	return delay;
}



#pragma mark -
#pragma mark Delegate methods


- (BOOL)hasConfigureSheet
{
    return YES;
}


- (NSWindow*)configureSheet
{
	return [[PFMain instance] configureSheet];
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