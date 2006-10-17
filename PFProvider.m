#import "PFProvider.h"
#import "PFQueue.h"

@interface PPFProvider
NSConditionLock* dataLock;
PFQueue* buffer;
@end
//-------------------------------------
@implementation PFProvider

-(id)init
{
	dataLock = [[NSConditionLock alloc] initWithCondition:WAITING_FOR_DATA];
	buffer = [[PFQueue alloc] initWithCapacity:20];
	[NSThread detachNewThreadSelector:@selector(fillBufferThread:) toTarget:self withObject:buffer];
	return self;
}

-(NSURL*)getURL
{
	[dataLock lockWhenCondition:HAS_DATA];
	
	NSLog(@"[%@ getURL]", self);
	NSURL* url = (NSURL*)[buffer poll];
	if(url == nil)
		NSLog(@"FATAL! Moment 22 - got nil from buffer which should be filled");
	
	if([buffer count] == 0) {
		NSLog(@"[%@ getURL] Buffer was emptied", self);
		[dataLock unlockWithCondition:WAITING_FOR_DATA];
	}
	else
		[dataLock unlock];
	
	return url;
}

-(void) fillBufferThread:(id)_buf {
	PFQueue* buf = (PFQueue*)_buf;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	while(1) {
		[dataLock lockWhenCondition:WAITING_FOR_DATA];
		
		NSLog(@"[%@ fillBufferThread] iteration", self);
		
		// get some images from flickr
		// TODO: per_page = buffer->capacity
		/*url = [NSURL URLWithString:@"http://api.flickr.com/services/rest/?method=flickr.favorites.getPublicList&api_key=9b4439ce94de7e2ec2c2e6ffadc22bcf&user_id=12281432@N00&per_page=20"];
		NSXMLDocument* doc = [[NSXMLDocument alloc] initWithContentsOfURL:url options:0 error:nil];*/
		
		[buf put:[NSURL URLWithString:@"http://static.flickr.com/96/207296186_07c83ed2fa_b.jpg"]];
		[buf put:[NSURL URLWithString:@"http://static.flickr.com/90/245707482_620b878566_b.jpg"]];
		[buf put:[NSURL URLWithString:@"http://static.flickr.com/96/207296186_07c83ed2fa_b.jpg"]];
		[buf put:[NSURL URLWithString:@"http://static.flickr.com/90/245707482_620b878566_b.jpg"]];
		
		[dataLock unlockWithCondition:HAS_DATA];
	}
	[pool release];
}

@end
