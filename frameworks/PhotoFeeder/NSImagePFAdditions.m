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

#import "NSImagePFAdditions.h"


@implementation NSImage (NSImagePFAdditions)

// Returns an image from the owners bundle with the specified name
+ (NSImage *)imageNamed:(NSString *)name forClass:(Class)inClass
{
	NSBundle	*ownerBundle;
	NSString	*imagePath;
	NSImage		*image;
	
	//Get the bundle
	ownerBundle = [NSBundle bundleForClass:inClass];
	
	//Open the image
	imagePath = [ownerBundle pathForImageResource:name];    
	image = [[NSImage alloc] initWithContentsOfFile:imagePath];
	
	return [image autorelease];
}

@end