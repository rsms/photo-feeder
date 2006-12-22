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

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    if(self = ([super initWithFrame:frame isPreview:isPreview]))
	{
		DLog(@"");
		
		// Create the mother-queue
		queue = [[PFQueue alloc] initWithCapacity:20];
		
		// Setup providers
		providers = [[NSMutableArray alloc] initWithCapacity:2];
		//[providers addObject:[[PFFlickrProvider alloc] init]];
		[providers addObject:[[PFDiskProvider alloc] initWithPathToDirectory:[NSHomeDirectory() stringByAppendingPathComponent:@"Pictures/_qc_test"]]];
		
		// Start filling the queue with images from providers
		[NSThread detachNewThreadSelector: @selector(queueFillerThread:)
								 toTarget: self
							   withObject: nil];
		
		// Load composition into a QCView and keep it as a subview
		qcView = [[QCView alloc] initWithFrame:frame];
		[qcView loadCompositionFromFile: [[NSBundle mainBundle] pathForResource:@"renderer" ofType:@"qtz"]];
		[qcView setAutostartsRendering:NO];
		[self addSubview: qcView];
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
	
	double userFps;
	NSUserDefaults* ud = [NSUserDefaults standardUserDefaults]; // TODO
	
	userFps = [ud floatForKey:@"rendererFPS"];
	if(userFps == 0.0) userFps = 60.0;
	
	userFadeInterval = [ud floatForKey:@"fadeInterval"];
	if(userFadeInterval == 0.0) userFadeInterval = 1.0;
	
	userDisplayInterval = [ud floatForKey:@"displayInterval"];
	if(userDisplayInterval == 0.0) userDisplayInterval = 6.0;
	
	animationInterval = 1.0/userFps;
	
	[qcView setMaxRenderingFrameRate: userFps];
	[qcView startRendering];
	
	// We only need to call animateOneFrame
	//[self setAnimationTimeInterval: INT_MAX];
	[self initAnimation];
	//[super startAnimation];
}


- (void) initAnimation
{
	DLog(@"");
	
	// Beräkna total tid (pungsvett från räkan)
	transitionAndDisplayInterval = (userDisplayInterval + userFadeInterval) * 2;
	
	// Berätta för Q-kompositionen hur länge bilder skall visas & fadeas
	[qcView setValue: [NSNumber numberWithDouble:userDisplayInterval]  forInputKey: @"timeVisible"];
	[qcView setValue: [NSNumber numberWithDouble:userFadeInterval]     forInputKey: @"timeFading"];
	
	// Starta bild 0 switch
	[self performSelector: @selector(switchImage:) 
				  withObject: @"sourceImage" 
				  afterDelay: 0];
	
	// Starta bild 1 switch
	[self performSelector: @selector(switchImage:) 
				  withObject: @"destinationImage" 
				  afterDelay: userFadeInterval + userDisplayInterval];
}


- (void) drawRect:(NSRect)r
{
	[qcView setFrame:r];
}


- (void)stopAnimation
{
	DLog(@"");
	animationIsInitialized = NO;
	[qcView stopRendering];
	[super stopAnimation];
}



#pragma mark -- Threads

- (void)queueFillerThread:(id)obj
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	PFProvider* provider;
	NSImage* im;
	
	@try
	{
		while(1)
		{
			provider = (PFProvider*)[providers objectAtIndex:SSRandomIntBetween(0, [providers count]-1)];
			
			if(im = [provider nextImage]) {
				[queue put:im];
			}
			else {
				// TODO: implement suspension of specific providers instead of blocking the whole thread
				static float suspendSecs = 3.0f;
				DLog(@"[%@ nextImage] returned nil. Suspending queue filler thread for %.0f second...", provider, suspendSecs);
				[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:suspendSecs]];
			}
		}
	}
	@finally {
		[pool release];
	}
}



#pragma mark -- Etc...

- (void) switchImage:(NSString*)imagePortName
{
	DLog(@"%@", imagePortName);
	
	// Take the next image from the image queue
	NSImage* image = (NSImage*)[queue take];
	if(!image)
	{
		NSLog(@"Image queue is depleted");
		return;
	}
	
	// Set image in QC
	[qcView setValue:image forInputKey:imagePortName];
	
	//Release next image
	[image release];
	
	// Schedule next switch
	[self performSelector:@selector(switchImage:) 
				  withObject:imagePortName
				  afterDelay:transitionAndDisplayInterval];
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