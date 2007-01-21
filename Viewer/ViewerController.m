/*
 * PhotoFeeder is the legal property of its developers.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version. You should have received a copy 
 * of the GNU General Public License along with this program; if not, 
 * write to the Free Software Foundation, Inc., 59 Temple Place, 
 * Suite 330, Boston, MA 02111-1307 USA
 */
#import "ViewerController.h"
#import "PFMain.h"

@implementation ViewerController


-(void)awakeFromNib
{
	ssv = [[PFView alloc] initWithFrame:[win frame] isPreview:NO];
	[win setContentView:ssv];
	[ssv startAnimation];
}


- (IBAction) showConfigureSheet:(id)sender
{
	DLog(@"");
	NSWindow* confWin;
	
	if(confWin = [[PFMain instance] configureSheet])
	{
		[NSApp beginSheet: confWin
			modalForWindow: win
			 modalDelegate: self
			didEndSelector: @selector(didEndSheet:returnCode:contextInfo:)
				contextInfo: nil];
	}
	// Sheet is up. Return processing to the event loop
}


- (IBAction) done:(id)sender
{
	DLog(@"[%@ done]", self);
}


- (IBAction)closeConfigureSheet:(id)sender
{
	[NSApp endSheet:configureSheet];
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


- (void)didEndSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	[sheet orderOut:self];
}


- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	return YES;
}


@end
