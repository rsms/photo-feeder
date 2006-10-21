
#import <ScreenSaver/ScreenSaver.h>
#import <QuartzCore/QuartzCore.h>
#import "PFText.h"
#import "PFQueue.h"
#import "PFGLRenderer.h"
#import "PFImage.h"

@interface PFScreenSaverView : ScreenSaverView {
	PFQueue*			queue;
	NSMutableArray*		providers;
	NSConditionLock*	imageCreatorLock;
	PFText*				statusText;
	PFGLRenderer*		renderer;
	
	NSSize				screenSize;
	CIContext *			context;
	
	PFImage				frontImage;
	PFImage				backImage;
}

- (void)queueFillerThread:(id)obj;
- (void)imageCreatorThread:(id)obj;
- (PFImage)createResizedImageFromCIImage:(CIImage *)im;

@end