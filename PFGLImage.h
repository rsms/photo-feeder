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
	GLenum texType;
	NSSize size;
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


#pragma mark Getting image properties

- (NSSize) size;
- (GLuint) textureId;
- (GLenum) textureType;

@end
