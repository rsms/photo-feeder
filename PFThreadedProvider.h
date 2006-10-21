#import "PFProvider.h"

@interface PFThreadedProvider : PFProvider {
	NSConditionLock* urlsLock;
	NSMutableArray*  urls;
}

/**
 * Runs the thread which is responsible for calling addURLs to add URL:s, 
 * when the queue is empty.
 */
-(void)addURLsThread:(id)obj;

/**
 * Called upon from the addURLsThread to fill the urls array with new URLs.
 * You need to override this method.
 */
-(void)addURLs;

@end