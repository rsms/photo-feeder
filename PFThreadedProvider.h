/**
 * PhotoFeeder is the legal property of its developers.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version. You should have received a copy 
 * of the GNU General Public License along with this program; if not, 
 * write to the Free Software Foundation, Inc., 59 Temple Place, 
 * Suite 330, Boston, MA 02111-1307 USA
 */
#import "PFProvider.h"

@interface PFThreadedProvider : NSObject<PFProvider> {
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