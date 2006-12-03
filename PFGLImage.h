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
#include <OpenGL/gl.h>

/**
 * OpenGL-backed bitmap image stored on the graphic memory.
 * Accepts a vast array of different image formats.
 *
 * <b>Note:</b> You need to have a valid opengl-context when calling one of the 
 *              initWith-methods, since they create a texture on the gmem.
 *
 * @version $Id$
 * @author  Rasmus Andersson
 * @author  Mattias Arrelid
 */
@interface PFGLImage : NSObject
{
	GLuint texId;
	NSRect bounds;
	
	NSBitmapImageRep* _bmp;
}


#pragma mark Creating an image

/**
 * @returns Allocated, but unloaded, PFGLImage or nil if it failed to load or parse image.
 */
- (id) initWithContentsOfFile:(NSString*)path;

/**
 * @returns Allocated, but unloaded, PFGLImage or nil if it failed to load or parse image.
 */
- (id) initWithContentsOfURL:(NSURL*)url;

/**
 * @returns Allocated, but unloaded, PFGLImage or nil if it failed to parse image data.
 */
- (id) initWithData:(NSData*)data;



#pragma mark Drawing the image

- (void) draw;
- (void) drawInRect:(NSRect)rect;
- (void) drawInRect:(NSRect)dstRect sourceRect:(NSRect)srcRect;
- (void) drawAtPoint:(NSPoint)point;
- (void) drawAtPoint:(NSPoint)point sourceRect:(NSRect)srcRect;


#pragma mark Getting image properties

- (NSRect) bounds;
- (GLuint) textureId;
+ (GLenum) textureType;
+ (NSArray*) acceptableFileExtensions;

@end
