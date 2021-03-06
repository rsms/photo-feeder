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

#import "PFUtil.h"
#import <ScreenSaver/ScreenSaverDefaults.h>
#import <ScreenSaver/ScreenSaverView.h>

@implementation PFUtil


+ (unsigned long) microseed
{
  struct timeval tp;
  if(gettimeofday(&tp, NULL) == 0)
    return tp.tv_usec + tp.tv_sec;
  return 0;
}


+ (double) microtime
{
  struct timeval tp;
  if(gettimeofday(&tp, NULL) == 0)
    return (double)(((double)tp.tv_usec) / 1000000.0) + tp.tv_sec;
  return -1.0;
}


+ (void) randomSleep:(unsigned)min maxSeconds:(unsigned)max
{
  srandom([PFUtil microseed]);
  float s = SSRandomFloatBetween(min, max);
  if(!s) // if 0, no need to sleep
    return;
  //DLog(@"Sleeping for %f seconds...", s);
  [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:s]];
}


+ (NSString*) providerIdFromProvider:(PFProvider *)provider
{
  // TODO: Fix this -- class name is not unique per instance ;)
  return NSStringFromClass([provider class]);
}


+ (NSString*) generateUID
{
  struct timeval tp;
  
  if(gettimeofday(&tp, NULL) == 0)
  {
    srandom(tp.tv_sec);
    return [NSString stringWithFormat:@"%x-%x-%x",
            tp.tv_usec, tp.tv_sec, SSRandomIntBetween(100, LONG_MAX)];
  }
  
  return nil;
}


#pragma mark -
#pragma mark Provider Configuration


/*
 LAYOUT:
 
 "activeProviders" => NSArray:
 "id" => NSDict:
 "class" => "MyClass"
 "configuration" => NSDict:
 "active" => YES
 "name" => "My provider"
 "something" => "Bobobob"
 
 */


+ (NSMutableDictionary*) configurationForProvider:(PFProvider *)provider
{
  return [PFUtil configurationForProviderWithIdentifier:[provider identifier]];
}


+ (NSMutableDictionary*) configurationForProviderWithIdentifier:(NSString*)providerId
{
  NSDictionary* activeProvidersDict;
  NSDictionary* providerDefinitionDict;
  NSDictionary* providerConfiguration;
  
  @synchronized([PFUtil defaults])
  {
    if(activeProvidersDict = [PFUtil defaultObjectForKey:@"activeProviders"])
      if(providerDefinitionDict = [activeProvidersDict objectForKey:providerId])
        if(providerConfiguration = [providerDefinitionDict objectForKey:@"configuration"])
          return [[providerConfiguration mutableCopy] autorelease];
  }
  
  return [[[NSMutableDictionary alloc] init] autorelease];
}


/*+ (void) setConfiguration:(NSDictionary*)conf forProvider:(PFProvider *)provider
 {
 NSMutableDictionary* activeProvidersDict;
 NSMutableDictionary* providerDefinitionDict;
 
 @synchronized([PFUtil defaults])
 {
 // If there is saved active providers, convert dict to mutable. If not, create a new dict.
 activeProvidersDict = (activeProvidersDict = [PFUtil defaultObjectForKey:@"activeProviders"]) ?
 [activeProvidersDict mutableCopy] : [[NSMutableDictionary alloc] init];
 
 providerDefinitionDict = [[NSMutableDictionary alloc] init];
 
 [providerDefinitionDict setObject: [provider className]  forKey: @"class"];
 [providerDefinitionDict setObject: conf                  forKey: @"configuration"];
 
 [activeProvidersDict setObject: providerDefinitionDict   forKey: [provider identifier]];
 [providerDefinitionDict release];
 
 [[PFUtil defaults] setObject: activeProvidersDict        forKey: @"activeProviders"];
 [activeProvidersDict release];
 }
 }*/



#pragma mark -
#pragma mark Defaults


static NSDictionary* appDefaults = nil;


+ (NSUserDefaults*) defaults
{
  return [ScreenSaverDefaults defaultsForModuleWithName:@"com.flajm.PhotoFeeder"];
}


+ (NSDictionary*) appDefaults
{
  // Lazy initializer
  if(!appDefaults)
  {
    // Default activated providers
    NSDictionary* defaultActiveProviders = 
    [NSDictionary dictionaryWithObjectsAndKeys:
     [NSDictionary dictionaryWithObjectsAndKeys:
      @"PFDiskProvider", @"class",
      [NSDictionary dictionaryWithObjectsAndKeys:
       [NSNumber numberWithBool:YES],   @"active",
       @"Images in my Pictures folder", @"name",
       @"~/Pictures",                   @"path",
       nil],
      @"configuration",
      nil],
     @"787f7-45b684e7-4e413064",
     nil];
    
    // Application defaults
    appDefaults = [[NSDictionary dictionaryWithObjectsAndKeys:
                    [NSNumber numberWithInt:60],     @"fps",
                    [NSNumber numberWithFloat:5.0],  @"displayInterval",
                    [NSNumber numberWithFloat:3.0],  @"fadeInterval",
                    defaultActiveProviders,          @"activeProviders",
                    nil] retain];
  }
  return appDefaults;
}


+ (float) defaultFloatForKey:(NSString*)key
{
  NSNumber* n;
  if(!(n = [[PFUtil defaults] objectForKey:key]))
    n = [[PFUtil appDefaults] objectForKey:key];
  return n ? [n floatValue] : 0.0;
}


+ (int) defaultIntForKey:(NSString*)key
{
  NSNumber* n;
  if(!(n = [[PFUtil defaults] objectForKey:key]))
    n = [[PFUtil appDefaults] objectForKey:key];
  return n ? [n intValue] : 0;
}


+ (id) defaultObjectForKey:(NSString*)key
{
  NSObject* o;
  if(!(o = [[PFUtil defaults] objectForKey:key]))
    o = [[PFUtil appDefaults] objectForKey:key];
  return o;
}

@end
