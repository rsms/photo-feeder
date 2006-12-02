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
