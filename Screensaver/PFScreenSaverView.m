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
#import "PFProvider.h"
#import "PFFlickrProvider.h"
#import "PFQueue.h"
#import "PFConfigureSheetController.h"
#import "PFUtil.h"

@implementation PFScreenSaverView

// Our two image ports
static NSString* dstImageId = @"destinationImage";
static NSString* srcImageId = @"sourceImage";



- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    if(self = ([super initWithFrame:frame isPreview:isPreview]))
	{
		DLog(@"");
		
		// Create the mother-queue
		queue = [[PFQueue alloc] initWithCapacity:7];
		
		// Setup available providers storage
		availableProviders = [[NSMutableArray alloc] init];
		
		// Load plugins (providers, etc)
		[self loadPlugins];
		
		// Setup and instantiate providers
		providers = [[NSMutableArray alloc] init];
		NSEnumerator* en = [availableProviders objectEnumerator];
		Class providerClass;
		while ((providerClass = [en nextObject]))
		{
			PFProviderClass* provider = [[providerClass alloc] init];
			[providers addObject:provider];
		}
		/*[providers addObject:[[PFDiskProvider alloc] initWithPathToDirectory:[NSHomeDirectory() 
			stringByAppendingPathComponent:@"Pictures/_temp"]]];*/
		//[providers addObject:[[PFFlickrProvider alloc] init]];
		
		
		// Init runningProvidersCount
		runningProvidersCount = 0;
		providerThreadsAvailableCondLock = [[NSConditionLock alloc] initWithCondition:TRUE];
		
		
		// Load composition into a QCView and keep it as a subview
		qcView = [[QCView alloc] initWithFrame:frame];
		NSString* rendererQtzPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"standard" ofType:@"qtz"];
		[qcView loadCompositionFromFile:rendererQtzPath];
		[qcView setAutostartsRendering:NO];
		[self addSubview: qcView];
		
		
		switchImageDispatchT = nil;
		runCond = [[NSConditionLock alloc] initWithCondition:FALSE];
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


#pragma mark -- Plugins


- (void) loadPlugins
{
	DLog(@"");
	[self loadProvidersFromPath:[[NSBundle bundleForClass:[self class]] builtInPlugInsPath]];
	//[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Application Support/PhotoFeeder/Plugins"];
}


- (void) loadProvidersFromPath:(NSString*)path
{
	DLog(@"path: %@", path);
	if(path)
	{
		NSString* pluginPath;
		NSEnumerator* enumerator = [[NSBundle pathsForResourcesOfType:@"pfprovider"
																		  inDirectory:path] objectEnumerator];
		while ((pluginPath = [enumerator nextObject]))
		{
			[self loadProviderFromPath:pluginPath];
		}
	}
}


- (void) loadProviderFromPath:(NSString*)path
{
	DLog(@"path: %@", path);
	
	// Locate bundle
	NSBundle* pluginBundle = [NSBundle bundleWithPath:path];
	if(!pluginBundle)
	{
		NSTrace(@"ERROR: Unable to load provider bundle with path '%@'", path);
		return;
	}
	
	// Get entry-classname
	NSDictionary* pluginDict = [pluginBundle infoDictionary];
	NSString* pluginClassName = [pluginDict objectForKey:@"NSPrincipalClass"];
	if(!pluginClassName)
	{
		NSTrace(@"ERROR: Unable to get NSPrincipalClass from provider bundle at path '%@'", path);
		return;
	}
	
	// Already loaded?
	Class pluginClass = NSClassFromString(pluginClassName);
	if(pluginClass)
	{
		NSTrace(@"ERROR: Provider namespace conflict: %@ is already loaded", pluginClassName);
		return;
	}
	
	//	Type and inheritance sanity checks
	pluginClass = [pluginBundle principalClass];
	NSString* pluginIdentifier = [pluginBundle bundleIdentifier];
	if(![pluginClass conformsToProtocol:@protocol(PFProvider)])
	{
		NSTrace(@"ERROR: Provider '%@' must conform to the PFProvider protocol", pluginIdentifier);
		return;
	}
	else if(![pluginClass isKindOfClass:[NSObject class]])
	{
		NSTrace(@"ERROR: Provider '%@' must be a subclass of NSObject", pluginIdentifier);
		return;
	}
	
	// If it loads, it can run
	if([pluginClass initClass:pluginBundle
						  defaults:[ScreenSaverDefaults defaultsForModuleWithName:pluginIdentifier]])
	{
		[availableProviders addObject:pluginClass];
	}
}


#pragma mark -- Animation & Rendering


- (void) startAnimation
{
	DLog(@"");
	
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
	[qcView setValue: [NSNumber numberWithDouble:2.0]                  forInputKey: @"statusMessageEnabled"];
	
	DLog(@"userFadeInterval: %f", userFadeInterval);

	[qcView setMaxRenderingFrameRate: userFps];
	[qcView startRendering];
	
	
	// Index over providers running state (1=running, 0=not running)
	runningProviders = (short *)malloc(sizeof(short) * [providers count]);
	unsigned i = [providers count];
	while(i--)
		runningProviders[i] = 0;

	
	// Reset image ports
	imagePortName = dstImageId;
	
	// Fork threads on first call to startAnimation (pungsvett från räkan)
	if(!switchImageDispatchT)
	{
		[NSThread detachNewThreadSelector: @selector(switchImageDispatchThread:)
										 toTarget: self
									  withObject: nil];
		
		// Start filling the queue with images from providers
		[NSThread detachNewThreadSelector: @selector(queueFillerThread:)
										 toTarget: self
									  withObject: nil];
	}
	
	
	[super startAnimation];
	[runCond lock];
	[runCond unlockWithCondition:TRUE];
}


- (void) drawRect:(NSRect)r
{
	DLog(@"");
	[qcView setFrame:r];
}


- (void)stopAnimation
{
	DLog(@"");
	[runCond lock];
	[runCond unlockWithCondition:FALSE];
	[qcView stopRendering];
	[super stopAnimation];
	free(runningProviders);
}



#pragma mark -- Threads

- (void)queueFillerThread:(id)obj
{
	NSAutoreleasePool *pool;
	PFProviderClass* provider;
	unsigned providerIndex, providerCount;
	
	pool = [[NSAutoreleasePool alloc] init];
	
	@try
	{
		while(1)
		{
			// Hold here if animation is stopped
			[runCond lockWhenCondition:TRUE];
			[runCond unlock];
			
			// Lock and run if we have available providers
			[providerThreadsAvailableCondLock lockWhenCondition:TRUE];
			
			// Pick a random provider
			providerCount = [providers count];
			providerIndex = SSRandomIntBetween(0, [providers count]-1);
			while(runningProviders[providerIndex])
				if(++providerIndex == providerCount)
					providerIndex = 0;
			
			
			if(providerIndex != -1)
			{
				provider = (PFProviderClass*)[providers objectAtIndex:providerIndex];
				runningProviders[providerIndex] = 1;
				runningProvidersCount++;
				
				[NSThread detachNewThreadSelector: @selector(providerQueueFillerThread:)
												 toTarget: self
											  withObject: [NSArray arrayWithObjects:provider, [NSNumber numberWithUnsignedInt:providerIndex], nil]];
			}
			
			[providerThreadsAvailableCondLock unlockWithCondition:(runningProvidersCount < [providers count])];
		}
	}
	@finally {
		if(pool)
			[pool release];
	}
}


- (void)providerQueueFillerThread:(id)_providerAndProviderIndex
{
	NSAutoreleasePool *pool;
	PFProviderClass* provider;
	NSArray* providerAndProviderIndex;
	NSImage* im;
	unsigned providerIndex;
	double timer;
	
	pool = [[NSAutoreleasePool alloc] init];
	timer = [PFUtil microtime];
	providerAndProviderIndex = (NSArray*)_providerAndProviderIndex;
	provider = (PFProviderClass*)[providerAndProviderIndex objectAtIndex:0];
	providerIndex = [(NSNumber*)[providerAndProviderIndex objectAtIndex:1] unsignedIntValue];
			
	@try
	{
		// Pick a random provider and request an image
		im = [provider nextImage];
		
		// Now, do we have an image or not?
		if(im)
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
		
		timer = [PFUtil microtime] - timer;
		if(timer < userDisplayInterval/2.0)
			[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:(userDisplayInterval/2.0)-timer]];
	}
	@finally
	{
		// Reset running state to false for this provider
		[providerThreadsAvailableCondLock lock];
		runningProviders[providerIndex] = 0;
		runningProvidersCount--;
		[providerThreadsAvailableCondLock unlockWithCondition:(runningProvidersCount < [providers count])];
		
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
			// Hold here if animation is stopped
			[runCond lockWhenCondition:TRUE];
			[runCond unlock];
			
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
	NSImage* image;
	double delay;
	
	// Take the next image from the image queue
	image = (NSImage*)[queue poll];
	
	// Check if queue is empty
	if(!image)
	{
		DLog(@"Image queue is depleted");
		if(!([[qcView valueForInputKey:@"statusMessageEnabled"] doubleValue] == 1.0))
			[qcView setValue: [NSNumber numberWithDouble:1.0]  forInputKey: @"statusMessageEnabled"];
		
		[qcView setValue: @"Loading images..." forInputKey: @"statusMessageText"];
	}
	else
	{
		// TODO: Fullösning -- gör avstängningsmekanismen generell och inte beroende av bild finns
		if(image && [[qcView valueForInputKey:@"statusMessageEnabled"] doubleValue] == 1.0)
		{
			[qcView setValue: [NSNumber numberWithDouble:0.0]  forInputKey: @"statusMessageEnabled"];
		}
		
		// Pass the image to QC, which will cause the bitmap data to be copied onto a
		// texture. Takes some time...
		[qcView setValue:image forInputKey:imagePortName];
		[image release];
	}
	
	
	// First time, we know the exact delay:
	if(isFirstTime)
	{
		delay = userFadeInterval;
	}
	// Following calls, we sync the delay with the rendering cycle, 
	// getting "time" from the qc-composition:
	else
	{
		double time = [[qcView valueForInputKey: @"time"] doubleValue];
		double userDisplayAndFadeInterval = userDisplayInterval + userFadeInterval;
		delay = (userDisplayAndFadeInterval - (time - (floor(time / userDisplayAndFadeInterval) * userDisplayAndFadeInterval))) + userFadeInterval;
	}
	
	
	// Switch image ports. Needs to be done every time this method is run.
	imagePortName = (imagePortName == srcImageId) ? dstImageId : srcImageId;
	
	DLog(@"Next switch will operate on '%@' in %f seconds", imagePortName, delay);
	return delay;
}



- (NSImage*) resizeImageIfNeeded:(NSImage*)im
{
	// We need to take size from rep because nsimage compensates for dpi or something
	NSImageRep* imr = [im bestRepresentationForDevice:nil];
	if(!imr)
		return im;
	NSSize outSize = [self frame].size;
	NSSize inSize = NSMakeSize([imr pixelsWide], [imr pixelsHigh]);
	
	if(inSize.width < outSize.width || inSize.height < outSize.height)
		return im;
	
	float inAs = inSize.width / inSize.height;
	float outAs = outSize.width / outSize.height;
	
	if(inAs > outAs) // in is wider than put
		outSize.width = outSize.height * inAs;
	else
		outSize.height = outSize.width / inAs;
	
	NSImage *resizedImage = [[NSImage alloc] initWithSize:outSize];
	[resizedImage lockFocus];
	[imr drawInRect:NSMakeRect(0, 0, outSize.width, outSize.height)];
	[resizedImage unlockFocus];
	
	NSImage* old = im;
	im = resizedImage;
	[old release];
	
	//DLog(@"Resized from %f x %f  ->  %f x %f", inSize.width, inSize.height, outSize.width, outSize.height);
	
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