#import "PFFlickrProvider.h"

@implementation PFFlickrProvider

-(id)init
{
	[super init];
	
	//flickrContext = [[OFFlickrContext contextWithAPIKey:OFDemoAPIKey sharedSecret:OFDemoSharedSecret] retain];
	//flickrInvoc = [[OFFlickrInvocation invocationWithContext:flickrContext delegate:self] retain];
	
	return self;
}


-(void)addURLs
{	
	NSURL* url = [NSURL URLWithString:@"http://api.flickr.com/services/rest/?method=flickr.favorites.getPublicList&api_key=9b4439ce94de7e2ec2c2e6ffadc22bcf&user_id=12281432@N00&per_page=999&extras=date_taken"];
	NSXMLDocument* doc = [[[NSXMLDocument alloc] initWithContentsOfURL:url options:0 error:nil] autorelease];
	
	// Flickr service error?
	if([[[[doc rootElement] attributeForName:@"stat"] stringValue] compare:@"fail" options:0] == 0)
	{
		throw_ex(@"PFFlickrProviderException", [[(NSXMLElement*)[[doc rootElement] childAtIndex:0] attributeForName:@"msg"] stringValue]);
	}
	
	// Find photos
	NSError* err = nil;
	NSArray* childs = [[doc rootElement] nodesForXPath:@"/rsp/photos/photo" error:&err];
	if(err) // TODO: test and fix
		NSLog(@"Error: %@", err);
	
	// Add URLs
	NSEnumerator* it = [childs objectEnumerator];
	NSXMLElement* n;
	while (n = (NSXMLElement*)[it nextObject]) {
		NSString* urlString = [[NSString stringWithFormat:@"http://static.flickr.com/%@/%@_%@_b.jpg",
			[[n attributeForName:@"server"] stringValue],
			[[n attributeForName:@"id"] stringValue],
			[[n attributeForName:@"secret"] stringValue]] autorelease];
		NSLog(@"url: %@", urlString);
		[urls addObject:[NSURL URLWithString:urlString]];
	}
	
	// Sure shots:
	//[urls addObject:[NSURL URLWithString:@"http://static.flickr.com/79/270773771_43fea70d2b_b.jpg"]];
	//[urls addObject:[NSURL URLWithString:@"http://static.flickr.com/90/245707482_620b878566_b.jpg"]];
	//[urls addObject:[NSURL URLWithString:@"http://static.flickr.com/96/207296186_07c83ed2fa_b.jpg"]];
	//[urls addObject:[NSURL URLWithString:@"http://static.flickr.com/90/245707482_620b878566_b.jpg"]];
}

@end
