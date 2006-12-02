@interface PFGLRenderer : NSOpenGLView {
	BOOL viewHasBeenReshaped;
}

- (PFGLRenderer*) initWithDefaultPixelFormat;

@end
