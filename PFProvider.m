#import "PFProvider.h"

@implementation PFProvider

-(NSURL*)getURL
{
	NSLog(@"[%@ getURL] Not implemented - you called a object of class PFProvider which is abstract", self);
	throw_ex(@"PFProviderException", @"getURL method is abstract and not overridden");
	return nil;
}

@end
