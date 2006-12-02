
#import "PFGLImage.h"

@interface TestAppGLView : NSOpenGLView
{
	PFGLImage* image;
}

- (void) setImage:(PFGLImage*)im;
- (IBAction) openFile:(id)sender;
- (IBAction) toggleFullscreen:(id)sender;

@end
