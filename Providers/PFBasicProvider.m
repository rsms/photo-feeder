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


- (void) dealloc
{
	if(identifier)
		[identifier release];
	if(configuration)
		[configuration release];
	[super dealloc];
}


-(NSDictionary*) configuration
{
	return configuration;
}


-(void) setConfiguration:(NSMutableDictionary*)conf
{
	NSMutableDictionary* old = configuration;
	configuration = [conf retain];
	if(old)
		[old release];
	
	if(![configuration objectForKey:@"active"])
		[configuration setObject:[NSNumber numberWithBool:YES] forKey:@"active"];
	
	if(![configuration objectForKey:@"name"])
		[configuration setObject:[[self class] pluginName] forKey:@"name"];
	
	[self notifyOnConfigurationUpdate];
}


- (NSString*) identifier
{
	return identifier;
}


- (void) setIdentifier:(NSString*)pid
{
	NSString* old = identifier;
	identifier = [pid retain];
	if(old)
		[old release];
}


-(BOOL) active
{
	return [[configuration objectForKey:@"active"] boolValue];
}


-(void) setActive:(BOOL)b
{
	[configuration setObject:[NSNumber numberWithBool:b] forKey:@"active"];
	[self notifyOnConfigurationUpdate];
}


-(NSString*) name
{
	return [configuration objectForKey:@"name"];
}


-(void) setName:(NSString*)name
{
	[configuration setObject:name forKey:@"name"];
	[self notifyOnConfigurationUpdate];
}


- (void) notifyOnConfigurationUpdate
{
	// Notify observers about the config update
	[[NSNotificationCenter defaultCenter] postNotificationName: @"PFProviderConfigurationDidChangeNotification"
																		 object: self];
}


-(NSImage*)nextImage
{
	return nil;
}

@end
