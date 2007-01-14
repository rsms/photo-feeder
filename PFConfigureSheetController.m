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
#import "PFUtil.h"

@implementation PFConfigureSheetController


- (id)initWithWindowNibName:(NSString*)filename withReferenceToSSV:(PFScreenSaverView*)_ssv
{
	[self initWithWindowNibName:filename];
	ssv = _ssv;
	return self;
}


- (void)awakeFromNib
{
	//NSTrace(@"[%@ awakeFromNib]", self);
	[fps             setFloatValue:[PFUtil defaultFloatForKey:@"fps"]];
	[displayInterval setFloatValue:[PFUtil defaultFloatForKey:@"displayInterval"]];
	[fadeInterval    setFloatValue:[PFUtil defaultFloatForKey:@"fadeInterval"]];
}



- (IBAction) done:(id)sender
{
	DLog(@"[%@ done]", self);
	
	[[PFUtil defaults] setFloat:[fps             floatValue] forKey:@"fps"];
	[[PFUtil defaults] setFloat:[displayInterval floatValue] forKey:@"displayInterval"];
	[[PFUtil defaults] setFloat:[fadeInterval    floatValue] forKey:@"fadeInterval"];
	[[PFUtil defaults] synchronize];
	//NSTrace(@"fps: %f", [defaults floatForKey:@"rendererFPS"]);
	
	[[NSApplication sharedApplication] endSheet:[self window]];
}


- (IBAction)about:(id)sender
{
	DLog(@"[%@ about]", self);
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://trac.hunch.se/PhotoFeeder"]];
}
@end
