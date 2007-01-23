/*
 * PhotoFeeder is the legal property of its developers.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version. You should have received a copy 
 * of the GNU General Public License along with this program; if not, 
 * write to the Free Software Foundation, Inc., 59 Temple Place, 
 * Suite 330, Boston, MA 02111-1307 USA
 */

#import "NSArrayPFAdditions.h"
#import "PFFlickrProvider.h"

@implementation PFFlickrProvider


+ (NSString*) pluginName
{
	return @"Flickr: rsms favourites";
}


/* GOTT MOS:
NSURLRequest* req = [NSURLRequest requestWithURL: url 
												 cachePolicy: NSURLRequestReturnCacheDataElseLoad
											timeoutInterval: 5.0];
NSURLResponse* res;
NSError* err;
NSData* imData = [NSURLConnection sendSynchronousRequest: req 
													returningResponse: &res
																	error: &err];
DLog(@"%@", [res URL]);
*/


- (id) init
{
	[super init];
	
	// Internal URL queue
	urls = [[[PFQueue alloc] initWithCapacity:10] retain];
	
	// Used to pause the addURLsThread when not active
	activeCondLock = [[[NSConditionLock alloc] initWithCondition:YES] retain];
	
	[NSThread detachNewThreadSelector:@selector(addURLsThread:) 
							 toTarget:self 
						   withObject:nil];
	return self;
}


- (void) dealloc
{
	[urls release];
	[activeCondLock release];
	[super dealloc];
}


-(void) setConfiguration:(NSMutableDictionary*)conf
{
	[super setConfiguration:conf];
	
	// Update our condlock implementation of active/setActive
	[activeCondLock lock];
	[activeCondLock unlockWithCondition:[super active]];
}


-(BOOL) active
{
	return [activeCondLock condition];
}


-(void) setActive:(BOOL)b
{
	[super setActive:b];
	[activeCondLock lock];
	[activeCondLock unlockWithCondition:b];
}


- (NSString*) urlForSize:(NSString*)photoId size:(NSString*)size
{
	NSXMLElement* root = [self callMethod:@"flickr.photos.getSizes" 
											 params:[NSString stringWithFormat:@"photo_id=%@", photoId]];
	
	if(!root)
		return nil;
	
	// Find childs
	NSError* err;
	NSArray* children = [root nodesForXPath:@"/rsp/sizes/size" error:&err];
	if(err) {
		NSLog(@"Error: %@", err);
		[root release];
		return nil;
	}
	
	if(!children)
	{
		NSTrace(@"Error: No child nodes (no photos?)");
		return nil;
	}
	
	// Find URL
	NSEnumerator* it = [children objectEnumerator];
	NSXMLElement* n;
	while (n = (NSXMLElement*)[it nextObject]) {
		if([[[n attributeForName:@"label"] stringValue] caseInsensitiveCompare:size] == 0) {
			[root release];
			return [[n attributeForName:@"source"] stringValue];
		}
	}
	
	[root release];
	return nil;
}


- (NSXMLElement*)callMethod:(NSString*)method params:(NSString*)params
{
	NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=%@&api_key=9b4439ce94de7e2ec2c2e6ffadc22bcf&%@", method, params]];
	NSXMLDocument* doc = [[NSXMLDocument alloc] initWithContentsOfURL:url options:0 error:nil];
	NSXMLElement* root = [(NSXMLElement*)[doc rootElement] retain];
	
	// Flickr service error?
	if([[[root attributeForName:@"stat"] stringValue] compare:@"fail" options:0] == 0)
	{
		NSLog(@"Couldn't connect to flickr. Retrying in 5 seconds...");
		sleep(5);
		return nil;
	}
	
	return root;
}


-(NSImage*)nextImage
{
	// Would be nice to handle "to small images" right here
	NSURL* url = (NSURL *)[urls take];
	DLog(@"%@", url);
	return [[NSImage alloc] initWithContentsOfURL:url];
}


- (void)addURLsThread:(id)o
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	@try
	{
		while(1)
			[self addURLs];
	}
	@catch(NSException* e)
	{
		NSTrace(@"FATAL: %@ -- provider disabled", e);
		[self setActive:NO];
	}
	@finally
	{
		[pool release];
	}
}


- (void)addURLs
{
	// Wait here until activated
	[activeCondLock lockWhenCondition:TRUE];
	[activeCondLock unlock];
	
	NSXMLElement* root = [self callMethod:@"flickr.favorites.getPublicList" 
											 params:@"user_id=12281432@N00&per_page=999&extras=date_taken"];
	
	if(!root)
		return;
	
	// Find photos
	NSError* err = nil;
	NSArray* children = [root nodesForXPath:@"/rsp/photos/photo" error:&err];
	if(err) // TODO: test and fix
		NSLog(@"Error: %@", err);
	
	NSAssert(children != nil, @"children is nil");
	
	// Random, please
	id oldChildren = children;
	children = [[children randomCopy] retain];
	[oldChildren release];
	
	// Add URLs
	NSEnumerator* it = [children objectEnumerator];
	NSXMLElement* n;
	NSString* urlString;
	while (n = (NSXMLElement*)[it nextObject])
	{
		// Wait here until activated
		[activeCondLock lockWhenCondition:TRUE];
		[activeCondLock unlock];
		
		// Build url
		urlString = [self urlForSize: [[n attributeForName:@"id"] stringValue] 
									 //size: @"Medium"];
										size: @"Large"];
		if(urlString) {
			[urls put:[NSURL URLWithString:urlString]];
			DLog(@"Queued %@", urlString);
		}
		else
			DLog(@"Image was too small");
	}
	
	// Sure shots:
	//[urls addObject:[NSURL URLWithString:@"http://static.flickr.com/90/245707482_620b878566_b.jpg"]];
	//[urls addObject:[NSURL URLWithString:@"http://static.flickr.com/79/270773771_43fea70d2b_b.jpg"]];
	//[urls addObject:[NSURL URLWithString:@"http://static.flickr.com/96/207296186_07c83ed2fa_b.jpg"]];
	//[urls addObject:[NSURL URLWithString:@"http://static.flickr.com/90/245707482_620b878566_b.jpg"]];
	
}

@end
