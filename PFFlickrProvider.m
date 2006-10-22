#import "PFFlickrProvider.h"

@implementation PFFlickrProvider

/* GOTT MOS:
NSURLRequest* req = [NSURLRequest requestWithURL: url 
									 cachePolicy: NSURLRequestReturnCacheDataElseLoad
								 timeoutInterval: 5.0];
NSURLResponse* res;
NSError* err;
NSData* imData = [NSURLConnection sendSynchronousRequest: req 
									   returningResponse: &res
												   error: &err];
NSLog(@"%@", [res URL]);
*/

-(id)init
{
	[super init];
	urls = [[[PFQueue alloc] initWithCapacity:20] retain];
	NSLog(@"[%@ init] urls: %@", self, urls);
	[NSThread detachNewThreadSelector:@selector(addURLsThread:) 
							 toTarget:self 
						   withObject:nil];
	return self;
}


- (NSString*)urlForSize:(NSString*)photoId size:(NSString*)size
{
	NSXMLElement* root = [self callMethod:@"flickr.photos.getSizes" 
								   params:[NSString stringWithFormat:@"photo_id=%@", photoId]];
	
	// Find childs
	NSError* err;
	NSArray* children = [root nodesForXPath:@"/rsp/sizes/size" error:&err];
	if(err) {
		NSLog(@"Error: %@", err);
		return nil;
	}
	
	// Find URL
	NSEnumerator* it = [children objectEnumerator];
	NSXMLElement* n;
	while (n = (NSXMLElement*)[it nextObject])
		if([[[n attributeForName:@"label"] stringValue] caseInsensitiveCompare:size] == 0)
			return [[n attributeForName:@"source"] stringValue];
	
	return nil;
}


- (NSXMLElement*)callMethod:(NSString*)method params:(NSString*)params
{
	NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=%@&api_key=9b4439ce94de7e2ec2c2e6ffadc22bcf&%@", method, params]];
	NSXMLDocument* doc = [[[NSXMLDocument alloc] initWithContentsOfURL:url options:0 error:nil] autorelease];
	
	// Flickr service error?
	if([[[[doc rootElement] attributeForName:@"stat"] stringValue] compare:@"fail" options:0] == 0)
	{
		throw_ex(@"PFFlickrProviderException", 
				 [[(NSXMLElement*)[[doc rootElement] childAtIndex:0] attributeForName:@"msg"] stringValue]);
	}
	
	return (NSXMLElement*)[doc rootElement];
}


-(NSURL*)getURL
{
	//NSLog(@"[%@ getURL]", self);
	return (NSURL *)[urls take];
}


- (void)addURLsThread:(id)o
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	while(1) {
		NSLog(@"[%@ addURLsThread] calling [%@ addURLs]...", self, self);
		[self addURLs];
	}
	[pool release];
}


- (void)addURLs
{
	NSXMLElement* root = [self callMethod:@"flickr.favorites.getPublicList" 
								   params:@"user_id=12281432@N00&per_page=999&extras=date_taken"];
	
	// Find photos
	NSError* err = nil;
	NSArray* children = [root nodesForXPath:@"/rsp/photos/photo" error:&err];
	if(err) // TODO: test and fix
		NSLog(@"Error: %@", err);
	
	// Add URLs
	NSEnumerator* it = [children objectEnumerator];
	NSXMLElement* n;
	NSString* urlString;
	while (n = (NSXMLElement*)[it nextObject])
	{
		urlString = [self urlForSize: [[n attributeForName:@"id"] stringValue] 
								size: @"Large"];
		if(urlString)
			[urls put:[NSURL URLWithString:urlString]];
		else
			NSLog(@"[%@ addURLs] Image was too small", self);
	}
	
	// Sure shots:
	//[urls addObject:[NSURL URLWithString:@"http://static.flickr.com/90/245707482_620b878566_b.jpg"]];
	//[urls addObject:[NSURL URLWithString:@"http://static.flickr.com/79/270773771_43fea70d2b_b.jpg"]];
	//[urls addObject:[NSURL URLWithString:@"http://static.flickr.com/96/207296186_07c83ed2fa_b.jpg"]];
	//[urls addObject:[NSURL URLWithString:@"http://static.flickr.com/90/245707482_620b878566_b.jpg"]];
	
}

@end
