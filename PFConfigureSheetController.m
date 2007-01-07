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
#import "PFConfigureSheetController.h"

@implementation PFConfigureSheetController


- (id)initWithWindowNibName:(NSString*)filename withReferenceToSSV:(PFScreenSaverView*)_ssv
{
	[self initWithWindowNibName:filename];
	ssv = _ssv;
	defaults = [ScreenSaverDefaults defaultsForModuleWithName:@"com.flajm.PhotoFeeder"];
	return self;
}


- (void)awakeFromNib
{
	//NSTrace(@"[%@ awakeFromNib]", self);
	[fps setFloatValue:[defaults floatForKey:@"rendererFPS"]];
}



- (IBAction) done:(id)sender
{
	DLog(@"[%@ done]", self);
	
	[defaults setFloat:[fps floatValue] forKey:@"rendererFPS"];
	[defaults synchronize];
	//NSTrace(@"fps: %f", [defaults floatForKey:@"rendererFPS"]);
	
	[[NSApplication sharedApplication] endSheet:[self window]];
}


- (IBAction)about:(id)sender
{
	DLog(@"[%@ about]", self);
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://trac.hunch.se/PhotoFeeder"]];
}
@end
