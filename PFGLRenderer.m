

#import "PFGLRenderer.h"


@implementation PFGLRenderer


+ (PFGLRenderer*) newRenderer
{
	NSOpenGLPixelFormat *format;
	NSOpenGLPixelFormatAttribute attributes[] = { 
		NSOpenGLPFAAccelerated,
		NSOpenGLPFANoRecovery,
		NSOpenGLPFADepthSize, 16, // we may not need this for 2D
		NSOpenGLPFAColorSize, 32,
	0};
	format = [[[NSOpenGLPixelFormat alloc] initWithAttributes:attributes] autorelease];
	return [[[self class] alloc] initWithFrame:NSZeroRect pixelFormat:format];
}


- (void)prepare
{
	[[self openGLContext] makeCurrentContext];
	NSLog(@"[%@ prepareOpenGL] context: %x", self, [self openGLContext]);
	
    // Enable beam-synced updates
	long parm = 1;
    [[self openGLContext] setValues: &parm
					   forParameter: NSOpenGLCPSwapInterval];
	
    // Make sure that things we don't need are disabled. Some of
	// these are enabled by default and can slow down rendering
    glDisable (GL_ALPHA_TEST);
    glDisable (GL_DEPTH_TEST);
    glDisable (GL_SCISSOR_TEST);
    glDisable (GL_BLEND);
    glDisable (GL_DITHER);
    glDisable (GL_CULL_FACE);
    glColorMask (GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
    glDepthMask (GL_FALSE);
    glStencilMask (0);
    glClearColor (0.0f, 0.0f, 0.0f, 0.0f);
    glHint (GL_TRANSFORM_HINT_APPLE, GL_FASTEST);
}


- (void)setFrameSize:(NSSize)newSize
{  
	NSLog(@"-- setFrameSize");
	[super setFrameSize:newSize];
	//[renderer setFrameSize:newSize];
	
	[[self openGLContext] makeCurrentContext];
	
	NSRect  visibleRect = [self visibleRect];
	glViewport(0, 0, visibleRect.size.width, visibleRect.size.height);
	
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrtho(visibleRect.origin.x,
			visibleRect.origin.x + visibleRect.size.width,
			visibleRect.origin.y,
			visibleRect.origin.y + visibleRect.size.height,
			-1, 1);
	
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	
	
	// Reshape 3D
	/*glViewport( 0, 0, (GLsizei)newSize.width, (GLsizei)newSize.height );
	glMatrixMode( GL_PROJECTION );
	glLoadIdentity();
	gluPerspective( 45.0f, (GLfloat)newSize.width / (GLfloat)newSize.height, 0.1f, 100.0f );
	glMatrixMode( GL_MODELVIEW );
	glLoadIdentity();*/
}


- (BOOL)isOpaque {
	return NO;
}

@end
