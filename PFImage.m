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
#import "PFImage.h"


@implementation PFImage

- (PFImage*) initWithGLImage:(PFGLImage *)im
{
	[self setGLImage:im];
	return self;
}


- (void) moveOneStep
{
	if(movingType == PFMovingTypeHorizontally)
		sourceRect.origin.x += stepSize;
	else if(movingType == PFMovingTypeVertically)
		sourceRect.origin.y += stepSize;
	stepsLeft--;
}


- (void) setupAnimation:(PFMovingType)moveType 
			   stepSize:(float)ss 
			  stepCount:(int)sc 
			 sourceRect:(NSRect)sr
{
	movingType = moveType;
	stepSize = ss;
	stepCount = sc;
	stepsLeft = stepCount;
	sourceRect = sr;
}


- (void) setGLImage:(PFGLImage *)im
{
	PFGLImage *old = glImage;
	
	glImage = [im retain];
	bounds = [glImage bounds];
	
	if(old)
		[old release];
}

- (PFGLImage *) glImage { return glImage; }

- (NSRect) bounds { return bounds; }
- (NSRect) sourceRect { return sourceRect; }
- (PFMovingType) movingType { return movingType; }

- (float) stepSize { return stepSize; }
- (int) stepsLeft { return stepsLeft; }
- (int) stepCount { return stepCount; }

@end
