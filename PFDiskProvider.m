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
	files = nil;
	return self;
}

- (void) dealloc
{
	if(files)
		[files release];
	if(dir)
		[dir release];
	[super dealloc];
}


- (void) scrambleFiles
{
	NSDirectoryEnumerator* dirEnum;
	NSArray* acceptExts;
	NSMutableArray* filesTemp;
	NSString* file;
	
	filesTemp = [NSMutableArray array]; // autoreleased
	acceptExts = [PFProvider acceptableFileExtensions];
	dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:dir];
	
	while( file = [dirEnum nextObject] )
		if( [acceptExts containsObject:[[file pathExtension] lowercaseString]] )
			[filesTemp addObject:file];
	
	files = [[filesTemp randomCopy] retain];
	filesIndex = [files count]-1;
}


-(NSImage*)nextImage
{
	// TEST latency
	//[PFUtil randomSleep:0 maxSeconds:7];
	
	// Dig dir on first call
	if(!files)
		[self scrambleFiles];
	
	// We know the files array is empty
	if(filesIndex == -1)
		return nil;
	
	NSString* file;
	NSImage* im;
	
	// Take last
	file = [files objectAtIndex:filesIndex--];
	im = [[NSImage alloc] initWithContentsOfFile:[dir stringByAppendingPathComponent:file]];
	
	// We have l00ked thru da directory, yo
	if(filesIndex == -1)
		[self scrambleFiles];
	
	return im;
}

@end
