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
#import "PFUIController.h"
#import "../Core/PFUtil.h"

@implementation PFUIController


- (void)awakeFromNib
{
	DLog(@"");
	
	[fps             setFloatValue:[PFUtil defaultFloatForKey:@"fps"]];
	[displayInterval setFloatValue:[PFUtil defaultFloatForKey:@"displayInterval"]];
	[fadeInterval    setFloatValue:[PFUtil defaultFloatForKey:@"fadeInterval"]];
	
	// Load table of active providers
	// TODO: load config about active providers
	//NSDictionary* activeProviders = [PFUtil defaultDictForKey:@"activeProviders"];
	//activeProvidersDS = [[PFActiveProvidersTableViewDataSource alloc] initWithDefaults:nil];
	//[activeProvidersTable setDataSource:activeProvidersDS];
}



- (IBAction) done:(id)sender
{
	DLog(@"");
	
	NSUserDefaults* defaults = [PFUtil defaults];
	
	[defaults setFloat:[fps             floatValue] forKey:@"fps"];
	[defaults setFloat:[displayInterval floatValue] forKey:@"displayInterval"];
	[defaults setFloat:[fadeInterval    floatValue] forKey:@"fadeInterval"];
	[defaults synchronize];
	//NSTrace(@"fps: %f", [defaults floatForKey:@"rendererFPS"]);
	
	[NSApp endSheet:[self window]];
}


- (IBAction)about:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://trac.hunch.se/PhotoFeeder"]];
}
@end
