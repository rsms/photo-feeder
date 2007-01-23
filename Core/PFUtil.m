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

@implementation PFUtil


static NSMutableDictionary* uniqueIdentifiersDictKeyedByClass = nil;


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
	unsigned long s = (random() % (max-min)) + min;
	if(!s)
		return;
	DLog(@"Sleeping for %lu seconds...", s);
	[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:s]];
}


+ (NSString*) providerIdFromProvider:(NSObject<PFProvider>*)provider
{
	// TODO: Fix this -- class name is not unique per instance ;)
	return NSStringFromClass([provider class]);
}


+ (NSString*) generateUniqueIdentifierForInstanceOfClass:(Class)cls
{
	if(!uniqueIdentifiersDictKeyedByClass)
		uniqueIdentifiersDictKeyedByClass = [[NSMutableDictionary alloc] init];
	
	NSString* className = NSStringFromClass(cls);
	NSNumber* nextNumObj;
	int nextNum = 0;
	
	@synchronized(uniqueIdentifiersDictKeyedByClass)
	{
		if(nextNumObj = [uniqueIdentifiersDictKeyedByClass objectForKey:className])
			nextNum = [nextNumObj intValue];
		[uniqueIdentifiersDictKeyedByClass setObject:[[NSNumber alloc] initWithInt:nextNum+1] forKey:className];
	}
	
	return [NSString stringWithFormat:@"%@#%d", className, nextNum];
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


+ (NSMutableDictionary*) configurationForProvider:(NSObject<PFProvider>*)provider
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
		{
			if(providerDefinitionDict = [activeProvidersDict objectForKey:providerId])
			{
				if(providerConfiguration = [providerDefinitionDict objectForKey:@"configuration"])
				{
					NSMutableDictionary* mutableProviderConfiguration = [providerConfiguration mutableCopy];
					[providerConfiguration release];
					return mutableProviderConfiguration;
				}
			}
		}
	}
	
	return [[NSMutableDictionary alloc] init];
}


+ (void) setConfiguration:(NSDictionary*)conf forProvider:(NSObject<PFProvider>*)provider
{
	[PFUtil setConfiguration:conf forProviderWithIdentifier:[provider identifier]];
}


+ (void) setConfiguration:(NSDictionary*)conf forProviderWithIdentifier:(NSString*)providerId
{
	NSMutableDictionary* activeProvidersDict;
	NSMutableDictionary* providerDefinitionDict;
	
	@synchronized([PFUtil defaults])
	{
		
		if(!(activeProvidersDict = [PFUtil defaultObjectForKey:@"activeProviders"]))
			activeProvidersDict = [[NSMutableDictionary alloc] init];
		else
			activeProvidersDict = [activeProvidersDict mutableCopy];
		
		
		if(!(providerDefinitionDict = [activeProvidersDict objectForKey:providerId]))
			providerDefinitionDict = [[NSMutableDictionary alloc] init];
		else
			providerDefinitionDict = [providerDefinitionDict mutableCopy];
		
		
		NSTrace(@"TODO: Fix problem with immutable vs mutable dicts which are to be saved. Config saving is disabled.");
		//[providerDefinitionDict setObject:conf forKey:@"configuration"];
		//[activeProvidersDict setObject:providerDefinitionDict forKey:providerId];
		//[[PFUtil defaults] setObject:activeProvidersDict forKey:@"activeProviders"];
	}
}



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
						[NSNumber numberWithBool:YES], @"active",
						@"Images in ~/Pictures/_temp", @"name",
						@"~/Pictures/_temp",           @"path",
					nil],
					@"configuration",
				nil],
				@"PFDiskProvider#-1",
			nil];
		
		// Application defaults
		appDefaults = [[NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt:60],     @"fps",
			[NSNumber numberWithFloat:3.0],  @"displayInterval",
			[NSNumber numberWithFloat:1.0],  @"fadeInterval",
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
