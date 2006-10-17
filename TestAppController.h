#import "PFScreenSaverView.h"

@interface TestAppController : NSObject
{
    IBOutlet NSView *view;
	PFScreenSaverView* ssv;
}

-(void)toggleAnimation:(id)sender;

@end
