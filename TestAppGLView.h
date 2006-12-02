
#import "PFGLImage.h"

@interface TestAppGLView : NSOpenGLView
{
	PFGLImage *image;
	NSString  *lastFilePathOpened;
}

- (void) setImage:(PFGLImage*)im;
- (IBAction) openFile:(id)sender;
- (IBAction) toggleFullscreen:(id)sender;

@end
