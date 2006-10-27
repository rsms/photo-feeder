#import "FlickrContext.h"

@interface FlickrUser : NSObject {
	FlickrContext* ctx;
	NSString*      uid;
	NSString*      name;
	
	NSDictionary*  info; // contains realName, location, etc loaded from _fetchInfo
}

+ (FlickrUser*) userWithId:(NSString*)uid context:(FlickrContext*)ctx;

+ (FlickrUser*) userWithName:(NSString*)name context:(FlickrContext*)ctx;
+ (FlickrUser*) userWithName:(NSString*)name; // uses [FlickrContext defaultContext]

- (id) initWithId:(NSString*)uid name:(NSString*)name context:(FlickrContext*)ctx;

- (NSString*)uid;
- (NSString*)name;
- (NSString*)realName;

@end
