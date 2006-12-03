#import "PFDiskProvider.h"


@implementation PFDiskProvider

- (id) initWithPathToDirectory:(NSString*)d
{
	dir = [d retain];
	dirEnum = [[[NSFileManager defaultManager] enumeratorAtPath:dir] retain];
	return self;
}


-(PFImage*)nextImage
{
	NSString* file;
	NSArray* acceptExts = [PFGLImage acceptableFileExtensions];
	
	while( file = [dirEnum nextObject] )
	{
		if( [acceptExts containsObject:[file pathExtension]] )
		{
			DLog(@"%@", file);
			PFGLImage* gli = [[PFGLImage alloc] initWithContentsOfFile:[dir stringByAppendingPathComponent:file]];
			return [[PFImage alloc] initWithGLImage:gli];
		}
	}
	
	return nil;
}

@end
