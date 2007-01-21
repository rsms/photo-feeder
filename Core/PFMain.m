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

#import "PFMain.h"
#import "PFProvider.h"
#import "PFUtil.h"

NSString* const PFActiveProvidersDidChangeNotification = @"PFActiveProvidersDidChangeNotification";

@implementation PFMain



#pragma mark -
#pragma mark Singleton setup

static PFMain* instance = nil;


+ (PFMain*) instance
{
	@synchronized(self)
	{
		if (instance == nil)
		{
			[[self alloc] init]; // assignment not done here
		}
	}
	return instance;
}


+ (id) allocWithZone:(NSZone *)zone
{
	@synchronized(self)
	{
		if(instance == nil)
		{
			instance = [super allocWithZone:zone];
			return instance;  // assignment and return on first allocation
		}
	}
	return nil; //on subsequent allocation attempts return nil
}


- (id)copyWithZone:(NSZone *)zone { return self; }
- (id)retain { return self; }
- (unsigned)retainCount { return UINT_MAX; }
- (void)release {}
- (id)autorelease { return self; }


#pragma mark -
#pragma mark Instance

- (id) init
{
	DLog(@"");
	self = [super init];
	
	// Keeps track of animation views. Increased on start animation, decreased on stop.
	numAnimatingViews = 0;
	
	// Save reference to our bundle
	bundle = [NSBundle bundleForClass:[self class]];
	
	// Create the mother-queue
	queue = [[PFQueue alloc] initWithCapacity:7];
	
	// Setup available providers storage
	availableProviders = [[NSMutableArray alloc] init];
	
	// Keeps references to active views
	views = [[NSMutableArray alloc] init];
	
	// Make sure uiController is nil. Lazy cache.
	uiController = nil;
	
	// Load and activate plugins (providers, etc)
	[self loadPlugins];
	[self activatePlugins];
	
	// Index over providers running state (1=running, 0=not running)
	runningProviders = (short *)malloc(sizeof(short) * [[[PFMain instance] activeProviders] count]);
	unsigned i = [[[PFMain instance] activeProviders] count];
	while(i--)
		runningProviders[i] = 0;
	runningProvidersCount = 0; // num providers currently in private threads aquiring images
	providerThreadsAvailableCondLock = [[NSConditionLock alloc] initWithCondition:([[[PFMain instance] activeProviders] count] ? TRUE : FALSE)];
	
	// Init runCond lock as FALSE (dont run)
	// This is unlocked as TRUE by any view when it's time to start animation
	runCond = [[NSConditionLock alloc] initWithCondition:FALSE];
	
	// We keep track of largest possible screen size to be able to downscale 
	// images correctly
	largestScreenSize = [[NSScreen mainScreen] visibleFrame].size;
	
	// Start filling the queue with images from providers
	[NSThread detachNewThreadSelector: @selector(queueFillerThread:)
									 toTarget: self
								  withObject: nil];
	
	return self;
}


- (void) dealloc
{
	[providers release];
	[availableProviders release];
	[queue release];
	free(runningProviders);
	[super dealloc];
}



#pragma mark -
#pragma mark Accessors


- (NSBundle*) bundle
{
	return bundle;
}

- (PFQueue*) queue
{
	return queue;
}

- (NSMutableArray*) availableProviders
{
	return availableProviders;
}

- (NSMutableArray*) activeProviders
{
	return providers;
}

- (void) setActiveProviders:(NSMutableArray*)newProviders
{
	DLog(@"");
	NSMutableArray* old = providers;
	providers = [newProviders retain];
	if(old)
		[old release];
}



#pragma mark -
#pragma mark View Registration


- (void) registerView:(PFView*)view isPreview:(BOOL)isPreview
{
	DLog(@"view: %@  isPreview: %@", view, isPreview ? @"YES" : @"NO");
	[views addObject:view];
}


- (void) unregisterView:(PFView*)view
{
	DLog(@"view: %@", view);
	[views removeObject:view];
}



#pragma mark -
#pragma mark Plugins


- (void) loadPlugins
{
	DLog(@"");
	[self loadProvidersFromPath:[[NSBundle bundleForClass:[self class]] builtInPlugInsPath]];
	//[self loadProvidersFromPath:[@"~/Library/Application Support/PhotoFeeder/Plugins" stringByExpandingTildeInPath]];
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
	if([pluginClass initPluginWithBundle:pluginBundle])
	{
		[availableProviders addObject:pluginClass];
	}
}


- (void) activatePlugins
{
	[self activateProviders];
}


- (void) activateProviders
{
	// Setup and instantiate providers
	// TODO: Only load providers which are enabled by the user
	// TODO: Move into separate method(s)
	providers = [[NSMutableArray alloc] init];
	NSDictionary* defaultActiveProviders;
	
	if(defaultActiveProviders = (NSDictionary*)[PFUtil defaultObjectForKey:@"activeProviders"])
	{
		NSEnumerator* enumerator;
		NSString*     providerClassName;
		
		enumerator = [defaultActiveProviders keyEnumerator];
		
		while (providerClassName = [enumerator nextObject])
		{
			Class providerClass = NSClassFromString(providerClassName);
			if(!providerClass)
			{
				NSTrace(@"Unknown provider %@", providerClassName);
			}
			else
			{
				[self activateProviderOfClass: providerClass
					  lookingUpConfigurationIn: defaultActiveProviders];
			}
		}
	}
}


- (void) activateProviderOfClass:(Class)providerClass lookingUpConfigurationIn:(NSDictionary*)confDict
{
	PFProviderClass* provider;
	NSDictionary* providerConfiguration = nil;
	
	if(!confDict)
		confDict = (NSDictionary*)[PFUtil defaultObjectForKey:@"activeProviders"];
	
	if(confDict)
		providerConfiguration = (NSDictionary*)[confDict objectForKey:NSStringFromClass(providerClass)];
	
	if(!providerConfiguration) // Empty dict if none found
		providerConfiguration = [[NSDictionary alloc] init];
	
	if(provider = [[providerClass alloc] initWithConfiguration:providerConfiguration])
	{
		//DLog(@"Adding provider %@", provider);
		[providers addObject:provider];
		[[NSNotificationCenter defaultCenter] postNotificationName:PFActiveProvidersDidChangeNotification object:self];
	}
	else
		NSTrace(@"Failed to initialize instance of provider '%@'", NSStringFromClass(providerClass));
}



#pragma mark -
#pragma mark Threads

// Keeps filling the queue with images
- (void) queueFillerThread:(id)obj
{
	NSAutoreleasePool *pool;
	PFProviderClass* provider;
	unsigned providerIndex, providerCount, altProviderIndexCountdown;
	
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
			
			// Hold if count < 1
			if(!providerCount)
			{
				NSTrace(@"ERROR: No providers loaded. Sleeping forever...");
				[NSThread sleepUntilDate:[NSDate distantFuture]];
			}
			
			// Get a non-running provider index
			providerIndex = SSRandomIntBetween(0, [providers count]-1);
			altProviderIndexCountdown = providerCount;
			while(runningProviders[providerIndex] || ![(NSObject<PFProvider>*)[providers objectAtIndex:providerIndex] active])
			{
				if(++providerIndex == providerCount)
					providerIndex = 0;
				
				// Needed for avoiding deadlock
				if(!--altProviderIndexCountdown)
				{
					providerIndex = -1;
					break;
				}
			}
			
			
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
			
			if(providerIndex == -1)
				[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
		}
	}
	@finally {
		if(pool)
			[pool release];
	}
}


// Triggered by queueFillerThread to aquire image(s) from a specified provider
- (void) providerQueueFillerThread:(id)_providerAndProviderIndex
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
		
		// Sleep a short while if needed, so one fast provider doesn't fill up the queue
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



#pragma mark -
#pragma mark Animation


- (void) animationStartedByView:(PFView*)view
{
	DLog(@"view: %@", view);
	
	// Update from defaults
	// This is used frequently by providerQueueFillerThread and therefore cached
	userDisplayInterval = [PFUtil defaultFloatForKey:@"displayInterval"];
	
	// Update largest screen
	NSSize frameSize = [view frame].size;
	if(frameSize.width > largestScreenSize.width)
		largestScreenSize.width = frameSize.width;
	if(frameSize.height > largestScreenSize.height)
		largestScreenSize.height = frameSize.height;
	
	numAnimatingViews++;
	//DLog(@"numAnimatingViews: %d", numAnimatingViews);
	if(numAnimatingViews)
	{
		[runCond lock];
		[runCond unlockWithCondition:TRUE];
	}
}


- (void) animationStoppedByView:(PFView*)view
{
	DLog(@"view: %@", view);
	//DLog(@"numAnimatingViews: %d", numAnimatingViews);
	
	if(--numAnimatingViews < 1)
	{
		[runCond lock];
		[runCond unlockWithCondition:FALSE];
	}
}


- (void) blockWhileStopped
{
	[runCond lockWhenCondition:TRUE];
	[runCond unlock];
}


- (BOOL) isRunning
{
	return [runCond condition];
}


- (void) renderingParametersDidChange
{
	DLog(@"views: %@", views);
	// TODO: Replace this whole chain with notifications using NSNotificationCenter
	NSEnumerator *en = [views objectEnumerator];
	PFView* o;
	while(o = (PFView*)[en nextObject])
	{
		[o renderingParametersDidChange];
	}
}


#pragma mark -
#pragma mark User Interface


- (NSWindow*) configureSheet
{
	DLog(@"");
	if(!uiController)
		uiController = [[PFUIController alloc] initWithWindowNibName:@"ConfigureSheet"];
	
	NSWindow* win = [uiController window];
	if(win == nil)
		NSTrace(@"ERROR: [uiController window] == nil");
	
	return win;
}



#pragma mark -
#pragma mark Utilities


// Downsizes a image which is larger than needed (this speeds things up with very large images)
- (NSImage*) resizeImageIfNeeded:(NSImage*)im
{
	// We need to take size from rep because nsimage compensates for dpi or something
	NSImageRep* imr = [im bestRepresentationForDevice:nil];
	if(!imr)
		return im;
	
	NSSize outSize = largestScreenSize; // copy
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


@end
