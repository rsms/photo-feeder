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
#import "PFQueue.h"
#import "PFUIController.h"

@interface PFMain : NSObject
{
	NSBundle*        bundle;             // The PhotoFeeder.saver bundle
	NSMutableArray*  views;              // Active PFScreenSaverView's
	PFQueue*         queue;              // Image queue
	NSMutableArray*  availableProviders; // Available providers -- a collection of Class'es
	NSMutableArray*  providers;          // Active providers
	PFUIController*  uiController;       // Configure-sheet controller
	NSConditionLock* runCond;            // TRUE when animating, FALSE when stopped
	NSSize           largestScreenSize;  // Keep track of largest possible screen size
	
	
	// Running providers control
	short*           runningProviders; // map over all providers run state
	unsigned         runningProvidersCount;
	NSConditionLock* providerThreadsAvailableCondLock;
	
	// Need for speed
	double           userDisplayInterval;
	short            numAnimatingViews;
}

+ (PFMain*)instance;

// Accessors
- (NSBundle*) bundle;
- (PFQueue*) queue;
- (NSMutableArray*) providers;

// View Registration
- (void) registerView:(PFScreenSaverView*)view isPreview:(BOOL)yay;
- (void) unregisterView:(PFScreenSaverView*)view;

// Plugins
- (void) loadPlugins;
- (void) loadProvidersFromPath:(NSString*)path;
- (void) loadProviderFromPath:(NSString*)path;

// Threads
- (void) queueFillerThread:(id)obj;
- (void) providerQueueFillerThread:(id)providerInfo;

// Animation
- (void) animationStartedByView:(PFScreenSaverView*)view;
- (void) animationStoppedByView:(PFScreenSaverView*)view;
- (void) blockWhileStopped;
- (BOOL) isRunning;
- (void) renderingParametersDidChange;

// User Interface
- (NSWindow*) configureSheet;

// Utilities
- (NSImage*) resizeImageIfNeeded:(NSImage*)im;

@end
