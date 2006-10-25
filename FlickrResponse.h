
@interface FlickrResponse : NSObject {
	int           errorCode;
	NSString*     errorMessage;
	NSXMLElement* dom;
}

- (id) initWithDOM:(NSXMLElement*)root;
- (id) initWithErrorCode:(int)code errorMessage:(NSString*)msg;

- (int) errorCode;
- (NSString*) errorMessage;

- (NSXMLElement*) dom;

@end
