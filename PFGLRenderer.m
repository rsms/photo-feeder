#import "PFGLRenderer.h"

#import <OpenGL/gl.h>
#import <OpenGL/glext.h>
#import <OpenGL/glu.h>

@implementation PFGLRenderer

- (PFGLRenderer*) initWithDefaultPixelFormat
{
	DLog(@"");
	NSOpenGLPixelFormat *pixFmt;
	
	// Setup the default renderer attributes. We don't want any fancy stuff,
	// just the basics things for displaying images in 2D
	NSOpenGLPixelFormatAttribute attrs[] = {
		NSOpenGLPFAAccelerated,
		NSOpenGLPFANoRecovery,
		NSOpenGLPFAColorSize, 32,
		0
	};
	
	if( !(pixFmt = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs]) )
	{
		NSTrace(@"Failed to aquire pixel format!");
		return nil;
	}
	
	self = [super initWithFrame:NSZeroRect pixelFormat:pixFmt];
	[[self openGLContext] makeCurrentContext];
	
	// Setup some basic OpenGL stuff
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
	
	return self;
}


- (void) reshape	// scrolled, moved or resized
{
	[super reshape];
	DLog(@"");
	
	NSRect rect = [self bounds];
	glViewport(0, 0, (int) rect.size.width, (int) rect.size.height);
	
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	
	glOrtho(rect.origin.x,
			rect.origin.x + rect.size.width,
			rect.origin.y,
			rect.origin.y + rect.size.height,
			-1, 1);
	
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	
	[self setNeedsDisplay:YES];
}


- (void)setFrameSize:(NSSize)newSize
{  
	[super setFrameSize: newSize];
	DLog(@"");
	
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