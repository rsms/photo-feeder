#import "TestAppController.h"

@implementation TestAppController

-(void)awakeFromNib
{
	ssv = [[PFScreenSaverView alloc] initWithFrame:[win frame] isPreview:NO];
	[win setContentView:ssv];
	[ssv startAnimation];
}

-(void)toggleAnimation:(id)sender
{
	if([ssv isAnimating])
		[ssv stopAnimation];
	else
		[ssv startAnimation];
}

- (void)windowWillClose:(NSNotification *)aNotification
{
	[ssv stopAnimation];
	[ssv removeFromSuperview];
	[ssv release];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	return YES;
}

@end
