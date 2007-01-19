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
#import "../Core/PFMain.h"
#import "../Core/version.h"

@implementation PFUIController


- (void)awakeFromNib
{
	DLog(@"");
}


-(int) fps
{
	DLog(@"");
	return [PFUtil defaultIntForKey:@"fps"];
}

-(void) setFps:(int)d
{
	DLog(@"%d", d);
	[[PFUtil defaults] setInteger:d forKey:@"fps"];
	[[PFMain instance] renderingParametersDidChange];
}


-(float) displayInterval
{
	DLog(@"");
	return [PFUtil defaultIntForKey:@"displayInterval"];
}

-(void) setDisplayInterval:(float)f
{
	DLog(@"%f", f);
	[[PFUtil defaults] setInteger:f forKey:@"displayInterval"];
	[[PFMain instance] renderingParametersDidChange];
}


-(float) fadeInterval
{
	DLog(@"");
	return [PFUtil defaultIntForKey:@"fadeInterval"];
}

-(void) setFadeInterval:(float)f
{
	DLog(@"%f", f);
	[[PFUtil defaults] setInteger:f forKey:@"fadeInterval"];
	[[PFMain instance] renderingParametersDidChange];
}


- (NSMutableArray *) activeProviders
{
	DLog(@"");
	return [[PFMain instance] providers];
}


- (void) setActiveProviders:(NSArray *)v
{
	DLog(@"TODO");
	[[PFMain instance] renderingParametersDidChange];
}


- (int) appRevision
{
	return PF_REVISION;
}


- (NSString*) buildDate
{
	return [[NSDate dateWithTimeIntervalSince1970:PF_BUILD_TIMESTAMP] description];
}


- (IBAction) done:(id)sender
{
	DLog(@"");
	[[PFUtil defaults] synchronize];
	[NSApp endSheet:[self window]];
}


- (IBAction)about:(id)sender
{
	DLog(@"");
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://trac.hunch.se/PhotoFeeder"]];
}
@end
