/*
 * PhotoFeeder is the legal property of its developers.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version. You should have received a copy 
 * of the GNU General Public License along with this program; if not, 
 * write to the Free Software Foundation, Inc., 59 Temple Place, 
 * Suite 330, Boston, MA 02111-1307 USA
 */
#import "PFGLRenderer.h"

#import <OpenGL/gl.h>
#import <OpenGL/glext.h>
#import <OpenGL/glu.h>

@implementation PFGLRenderer

- (PFGLRenderer*) initWithDefaultPixelFormat
{
	DLog(@"");
	
	// Setup the default renderer attributes. We don't want any fancy stuff,
	// just the basics things for displaying images in 2D
	NSOpenGLPixelFormatAttribute attrs[] = {
		NSOpenGLPFANoRecovery,
		NSOpenGLPFADoubleBuffer,
		NSOpenGLPFAAccelerated,
		NSOpenGLPFADepthSize, 24,
		(NSOpenGLPixelFormatAttribute) 0
	};
	
	if( !(pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs]) )
	{
		NSTrace(@"Failed to aquire pixel format!");
		return nil;
	}
	
	self = [super initWithFrame:NSZeroRect pixelFormat:pixelFormat];
	
	return self;
}


- (void) setupQCRenderer
{
	//Create the QuartzComposer Renderer with that OpenGL context and the transition composition file
	qcRenderer = [[QCRenderer alloc] initWithOpenGLContext: [self openGLContext]
															 pixelFormat: pixelFormat
																	  file: [[NSBundle mainBundle] pathForResource:@"renderer" ofType:@"qtz"]];
	if(qcRenderer == nil)
	{
		NSLog(@"Cannot create QCRenderer");
		[NSApp terminate:nil];
	}
}


- (void) dealloc
{
	[qcRenderer release];
	[super dealloc];
}


- (QCRenderer*) qcRenderer
{
	return qcRenderer;
}


/*- (void) reshape	// scrolled, moved or resized
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
}*/


- (BOOL)isOpaque {
	return YES;
}

@end