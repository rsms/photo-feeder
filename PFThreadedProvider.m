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
#import "PFThreadedProvider.h"

@implementation PFThreadedProvider

-(id)init
{
	[super init];
	urls = [[[NSMutableArray alloc] init] retain];
	urlsLock = [[[NSConditionLock alloc] initWithCondition:NO_DATA] retain];
	DLog(@"[%@ init] urls: %@", self, urls);
	[NSThread detachNewThreadSelector:@selector(addURLsThread:) 
							 toTarget:self 
						   withObject:nil];
	return self;
}

- (void) dealloc {
	[urls release];
	[urlsLock release];
	[super dealloc];
}


-(NSURL*)getURL
{
	[urlsLock lockWhenCondition:HAS_DATA];
	DLog(@"[%@ getURL]", self);
	
	NSURL* url = (NSURL *)[urls lastObject];
	[urls removeLastObject];
	
	if([urls count] == 0) {
		DLog(@"[%@ getURL] Buffer was emptied", self);
		[urlsLock unlockWithCondition:NO_DATA];
	}
	else
		[urlsLock unlock];
	
	return url;
}

-(void) addURLsThread:(id)o
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	while(1) {
		[urlsLock lockWhenCondition:NO_DATA];
		DLog(@"[%@ addURLsThread] calling [%@ addURLs]...", self, self);
		[self addURLs];
		[urlsLock unlockWithCondition:HAS_DATA];
	}
	[pool release];
}

-(void)addURLs
{
	throw_ex(@"PFProviderException", @"[PFThreadedProvider addURLs] method is abstract and not overridden");
}

@end
