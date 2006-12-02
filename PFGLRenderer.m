#import "PFGLRenderer.h"

#import <OpenGL/gl.h>
#import <OpenGL/glext.h>
#import <OpenGL/glu.h>

@implementation PFGLRenderer

+ (PFGLRenderer*) newRenderer {
	// Setup the default renderer attributes. We don't want any fancy stuff,
	// just the basics things for displaying images in 2D
	NSOpenGLPixelFormatAttribute attributes[] = { 
		NSOpenGLPFAAccelerated,
		NSOpenGLPFANoRecovery,
		NSOpenGLPFADoubleBuffer,
		//NSOpenGLPFAColorSize, 24,
		0};
	
	// Setup the pixel format with the above specified attributes 
	NSOpenGLPixelFormat *format = [[[NSOpenGLPixelFormat alloc] initWithAttributes:attributes] autorelease];
	
	return [[[self class] alloc] initWithFrame: NSZeroRect
								   pixelFormat: format];
}


- (void)reshape	// scrolled, moved or resized
{
	NSRect rect;
	
	[super reshape];
	
	[[self openGLContext] makeCurrentContext];
	[[self openGLContext] update];
	
	rect = [self bounds];
	
	glViewport(0, 0, (int)rect.size.width, (int)rect.size.height);
	
	/*glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
	
	glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();*/
	
	[self setNeedsDisplay:true];
}


- (void)prepare {
	[[self openGLContext] makeCurrentContext];
	
	glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
	glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
	
	
	
    // Enable beam-synced updates
	/*long parm = 1;
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
	
	glEnable(GL_TEXTURE_RECTANGLE_EXT);*/
	
	
	/*
	NeHe:
	
	glEnable(GL_TEXTURE_2D);						// Enable Texture Mapping ( NEW )
	glShadeModel(GL_SMOOTH);						// Enable Smooth Shading
	glClearColor(0.0f, 0.0f, 0.0f, 0.5f);					// Black Background
	glClearDepth(1.0f);							// Depth Buffer Setup
	glEnable(GL_DEPTH_TEST);						// Enables Depth Testing
	glDepthFunc(GL_LEQUAL);							// The Type Of Depth Testing To Do
	glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);			// Really Nice Perspective Calculations
	return TRUE;								// Initialization Went OK
	*/
	
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