#import <OpenGL/gl.h>
#import <OpenGL/glu.h>

@interface PFGLRenderer : NSOpenGLView {
	BOOL viewHasBeenReshaped;
}

+ (PFGLRenderer*)newRenderer;
- (void)prepare;

@end
