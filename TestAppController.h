#import "PFScreenSaverView.h"

@interface TestAppController : NSObject
{
    IBOutlet NSWindow *win;
	PFScreenSaverView* ssv;
}

-(void)toggleAnimation:(id)sender;

@end
