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
