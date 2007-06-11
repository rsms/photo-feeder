

#import <QuartzCore/QuartzCore.h>

@interface PFImage : NSObject
{
	CVPixelBufferRef cgImage;
}

-(id)initWithImageRef:(CVPixelBufferRef)im;
-(CVPixelBufferRef)cgImage;

@end
