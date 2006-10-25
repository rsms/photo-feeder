
@interface FlickrUser : NSObject {
	NSString* uid;
	NSString* name;
}

+ (FlickrUser*) userWithId:(NSString*)uid;
+ (FlickrUser*) userWithName:(NSString*)name;

- (id) initWithId:(NSString*)uid;
- (id) initWithId:(NSString*)uid name:(NSString*)name;

- (NSString*)uid;
- (NSString*)name;

@end
