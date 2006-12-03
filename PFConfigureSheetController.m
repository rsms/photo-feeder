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
	return self;
}


- (IBAction)done:(id)sender
{
	DLog(@"[%@ done]", self);
	
	// tag 0 = OK, tag 1 = cancel
	/*if([(NSButton*)sender tag] == 0)
	{
		[[StarryView defaults] setInteger:[starsSlider intValue] forKey:@"numStars"];
		[[StarryView defaults] setFloat:[sizeSlider floatValue] forKey:@"starSize"];
		[[StarryView defaults] setInteger:[saturationSlider intValue] forKey:@"colorSaturation"];
		[[StarryView defaults] setInteger:[fpsSlider intValue] forKey:@"fps"];
	}
	else {
		[self loadSavedStates];
	}*/
	[[NSApplication sharedApplication] endSheet:[self window]];
}


- (IBAction)about:(id)sender
{
	DLog(@"[%@ about]", self);
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://trac.hunch.se/PhotoFeeder"]];
}


- (void)awakeFromNib
{
	DLog(@"[%@ awakeFromNib]", self);
	//[self loadSavedStates];
}

@end
