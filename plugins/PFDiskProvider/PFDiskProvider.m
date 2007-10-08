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

#import "NSArrayPFAdditions.h"
#import "PFDiskProvider.h"

@implementation PFDiskProvider

static NSArray* acceptableFileExtensions = nil;


+ (NSString*) pluginName {
	return @"Disk";
}


#pragma mark -
#pragma mark Instance


- (id) init {
	[super init];
	
	// Setup acceptable file extensions
	if(!acceptableFileExtensions) {
		acceptableFileExtensions = [[NSArray arrayWithObjects:
			@"jpeg", @"jpg", @"gif", @"png", @"tif", @"tiff", @"psd", @"pict", nil] retain];
	}
	
	files = nil;
	return self;
}


- (void) dealloc {
	if(files)
		[files release];
	[super dealloc];
}


#pragma mark -
#pragma mark Configure UI


- (BOOL)hasConfigureSheet {
	return YES;
}


- (NSWindow*) configureSheet {
	//NSBundle* bundle = [NSBundle bundleForClass:[self class]];
	if(![NSBundle loadNibNamed:NSStringFromClass([self class]) owner:self]) {
		NSTrace(@"Failed to load NIB file");
		return nil;
	}
	return window;
}


#pragma mark -
#pragma mark Accessors


-(void) setConfiguration:(NSMutableDictionary*)conf {
	[super setConfiguration:conf];
	
	if(![configuration objectForKey:@"directoryPath"]) {
		[configuration setObject:[@"~/Pictures" stringByExpandingTildeInPath] forKey:@"directoryPath"];
  }
	
	//if(![configuration objectForKey:@"minimumImageSize"])
	//	[configuration setObject:[NSNumber numberWithInt:400] forKey:@"minimumImageSize"];
}


- (NSString*) directoryPath {
	return [configuration objectForKey:@"directoryPath"];
}


- (void) setDirectoryPath:(NSString*)path {
	DLog(@"self = %@", self);
	
	NSString* oldPath = [self directoryPath];
	if(oldPath && [oldPath isEqualToString:path]) {
		return;
  }
	
	[configuration setObject:path forKey:@"directoryPath"];
	
	// Force re-read of files
	[self setFiles:nil];
}


- (NSNumber*) minimumImageSize {
	return [configuration objectForKey:@"minimumImageSize"];
}


- (void) setMinimumImageSize:(NSNumber*)n {
	[configuration setObject:n forKey:@"minimumImageSize"];
}


- (void) setFiles:(NSMutableArray*)a {
	id old = files;
	files = a ? [a retain] : nil;
	if(old) [old release];
}



#pragma mark -
#pragma mark Image polling


- (void) scrambleFiles {
	NSDirectoryEnumerator* dirEnum;
	NSMutableArray* filesTemp;
	NSString* file;
	NSString* dir;
	
	dir = [self directoryPath];
	dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:dir];
	
	if(!dirEnum)
	{
		DLog(@"Directory not found '%@'", dir);
		[self setFiles:[NSMutableArray array]];
		filesIndex = -1;
		return;
	}
	
	filesTemp = [NSMutableArray array];
	
	while( file = [dirEnum nextObject] ) {
		if( [acceptableFileExtensions containsObject:[[file pathExtension] lowercaseString]] ) {
			[filesTemp addObject:[dir stringByAppendingPathComponent:file]];
    }
  }
	
	[self setFiles:[filesTemp randomCopy]];
	filesIndex = [files count]-1;
}


-(NSImage*)nextImage {
	NSImage* im;
	
	// Dig dir if not done already
	if(!files) {
		[self scrambleFiles];
  }
	
	// We know the files array is empty
	if(filesIndex == -1) {
		return nil;
  }
	
	int minSize = [[self minimumImageSize] intValue];
	
	// Take image from array
	while(filesIndex) {
		if(!(im = [[NSImage alloc] initWithContentsOfFile:[files objectAtIndex:filesIndex--]])) {
			break;
    }
		
		// Check min size
		NSSize size = [im size];
		if(size.width >= minSize && size.height >= minSize) {
			break;
		} else {
			DLog(@"Removing too small image at index %d", filesIndex+1);
			[files removeObjectAtIndex:filesIndex+1];
		}
	}
	
	// We have l00ked thru da directory, yo
	if(filesIndex == -1) {
		[self setFiles:nil]; // trigger re-read on next call
  }
	
	return im;
}

@end
