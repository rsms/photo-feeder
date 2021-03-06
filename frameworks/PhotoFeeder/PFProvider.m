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

#import "PFProvider.h"

@implementation PFProvider


#pragma mark -
#pragma mark Plugin methods

+ (BOOL) initPluginWithBundle:(NSBundle*)theBundle {
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


- (BOOL)hasConfigureSheet
{
  return NO;
}


- (NSWindow*) configureSheet
{
  return nil;
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
}


-(NSString*) name
{
  return [configuration objectForKey:@"name"];
}


-(void) setName:(NSString*)name
{
  [configuration setObject:name forKey:@"name"];
}


-(NSString*) pluginType
{
  return [[self class] pluginName];
}


-(NSImage*)nextImage
{
  return nil;
}

@end
