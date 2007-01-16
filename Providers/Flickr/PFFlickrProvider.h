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

// prefix.pch is only needed for debug macros (DLog, and so on)
// Not required by external plugin developers.
#import "../../prefix.pch"

#import "PFProvider.h"
#import "PFQueue.h"

@interface PFFlickrProvider : NSObject<PFProvider> {
	PFQueue*  urls;
}

- (NSString*)urlForSize:(NSString*)photoId size:(NSString*)size;
- (NSXMLElement*)callMethod:(NSString*)method params:(NSString*)params;

- (void)addURLsThread:(id)o;
- (void)addURLs;

@end
