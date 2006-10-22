
#import "PFScreenSaverView.h"

@interface PFConfigureSheetController : NSWindowController
{
	PFScreenSaverView* ssv;
}

- (id)initWithWindowNibName:(NSString*)filename withReferenceToSSV:(PFScreenSaverView*)ssv;

- (IBAction)done:(id)sender;
- (IBAction)about:(id)sender;
//- (void)loadSavedStates;

@end
