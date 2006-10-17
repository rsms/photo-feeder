#import "PFQueue.h"

@interface PFProvider : NSObject {
	NSConditionLock* dataLock;
	PFQueue* buffer;
}

-(NSURL*)getURL;
-(void)fillBufferThread:(id)obj;

@end
