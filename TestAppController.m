#import "TestAppController.h"

@implementation TestAppController

-(void)awakeFromNib
{
	ssv = [[PFScreenSaverView alloc] initWithFrame:[view bounds] isPreview:NO];
	[view addSubview:ssv];
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
