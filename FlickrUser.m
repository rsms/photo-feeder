#import "FlickrUser.h"
#import "FlickrContext.h"

@implementation FlickrUser

+ (FlickrUser*) userWithId:(NSString*)uid
{
	return [[[FlickrUser alloc] initWithId:uid] retain];
}


+ (FlickrUser*) userWithName:(NSString*)name
{
	FlickrResponse* rsp = [[FlickrContext defaultContext] callMethod: @"flickr.people.findByUsername"
														   arguments: [NSString stringWithFormat:@"username=%@", name]];
	// Errors?
	if([rsp errorCode]) {
		if([rsp errorCode] != 1)
			// 1 = user not found, which we don't need to log
			NSLog(@"[FlickrUser userWithName] failed with response error %d: %@", [rsp errorCode], [rsp errorMessage]);
		return nil;
	}
	
	NSXMLElement* u = (NSXMLElement*)[[rsp dom] childAtIndex:0];
	NSString* nam = [(NSXMLElement*)[(NSXMLElement*)[u childAtIndex:0] childAtIndex:0] stringValue];
	
	return [[FlickrUser alloc] initWithId: [[u attributeForName:@"id"] stringValue] 
									 name: nam];
}


- (id) initWithId:(NSString*)i {
	uid = [i retain];
	return self;
}

- (id) initWithId:(NSString*)i name:(NSString*)n {
	uid = [i retain];
	name = [n retain];
	return self;
}

- (NSString*)uid {
	return uid;
}

- (NSString*)name {
	return name;
}

@end
