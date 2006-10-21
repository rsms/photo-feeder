#import "PFFlickrProvider.h"

@implementation PFFlickrProvider

-(id)init
{
	[super init];
	// TODO:
	// Create the OFFlickrContext to store your API key and use OFFliickrInvocation to call any Flickr API method
	return self;
}


-(void)addURLs
{
	// get some images from flickr
		// TODO: per_page = buffer->capacity
	/*url = [NSURL URLWithString:@"http://api.flickr.com/services/rest/?method=flickr.favorites.getPublicList&api_key=9b4439ce94de7e2ec2c2e6ffadc22bcf&user_id=12281432@N00&per_page=20"];
	NSXMLDocument* doc = [[NSXMLDocument alloc] initWithContentsOfURL:url options:0 error:nil];*/
	
	[urls addObject:[NSURL URLWithString:@"http://static.flickr.com/79/270773771_43fea70d2b_b.jpg"]];
	[urls addObject:[NSURL URLWithString:@"http://static.flickr.com/90/245707482_620b878566_b.jpg"]];
	[urls addObject:[NSURL URLWithString:@"http://static.flickr.com/96/207296186_07c83ed2fa_b.jpg"]];
	[urls addObject:[NSURL URLWithString:@"http://static.flickr.com/90/245707482_620b878566_b.jpg"]];
}

@end
