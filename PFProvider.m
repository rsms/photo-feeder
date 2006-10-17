#import "PFProvider.h"

@implementation PFProvider

-(id)init
{
	dataLock = [[NSConditionLock alloc] initWithCondition:WAITING_FOR_DATA];
	buffer = [[PFQueue alloc] initWithCapacity:20];
	NSLog(@"[%@ init] buffer: %@", self, buffer);
	[NSThread detachNewThreadSelector:@selector(fillBufferThread:) toTarget:self withObject:nil];
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
		
		[buffer put:[NSURL URLWithString:@"http://static.flickr.com/79/270773771_43fea70d2b_b.jpg"]];
		[buffer put:[NSURL URLWithString:@"http://static.flickr.com/90/245707482_620b878566_b.jpg"]];
		[buffer put:[NSURL URLWithString:@"http://static.flickr.com/96/207296186_07c83ed2fa_b.jpg"]];
		[buffer put:[NSURL URLWithString:@"http://static.flickr.com/90/245707482_620b878566_b.jpg"]];
		
		[dataLock unlockWithCondition:HAS_DATA];
	}
	[pool release];
}

@end
