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
#import <ScreenSaver/ScreenSaver.h>
#import <Quartz/Quartz.h>
#import "PFQueue.h"

@interface PFScreenSaverView : ScreenSaverView {
	PFQueue*					queue;
	NSMutableArray*		availableProviders;
	NSMutableArray*		providers;
	QCView*					qcView;
	NSThread*            switchImageDispatchT;
	NSConditionLock*     runCond;
	
	short*               runningProviders; // map over all providers run state
	unsigned             runningProvidersCount;
	NSConditionLock*     providerThreadsAvailableCondLock;
	
	NSImage*					sourceImage; // back
	NSImage*					destinationImage; // front
	
	id							configureSheetController;
	
	NSString*            imagePortName;
	
	double					userFadeInterval;            // User-defined transition interval
	double					userDisplayInterval;         // User-defined display interval -- how long the image is displayed, not counting transitions
	double               userFps;
}

- (void) queueFillerThread:(id)obj;
- (void)providerQueueFillerThread:(id)_providerAndProviderIndex;
- (double) switchImage:(NSObject*)isFirstTime;
- (NSImage*) resizeImageIfNeeded:(NSImage*)im;

#pragma mark -- Plugins
- (void) loadPlugins;
- (void) loadProvidersFromPath:(NSString*)path;
- (void) loadProviderFromPath:(NSString*)path;

@end
