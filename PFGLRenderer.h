@interface PFGLRenderer : NSOpenGLView {
	BOOL viewHasBeenReshaped;
}

+ (PFGLRenderer*)newRenderer;
- (void)prepare;

@end
