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
#import "PFDiskProvider.h"


@implementation PFDiskProvider

- (id) initWithPathToDirectory:(NSString*)d
{
	dir = [d retain];
	dirEnum = [[[NSFileManager defaultManager] enumeratorAtPath:dir] retain];
	return self;
}


-(NSImage*)nextImage
{
	NSString* file;
	NSArray* acceptExts = [PFProvider acceptableFileExtensions];
	
	while( file = [dirEnum nextObject] )
	{
		if( [acceptExts containsObject:[file pathExtension]] )
		{
			DLog(@"%@", file);
			return [[NSImage alloc] initWithContentsOfFile:[dir stringByAppendingPathComponent:file]];
		}
	}
	
	return nil;
}

@end
