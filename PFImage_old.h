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
	int				stepCount;
} PFImage;

static PFImage PFImageCreate(CIImage *im,
							 PFMovingType type,
							 float sizeOutsideScreen,
							 float timeVisible,
							 float basedOnFPS) {
	
	//DLog(@"PFImageCreate: creating i.im retainCount: %u", [im retainCount]);
	
	PFImage i;
	i.im = im;
	i.size = [i.im extent].size;
	i.movingType = type;
	i.stepSize = 1.0 / ((timeVisible * basedOnFPS) / (int)sizeOutsideScreen);
	i.stepsLeft = timeVisible * basedOnFPS;
	i.stepCount = i.stepsLeft;
	
	return i;
}

static void PFImageMoveOneStep(PFImage* i) {
	if(i->movingType == PFMovingTypeHorizontally)
		i->position.x += i->stepSize;
	else if(i->movingType == PFMovingTypeVertically)
		i->position.y += i->stepSize;
	i->stepsLeft--;
}

static void PFImageRelease(PFImage i) {
	if(i.im) {
		//DLog(@"PFImageRelease: releasing i.im: %@, retainCount: %u", i.im, [i.im retainCount]);
		[i.im release];
	}
}

static int PFImageIsValid(PFImage i) {
	return i.im ? 1 : 0;
}
