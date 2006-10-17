
#import <ScreenSaver/ScreenSaver.h>
#import "PFText.h"
#import "PFQueue.h"

/*typedef struct {
	NSImage *image;
	NSSize size;
	float cropWidth;
	float cropHeight;
	float ratio;
	BOOL  isWider;
	float resizeFactor;
} PFImageContainer;

static PFImageContainer PFMakeImageContainer(NSImage* im, NSSize screenSize);
static void PFFreeImageContainer(PFImageContainer ic);*/

@interface PFScreenSaverView : ScreenSaverView {
	PFQueue*			queue;
	NSMutableArray*		providers;
	NSConditionLock*	imageCreatorLock;
	PFText*				statusText;
	float				frameRatio;
	NSPoint				cropPosition;
	NSRect              myFrame;			// Cached [self frame]
	
	NSImage*	nextImage;
	NSImage*	currentImage;
	NSSize		currImSize;
	float		currImCropWidth;
	float		currImCropHeight;
	float		currImRatio;
	BOOL		currImIsWider;
	float		currImResizeFactor;
}

- (void)queueFillerThread:(id)obj;
- (void)imageCreatorThread:(id)obj;

@end
