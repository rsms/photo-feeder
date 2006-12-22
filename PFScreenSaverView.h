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
	NSMutableArray*		providers;
	QCView*					qcView;
	
	NSImage*					sourceImage; // back
	NSImage*					destinationImage; // front
	
	id							configureSheetController;
	
	BOOL						animationIsInitialized;
	double					animationInterval;            // 1.0/FPS
	double               animationTime;                // Current time in animation sequence
	double					userFadeInterval;            // User-defined transition interval
	double					userDisplayInterval;         // User-defined display interval -- how long the image is displayed, not counting transitions
	double					transitionAndDisplayInterval; // Total time an image is visible on the screen
}

- (void) queueFillerThread:(id)obj;
- (void) switchImage:(NSString*)imagePortName;

@end
