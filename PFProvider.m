#import "PFProvider.h"

@implementation PFProvider

-(CIImage*)nextImage
{
	throw_ex(@"PFProviderException", @"[PFProvider nextImage] method is abstract and not overridden");
	return nil;
}

@end
