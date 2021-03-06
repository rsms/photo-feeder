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
#import "PFQueue.h"
#import "PFProvider.h"
#import "PFConfigureSheetController.h"

@interface PFController : NSObject
{
  IBOutlet NSWindow*          configureSheet;
	NSBundle*                   bundle;             // The PhotoFeeder.saver bundle
	NSMutableArray*             views;              // Active PFView's
	PFQueue*                    queue;              // Image queue
	PFConfigureSheetController* configureSheetController;       // Configure-sheet controller
	NSConditionLock*            runCond;            // TRUE when animating, FALSE when stopped
	NSSize                      largestScreenSize;  // Keep track of largest possible screen size
	
	// Providers control
	NSMutableArray*  availableProviders; // Available providers -- a collection of Class'es
	NSMutableArray*  providers;          // Provider instances
	NSMutableArray*  busyProviders;      // Providers currently in nextImage call
	NSConditionLock* providerThreadsAvailableCondLock;
	
	// Need for speed
	double           userDisplayInterval;
	short            numAnimatingViews;
}

+ (PFController*)instance;

// Accessors
- (NSBundle*) bundle;
- (PFQueue*) queue;
- (NSMutableArray*) availableProviders; // Array of Class'es
- (NSMutableArray*) activeProviders;    // Array of PFProvider*
- (NSMutableArray*) busyProviders;      // Providers currently in nextImage call. This method is not thread-safe.
- (void) setActiveProviders:(NSMutableArray*)v;

// View Registration
- (void) registerView:(PFView*)view isPreview:(BOOL)yay;
- (void) unregisterView:(PFView*)view;

// Plugins
- (void) loadPlugins;
- (void) loadProvidersFromPath:(NSString*)path;
- (void) loadProviderFromPath:(NSString*)path;
- (void) activatePlugins;
- (void) instantiateProviders;
- (PFProvider *) instantiateProviderWithIdentifier: (NSString*)identifier
                                           ofClass: (Class)providerClass
                                usingConfiguration: (NSMutableDictionary*)configuration;

// Configuration Synchronization
- (void) synchronizeProviderConfigurations;

// Notification Callbacks
- (void) providerConfigurationDidChange:(NSNotification*)notification;

// Threads
- (void) queueFillerThread:(id)obj;
- (void) providerQueueFillerThread:(id)providerInfo;

// Animation
- (void) animationStartedByView:(PFView*)view;
- (void) animationStoppedByView:(PFView*)view;
- (void) blockWhileStopped;
- (BOOL) isRunning;

// User Interface
- (NSWindow*) configureSheet;

// Utilities
- (NSImage*) resizeImageIfNeeded:(NSImage*)im;

@end
