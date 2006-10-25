
#import "FlickrResponse.h"

@interface FlickrContext : NSObject {
	NSString* apiKey;
}

+ (FlickrContext*) defaultContext;

- (void) setApiKey:(NSString*)key;
- (NSString*) apiKey;

- (FlickrResponse*) callMethod:(NSString*)method;
- (FlickrResponse*) callMethod:(NSString*)method arguments:(NSString*)args;

@end
