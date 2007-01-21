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

@interface PFUtil : NSObject {
}

/// Returns 0 on failure
+ (unsigned long) microseed;

/// Returns -1.0 on failure
+ (double) microtime;

/// Cause the current thread to sleep for random number of seconds
+ (void) randomSleep:(unsigned)min maxSeconds:(unsigned)max;

/// Generates a per-process unique identifier based on class
+ (NSString*) generateUniqueIdentifierForInstanceOfClass:(Class)cls;

+ (NSMutableDictionary*) configurationForProvider:(NSObject<PFProvider>*)provider;
+ (NSMutableDictionary*) configurationForProviderWithIdentifier:(NSString*)providerId;
+ (void) setConfiguration:(NSDictionary*)conf forProvider:(NSObject<PFProvider>*)provider;
+ (void) setConfiguration:(NSDictionary*)conf forProviderWithIdentifier:(NSString*)providerId;

/// Screeen saver defaults for PhotoFeeder
+ (NSUserDefaults*) defaults;

/// Hard-coded application defaults
+ (NSDictionary*) appDefaults;

/// Convenience method
+ (float) defaultFloatForKey:(NSString*)key;

/// Convenience method
+ (int) defaultIntForKey:(NSString*)key;

/// Convenience method
+ (id) defaultObjectForKey:(NSString*)key;

@end
