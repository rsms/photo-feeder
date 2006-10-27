#import "FlickrUser.h"

@interface FlickrUser (Private)
- (void) _fetchInfo;
@end

@implementation FlickrUser


#pragma mark -- Public class methods

+ (FlickrUser*) userWithId:(NSString*)uid context:(FlickrContext*)ctx
{
	return [[FlickrUser alloc] initWithId: uid
									 name: nil
								  context: ctx];
}


+ (FlickrUser*) userWithName:(NSString*)name {
	return [FlickrUser userWithName:name context:[FlickrContext defaultContext]];
}


+ (FlickrUser*) userWithName:(NSString*)name context:(FlickrContext*)ctx
{
	FlickrResponse* rsp = [ctx callMethod: @"flickr.people.findByUsername"
								arguments: [NSString stringWithFormat:@"username=%@", name]];
	// Errors?
	if([rsp errorCode]) {
		if([rsp errorCode] != 1) {
			// 1 = user not found, which we don't need to log
			NSLog(@"[FlickrUser userWithName] failed with response error %d: %@", [rsp errorCode], [rsp errorMessage]);
		}
		return nil;
	}
	
	NSXMLElement* u = (NSXMLElement*)[[rsp dom] childAtIndex:0];
	NSString* nam = [(NSXMLElement*)[(NSXMLElement*)[u childAtIndex:0] childAtIndex:0] stringValue];
	
	return [[FlickrUser alloc] initWithId: [[u attributeForName:@"id"] stringValue] 
									 name: nam
								  context: ctx];
}



#pragma mark -- Public instance methods

- (id) initWithId:(NSString*)i name:(NSString*)n context:(FlickrContext*)context
{
	ctx = [context retain];
	uid = [i retain];
	name = [n retain];
	return self;
}

- (NSString*)uid {
	return uid;
}

- (NSString*)name {
	if(!name)
		[self _fetchInfo];
	return name;
}

- (NSString*)realName {
	if(!info)
		[self _fetchInfo];
	return (NSString*)[info objectForKey:@"realname"];
}



#pragma mark -- Private instance methods

- (void) _fetchInfo
{
	DLog(@"[%@ _fetchInfo]", self);
	FlickrResponse* rsp;
	rsp = [ctx callMethod: @"flickr.people.getInfo"
				arguments: [NSString stringWithFormat:@"user_id=%@", uid]];
	
	// Errors?
	if([rsp errorCode]) {
		if([rsp errorCode] != 1) {
			// 1 = user not found, which we don't need to log
			NSLog(@"[FlickrUser _fetchInfo] failed with response error %d: %@", [rsp errorCode], [rsp errorMessage]);
		}
		return;
	}
	
	NSXMLElement* u;
	
	info = [NSMutableDictionary dictionaryWithCapacity:11];
	u = (NSXMLElement*)[[rsp dom] childAtIndex:0];
	
	name = [[[[u elementsForName:@"username"] objectAtIndex:0] childAtIndex:0] stringValue];
	
	NSLog(@"name = %@", name);
	//NSString* nam = [(NSXMLElement*)[(NSXMLElement*)[u childAtIndex:0] childAtIndex:0] stringValue];
	
	
}

@end
