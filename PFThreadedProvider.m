#import "PFThreadedProvider.h"

@implementation PFThreadedProvider

-(id)init
{
	[super init];
	urls = [[[NSMutableArray alloc] init] retain];
	urlsLock = [[[NSConditionLock alloc] initWithCondition:NO_DATA] retain];
	NSLog(@"[%@ init] urls: %@", self, urls);
	[NSThread detachNewThreadSelector:@selector(addURLsThread:) 
							 toTarget:self 
						   withObject:nil];
	return self;
}

- (void) dealloc {
	[urls release];
	[urlsLock release];
	[super dealloc];
}


-(NSURL*)getURL
{
	[urlsLock lockWhenCondition:HAS_DATA];
	NSLog(@"[%@ getURL]", self);
	
	NSURL* url = (NSURL *)[urls lastObject];
	[urls removeLastObject];
	
	if([urls count] == 0) {
		NSLog(@"[%@ getURL] Buffer was emptied", self);
		[urlsLock unlockWithCondition:NO_DATA];
	}
	else
		[urlsLock unlock];
	
	return url;
}

-(void) addURLsThread:(id)o
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	while(1) {
		[urlsLock lockWhenCondition:NO_DATA];
		NSLog(@"[%@ addURLsThread] calling [%@ addURLs]...", self, self);
		[self addURLs];
		[urlsLock unlockWithCondition:HAS_DATA];
	}
	[pool release];
}

-(void)addURLs
{
	throw_ex(@"PFProviderException", @"[PFThreadedProvider addURLs] method is abstract and not overridden");
}

@end
