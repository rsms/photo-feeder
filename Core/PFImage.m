#import "PFImage.h"

@implementation PFImage

-(id)initWithImageRef:(CVPixelBufferRef)im
{
	self = [super init];
	cgImage = im;
	return self;
}

-(CVPixelBufferRef)cgImage
{
	return cgImage;
}

@end
