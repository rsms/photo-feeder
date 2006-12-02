
#import <OpenGL/gl.h>
#import <OpenGL/glext.h>
#import <OpenGL/glu.h>

@interface PFImage : NSObject {
	
	GLubyte         *data;
	GLuint          texture;
	
	PFRect			bounds;
	PFMovingType	movingType;
	
	float			stepSize;
	int				stepsLeft;
	int				stepCount;
}


+ (PFImage*) imageWithContentsOfURL:(NSURL*)url;
- (id) initWithData:(unsigned char *)data w:(int)w h:(int)h components:(int)components hasAlpha:(BOOL)hasA;

- (GLubyte*) data;
- (GLuint) texture;
- (PFRect) bounds;
- (PFMovingType) movingType;
- (float) stepSize;
- (int) stepsLeft;
- (int) stepCount;

@end
