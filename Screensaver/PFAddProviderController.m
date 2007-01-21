#import "PFAddProviderController.h"

@implementation PFAddProviderController

- (void)windowWillClose:(NSNotification *)aNotification
{
	[NSApp stopModal];
}

@end
