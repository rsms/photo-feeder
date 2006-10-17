
#import <ScreenSaver/ScreenSaver.h>
#import "PFText.h"
#import "PFQueue.h"

@interface PFScreenSaverView : ScreenSaverView {
	PFQueue*			queue;
	NSImage*			currentImage;
	NSImage*			nextImage;
	NSMutableArray*		providers;
	NSConditionLock*	imageCreatorLock;
	PFText*				statusText;
	float				frameRatio;
	NSPoint				cropPosition;
	NSRect              myFrame;			// Cached [self frame]
}

- (void)queueFillerThread:(id)obj;
- (void)imageCreatorThread:(id)obj;

@end
