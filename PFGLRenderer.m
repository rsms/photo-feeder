#import "PFGLRenderer.h"

#import <OpenGL/gl.h>
#import <OpenGL/glu.h>

@implementation PFGLRenderer

+ (PFGLRenderer*) newRenderer {
	// Setup the default renderer attributes. We don't want any fancy stuff,
	// just the basics things for displaying images in 2D
	NSOpenGLPixelFormatAttribute attributes[] = { 
		NSOpenGLPFAAccelerated,
		NSOpenGLPFANoRecovery,
		NSOpenGLPFAColorSize, 32,
		0};
	
	// Setup the pixel format with the above specified attributes 
	NSOpenGLPixelFormat *format = [[[NSOpenGLPixelFormat alloc] initWithAttributes:attributes] autorelease];
	
	return [[[self class] alloc] initWithFrame: NSZeroRect
								   pixelFormat: format];
}


- (void)prepare {
	[[self openGLContext] makeCurrentContext];
	
    // Enable beam-synced updates
	long parm = 1;
    [[self openGLContext] setValues: &parm
					   forParameter: NSOpenGLCPSwapInterval];
	
    // Make sure that things we don't need are disabled. Some of
	// these are enabled by default and can slow down rendering
    glDisable(GL_ALPHA_TEST);
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_SCISSOR_TEST);
    glDisable(GL_BLEND);
    glDisable(GL_DITHER);
    glDisable(GL_CULL_FACE);
    glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
    glDepthMask(GL_FALSE);
    glStencilMask(0);
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    glHint(GL_TRANSFORM_HINT_APPLE, GL_FASTEST);
}

- (void)setFrameSize:(NSSize)newSize {  
	[super setFrameSize: newSize];
	
	[[self openGLContext] makeCurrentContext];
	
	NSRect visibleRect = [self visibleRect];
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
}


- (BOOL)isOpaque {
	return NO;
}

@end