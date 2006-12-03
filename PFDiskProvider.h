#import "PFProvider.h"

@interface PFDiskProvider : PFProvider {
	NSString* dir;
	NSDirectoryEnumerator* dirEnum;
}

- (id) initWithPathToDirectory:(NSString*)dir;

@end
