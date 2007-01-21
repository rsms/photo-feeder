/**
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

@protocol PFProvider

/// Called when loading plugin
+ (BOOL) initPluginWithBundle:(NSBundle*)theBundle;

/// Called when unloading plugin
+ (void) deallocPlugin;

/// Human-readable name of the plugin
+ (NSString*) pluginName;

/// Plugin description text
+ (NSString*) pluginDescription;

/// Configuration UI, nil if none
+ (NSWindow*) configureSheet;

/// Initializer
- (id) initWithConfiguration:(NSDictionary*)conf;

/// Return an Image
-(NSImage*) nextImage;

/// Active or not
-(BOOL) active;
-(void) setActive:(BOOL)active;

/// Instance name
-(NSString*) name;
-(void) setName:(NSString*)name;


@end

/// Convenience type
typedef NSObject<PFProvider> PFProviderClass;
