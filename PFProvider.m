#import "PFProvider.h"

@implementation PFProvider

-(id)init
{
	urlQueue = [NSMutableArray arrayWithCapacity:20];
	dataLock = [[NSConditionLock alloc] initWithCondition:WAITING_FOR_DATA];
	
	NSLog(@"[%@ init] urlQueue: %@", self, urlQueue);
	
	[NSThread detachNewThreadSelector:@selector(fillBufferThread:) 
							 toTarget:self 
						   withObject:nil];
	return self;
}

-(NSURL*)getURL
{
	[dataLock lockWhenCondition:HAS_DATA];
	NSLog(@"[%@ getURL]", self);
	
	NSURL* url = (NSURL *)[urlQueue lastObject];
	[urlQueue removeLastObject];
	
	if([urlQueue count] == 0) {
		NSLog(@"[%@ getURL] Buffer was emptied", self);
		[dataLock unlockWithCondition:WAITING_FOR_DATA];
	}
	else
		[dataLock unlock];
	
	return url;
}

-(void) fillBufferThread:(id)o
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	while(1) {
		[dataLock lockWhenCondition:WAITING_FOR_DATA];
		
		NSLog(@"[%@ fillBufferThread] iteration. buffer: %@", self, buffer);
		
		// get some images from flickr
		// TODO: per_page = buffer->capacity
		/*url = [NSURL URLWithString:@"http://api.flickr.com/services/rest/?method=flickr.favorites.getPublicList&api_key=9b4439ce94de7e2ec2c2e6ffadc22bcf&user_id=12281432@N00&per_page=20"];
		NSXMLDocument* doc = [[NSXMLDocument alloc] initWithContentsOfURL:url options:0 error:nil];*/
		
		[urlQueue addObject:[NSURL URLWithString:@"http://static.flickr.com/79/270773771_43fea70d2b_b.jpg"]];
		[urlQueue addObject:[NSURL URLWithString:@"http://static.flickr.com/90/245707482_620b878566_b.jpg"]];
		[urlQueue addObject:[NSURL URLWithString:@"http://static.flickr.com/96/207296186_07c83ed2fa_b.jpg"]];
		[urlQueue addObject:[NSURL URLWithString:@"http://static.flickr.com/90/245707482_620b878566_b.jpg"]];
		
		[dataLock unlockWithCondition:HAS_DATA];
	}
	[pool release];
}

@end
