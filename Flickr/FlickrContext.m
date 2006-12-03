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
#import "FlickrContext.h"

@implementation FlickrContext

static FlickrContext* _default = nil;

+ (FlickrContext*) defaultContext
{
	if(!_default)
		_default = [[[FlickrContext alloc] init] retain];
	return _default;
}

- (void) setApiKey:(NSString*)k
{
	NSString* old = apiKey;
	apiKey = [k retain];
	if(old)
		[old release];
}

- (NSString*) apiKey
{
	return apiKey;
}


- (FlickrResponse*) callMethod:(NSString*)method {
	return [self callMethod:method arguments:@""];
}


- (FlickrResponse*) callMethod:(NSString*)method arguments:(NSString*)args
{
	DLog(@"[%@ callMethod] %@ ( %@ )", self, method, args);
	
	NSURL* url;
	NSXMLElement* d;
	
	url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=%@&api_key=%@&%@", method, apiKey, args]];
	d = (NSXMLElement*)[[[[NSXMLDocument alloc] initWithContentsOfURL:url options:0 error:nil] autorelease] rootElement];
	
	if([[[d attributeForName:@"stat"] stringValue] compare:@"fail" options:0] == 0) {
		// Error
		NSXMLElement* error = (NSXMLElement*)[d childAtIndex:0];
		return [[FlickrResponse alloc] initWithErrorCode:[[[error attributeForName:@"code"] stringValue] intValue]
											errorMessage:[[error attributeForName:@"msg"] stringValue]];
	}
	
	return [[FlickrResponse alloc] initWithDOM:d];
}

@end
