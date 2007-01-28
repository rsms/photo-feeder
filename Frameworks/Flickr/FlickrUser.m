/*
 * Flickr Objective-C Framework is the legal property of its developers.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version. You should have received a copy 
 * of the GNU General Public License along with this program; if not, 
 * write to the Free Software Foundation, Inc., 59 Temple Place, 
 * Suite 330, Boston, MA 02111-1307 USA
 */
#import "FlickrUser.h"

@interface FlickrUser (Private)
- (void) _fetchInfo;
@end

@implementation FlickrUser


#pragma mark -- Public class methods

+ (FlickrUser*) userWithId:(NSString*)uid context:(FlickrContext*)ctx
{
	return [[FlickrUser alloc] initWithContext: ctx
										   uid: uid
										  name: nil];
}

+ (FlickrUser*) userWithId:(NSString*)uid {
	return [FlickrUser userWithId:uid context:[FlickrContext defaultContext]];
}


+ (FlickrUser*) userWithName:(NSString*)name context:(FlickrContext*)ctx
{
	FlickrResponse* rsp = [ctx callMethod: @"flickr.people.findByUsername"
								arguments: [NSString stringWithFormat:@"username=%@", name]];
	// Errors?
	if([rsp errorCode]) {
		if([rsp errorCode] != 1) // 1 = user not found, which we don't need to log
			NSLog(@"[FlickrUser userWithName] failed with response error %d: %@", [rsp errorCode], [rsp errorMessage]);
		return nil;
	}
	
	NSXMLElement* u = (NSXMLElement*)[[rsp dom] childAtIndex:0];
	NSString* nam = [(NSXMLElement*)[(NSXMLElement*)[u childAtIndex:0] childAtIndex:0] stringValue];
	
	return [[FlickrUser alloc] initWithContext: ctx
										   uid: [[u attributeForName:@"id"] stringValue] 
										  name: nam];
}

+ (FlickrUser*) userWithName:(NSString*)name {
	return [FlickrUser userWithName:name context:[FlickrContext defaultContext]];
}



#pragma mark -- Public instance methods

- (id) initWithContext:(FlickrContext*)context uid:(NSString*)i name:(NSString*)n
{
	ctx = [context retain];
	uid = [i retain];
	numberOfPhotos = -1;
	if(n)
		name = [n retain];
	return self;
}

- (NSString*)uid {
	return uid;
}

// Convenience macro generating a get method for 
// fetchInfo depended properties
#define FETCHINFO_PROP_GET(_ret,_prop) \
- (_ret)_prop { \
	if(!_prop) [self _fetchInfo]; \
	return _prop; \
}

FETCHINFO_PROP_GET(NSString*, name);
FETCHINFO_PROP_GET(NSString*, realName);
FETCHINFO_PROP_GET(NSString*, location);
FETCHINFO_PROP_GET(NSURL*, photosURL);
FETCHINFO_PROP_GET(NSURL*, profileURL);
FETCHINFO_PROP_GET(NSURL*, mobileURL);
FETCHINFO_PROP_GET(NSDate*, firstDateUploaded);
FETCHINFO_PROP_GET(NSDate*, firstDateTaken);

- (int) numberOfPhotos {
	if(numberOfPhotos == -1) [self _fetchInfo];
	return numberOfPhotos;
}



#pragma mark -- Private instance methods

- (void) _fetchInfo
{
	if(_hasFetchedInfo)
		return;
	
	DLog(@"[%@ _fetchInfo]", self);
	
	// Mark as done
	_hasFetchedInfo = YES;
	
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
	
	// Get outer element
	NSXMLElement* u;
	u = (NSXMLElement*)[[rsp dom] childAtIndex:0];
	
	// Convenience macro for getting the child node value of the first found element with name
#define FETCHINFO_ELEMENTVAL(_n,name) \
	[[[[_n elementsForName:name] objectAtIndex:0] childAtIndex:0] stringValue]
	
	@try {
		// Extract info
		name = [FETCHINFO_ELEMENTVAL(u,@"username") retain];
		realName = [FETCHINFO_ELEMENTVAL(u,@"realname") retain];
		location = [FETCHINFO_ELEMENTVAL(u,@"location") retain];
		photosURL = [[NSURL URLWithString:FETCHINFO_ELEMENTVAL(u,@"photosurl")] retain];
		profileURL = [[NSURL URLWithString:FETCHINFO_ELEMENTVAL(u,@"profileurl")] retain];
		mobileURL = [[NSURL URLWithString:FETCHINFO_ELEMENTVAL(u,@"mobileurl")] retain];
		
		// Photos node
		NSXMLElement* photos = (NSXMLElement*)[[u elementsForName:@"photos"] objectAtIndex:0];
		
		// Dates
		firstDateUploaded = [[NSDate dateWithTimeIntervalSince1970:[FETCHINFO_ELEMENTVAL(photos,@"firstdate") intValue]] retain];
		firstDateTaken = [[NSDate dateWithString:[FETCHINFO_ELEMENTVAL(photos,@"firstdatetaken") stringByAppendingString:@" +0000"]] retain];
		
		// Numbers
		numberOfPhotos = [FETCHINFO_ELEMENTVAL(photos,@"count") intValue];
	}
	@catch(NSException* e) {
		NSLog(@"[FlickrUser _fetchInfo] failed from exception: %@", e);
	}
}

@end
