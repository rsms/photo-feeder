#import "PFProvider.h"
#import "PFQueue.h"

@interface PFFlickrProvider : PFProvider {
	PFQueue*  urls;
}

- (NSString*)urlForSize:(NSString*)photoId size:(NSString*)size;
- (NSXMLElement*)callMethod:(NSString*)method params:(NSString*)params;

- (void)addURLsThread:(id)o;
- (void)addURLs;

@end
