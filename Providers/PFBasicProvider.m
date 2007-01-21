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

#import "PFBasicProvider.h"

@implementation PFBasicProvider


#pragma mark -
#pragma mark Plugin methods

+ (BOOL) initPluginWithBundle:(NSBundle*)theBundle
{
	return YES;
}


+ (void) deallocPlugin
{
}


+ (NSString*) pluginName
{
	return NSStringFromClass(self);
}


+ (NSString*) pluginDescription
{
	return nil;
}


+ (NSWindow*) configureSheet
{
	return nil;
}


#pragma mark -
#pragma mark Instance methods

- (id) initWithConfiguration:(NSDictionary*)conf
{
	NSNumber* activeSetting;
	NSString* customName;
	
	if(activeSetting = [conf objectForKey:@"active"])
		[self setActive:[activeSetting boolValue]];
	else
		[self setActive:YES];
	
	if(customName = [conf objectForKey:@"name"])
		[self setName:customName];
	else
		[self setName:[[self class] pluginName]];
	
	return self;
}


- (void) dealloc
{
	if(name)
		[name release];
	[super dealloc];
}


-(BOOL) active
{
	return active;
}


-(void) setActive:(BOOL)b
{
	active = b;
}


-(NSString*) name
{
	return name;
}


-(void) setName:(NSString*)s
{
	NSString* old = name;
	name = [s retain];
	if(old)
		[old release];
}


-(NSImage*)nextImage
{
	return nil;
}

@end
