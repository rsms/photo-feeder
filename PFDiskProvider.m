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
	while( file = [dirEnum nextObject] )
	{
		if ([[file pathExtension] isEqualToString:@"jpg"])
		{
			PFGLImage* gli = [[PFGLImage alloc] initWithContentsOfFile:[dir stringByAppendingPathComponent:file]];
			return [[PFImage alloc] initWithGLImage:gli];
		}
	}
	
	return nil;
}

@end
