#import "PFProvider.h"

@implementation PFProvider

-(NSURL*)getURL
{
	throw_ex(@"PFProviderException", @"[PFProvider getURL] method is abstract and not overridden");
	return nil;
}

@end
