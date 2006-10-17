//
//  PhotoFeederView.m
//  PhotoFeeder
//
//  Created by Rasmus Andersson on 2006-10-16.
//  Copyright (c) 2006, __MyCompanyName__. All rights reserved.
//

#import "PhotoFeederView.h"
#import "PFProvider.h"
#import "PFQueue.h"

@interface PhotoFeederView (Private)
int y;
PFQueue* queue;
NSImage* currentImage;
NSImage* nextImage;
NSMutableArray* providers;
NSConditionLock* imageCreatorLock;
@end

@implementation PhotoFeederView

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
		NSLog(@"[PhotoFeederView initWithFrame...]");
		queue = [[PFQueue alloc] initWithCapacity:20];
		
		// Setup providers
		providers = [[NSMutableArray alloc] initWithCapacity:2];
		[providers addObject:[[PFProvider alloc] init]];
		[providers addObject:[[PFProvider alloc] init]];
		
		// Start filling the queue with images from providers
		[NSThread detachNewThreadSelector:@selector(queueFillerThread:) toTarget:self withObject:nil];
		
		// Start creating next and current image from queue URLs
		imageCreatorLock = [[NSConditionLock alloc] initWithCondition:CL_RUN];
		[NSThread detachNewThreadSelector:@selector(imageCreatorThread:) toTarget:self withObject:nil];
		
        [self setAnimationTimeInterval:1/30.0];
    }
    return self;
}

- (void)dealloc
{
	[providers release];
	[imageCreatorLock release];
	[super dealloc];
}


- (void)queueFillerThread:(id)obj
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	PFProvider* provider;
	while(1) {
		//provider = (PFProvider*)[providers objectAtIndex:SSRandomIntBetween(0, [providers count]-1)];
		//[queue put:[provider getURL]];
		provider = (PFProvider*)[providers objectAtIndex:0];
		[queue put:[provider getURL]];
		provider = (PFProvider*)[providers objectAtIndex:1];
		[queue put:[provider getURL]];
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
		
		if(currentImage)
			[imageCreatorLock unlockWithCondition:CL_WAIT];
		else
			[imageCreatorLock unlock];
	}
	[pool release];
}


- (void)animateOneFrame
{
	[[NSColor blackColor] set];
	[NSBezierPath fillRect:[self frame]];
	
	//NSLog(@"animateOneFrame: [currentImage drawAtPoint:NSMakePoint(0,0)];");
	
	if(!currentImage) {
		// TODO: text: loading...
		NSLog(@"[PhotoFeederView animateOneFrame] DRAW TEXT: Loading... (waiting for an image to become available)");
		return;
	}
	NSLog(@"[PhotoFeederView animateOneFrame] Rendering frame...");
	
	[currentImage drawInRect:[self frame] 
					fromRect:NSMakeRect(0,0, [currentImage size].width, [currentImage size].height) 
				   operation:NSCompositeSourceAtop
					fraction:1.0];

	//[[NSColor redColor] set];
	//[NSBezierPath fillRect:NSMakeRect(0,y++,10,10)];
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
