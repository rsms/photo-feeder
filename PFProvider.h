#import "PFQueue.h"

@interface PFProvider : NSObject {
	NSConditionLock* dataLock;
	PFQueue* buffer;
	NSMutableArray* urlQueue;
}

-(NSURL*)getURL;
-(void)fillBufferThread:(id)obj;

@end
