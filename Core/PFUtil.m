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


+ (NSUserDefaults*) defaults
{
	return [ScreenSaverDefaults defaultsForModuleWithName:@"com.flajm.PhotoFeeder"];
}



static NSDictionary* appDefaults = nil;


+ (NSDictionary*) appDefaults
{
	// Lazy initializer
	if(!appDefaults)
	{
		appDefaults = [[NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt:60],     @"fps",
			[NSNumber numberWithFloat:3.0],  @"displayInterval",
			[NSNumber numberWithFloat:1.0],  @"fadeInterval",
			[NSDictionary dictionary],       @"activeProviders",
			nil] retain];
	}
	return appDefaults;
}


+ (float) defaultFloatForKey:(NSString*)key
{
	NSNumber* n = [[PFUtil defaults] objectForKey:key];
	
	if(!n)
		n = [[PFUtil appDefaults] objectForKey:key];
	
	if(n)
		return [n floatValue];
	
	return 0.0;
}


+ (int) defaultIntForKey:(NSString*)key
{
	NSNumber* n = [[PFUtil defaults] objectForKey:key];
	
	if(!n)
		n = [[PFUtil appDefaults] objectForKey:key];
	
	if(n)
		return [n intValue];
	
	return 0.0;
}


+ (NSObject*) defaultObjectForKey:(NSString*)key
{
	NSObject* o = [[PFUtil defaults] objectForKey:key];
	
	if(!o)
		o = [[PFUtil appDefaults] objectForKey:key];
	
	return o;
}

@end
