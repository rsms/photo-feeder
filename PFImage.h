
#import "PFGLImage.h"

@interface PFImage : NSObject {
	
	PFGLImage       *glImage;
	
	NSRect			bounds;
	NSRect			sourceRect;
	PFMovingType	movingType;
	float			stepSize;
	int				stepsLeft;
	int				stepCount;
}


- (PFImage*) initWithGLImage:(PFGLImage*)im;

- (void) moveOneStep;
- (void) setupAnimation:(PFMovingType)moveType stepSize:(float)ss stepCount:(int)sc sourceRect:(NSRect)sr;

- (void) setGLImage:(PFGLImage *)im;
- (PFGLImage *) glImage;

- (NSRect) bounds;
- (NSRect) sourceRect;
- (PFMovingType) movingType;

- (float) stepSize;
- (int) stepsLeft;
- (int) stepCount;

@end
