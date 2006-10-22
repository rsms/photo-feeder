#import <QuartzCore/QuartzCore.h>

enum {
	PFMovingTypeHorizontally,
	PFMovingTypeVertically,
	PFMovingTypeNone
};

typedef int PFMovingType;

typedef struct {
	CIImage *		im;
	CGSize			size;
	CGPoint			position;
	PFMovingType	movingType;
	float			stepSize;
	int				stepsLeft;
} PFImage;

static PFImage PFImageCreate(CIImage *im,
							 PFMovingType type,
							 float pixelsScreenCantShow,
							 float timeVisible,
							 float basedOnFPS) {
	PFImage i;
	i.im = [im retain];
	i.size = [i.im extent].size;
	i.movingType = type;
	i.stepSize = 1.0 / ((timeVisible * basedOnFPS) / (int)pixelsScreenCantShow);
	i.stepsLeft = timeVisible * basedOnFPS;
	
	return i;
}

static void PFImageRelease(PFImage i) {
	if(i.im)
		[i.im release];
}

static int PFImageIsValid(PFImage i) {
	return i.im ? 1 : 0;
}
