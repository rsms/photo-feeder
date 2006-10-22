#import <QuartzCore/QuartzCore.h>

typedef struct {
	CIImage *	im;
	CGSize		size;
	CGPoint		position;
	BOOL		movingHorizontally;
} PFImage;

static PFImage PFImageCreate(CIImage *im) {
	PFImage i;
	i.im = [im retain];
	i.size = [i.im extent].size;
	return i;
}

static void PFImageRelease(PFImage i) {
	if(i.im)
		[i.im release];
}

static int PFImageIsValid(PFImage i) {
	return i.im ? 1 : 0;
}
