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

@interface PFProvider : NSObject
{
	NSString*            identifier;
	NSMutableDictionary* configuration;
}

#pragma mark -
#pragma mark Plugin methods

/// Called when loading plugin
+ (BOOL) initPluginWithBundle:(NSBundle*)theBundle;

/// Called when unloading plugin
+ (void) deallocPlugin;

/// Human-readable name of the plugin
+ (NSString*) pluginName;

/// Plugin description text, nil if none
+ (NSString*) pluginDescription;


#pragma mark -
#pragma mark Instance methods

/// Configuration UI
- (BOOL) hasConfigureSheet;
- (NSWindow*) configureSheet;

/// Provider instance configuration
-(NSDictionary*) configuration;
-(void) setConfiguration:(NSMutableDictionary*)conf;

/// Provider instance identifier
- (NSString*) identifier;
- (void) setIdentifier:(NSString*)pid;

/// Active or not
-(BOOL) active;
-(void) setActive:(BOOL)active;

/// Human-readable instance name
-(NSString*) name;
-(void) setName:(NSString*)name;

/// Human-readable name, or type, of the plugin
-(NSString*) pluginType;
//-(void) setPluginType:(Class)cls;

/// Return an Image
-(NSImage*) nextImage;


@end