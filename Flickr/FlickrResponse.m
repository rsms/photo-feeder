#import "FlickrResponse.h"

@implementation FlickrResponse

- (id) initWithErrorCode:(int)code errorMessage:(NSString*)msg
{
	errorCode = code;
	errorMessage = [msg retain];
	return self;
}

- (id) initWithDOM:(NSXMLElement*)root
{
	dom = root;
	return self;
}

- (int) errorCode {
	return errorCode;
}

- (NSString*) errorMessage {
	return errorMessage;
}

- (NSXMLElement*) dom {
	return dom;
}

@end
