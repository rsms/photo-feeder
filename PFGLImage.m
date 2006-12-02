#import "PFGLImage.h"

@interface PFGLImage (Private)
- (void) _loadTexture:(NSBitmapImageRep *)bmp;
@end


@implementation PFGLImage



#pragma mark -- Creating the image

/**
 * @returns Allocated, but unloaded, PFGLImage or nil if it failed to load or parse image.
 */
- (id) initWithContentsOfFile:(NSString*)path
{
	NSData* d = [NSData dataWithContentsOfFile:path];
	if(!d) {
		NSLog(@"[%@ initWithContentsOfFile:] Failed to read file '%@'", self, path);
		return nil;
	}
	return [self initWithData:d];
}


/**
 * @returns Allocated, but unloaded, PFGLImage or nil if it failed to load or parse image.
 */
- (id) initWithContentsOfURL:(NSURL*)url
{
	NSData* d = [NSData dataWithContentsOfURL:url];
	if(!d) {
		NSLog(@"[%@ initWithContentsOfURL:] Failed to read URL '%@'", self, url);
		return nil;
	}
	return [self initWithData:d];
}


/**
 * @returns Allocated, but unloaded, PFGLImage or nil if it failed to parse image data.
 */
- (id) initWithData:(NSData*)data
{
	if(!data) {
		NSLog(@"[%@ initWithContentsOfData:] data is nil", self);
		return nil;
	}
	
	NSBitmapImageRep* bmp = [NSBitmapImageRep imageRepWithData:data];
	if(!bmp) {
		NSLog(@"[%@ initWithContentsOfData:] Failed to load image data", self);
		return nil;
	}
	
	self = [super init];
	size = [bmp size];
	[self _loadTexture:bmp];
	return self;
}


- (void) _loadTexture:(NSBitmapImageRep *)bmp
{
	texType = GL_TEXTURE_RECTANGLE_EXT;
	
	glDisable(GL_TEXTURE_2D);
	glEnable(texType);
	
	// allocate & bind the texture
	glGenTextures(1, &texId);
	glBindTexture(texType, texId);
	
	// Apple says these two speed things up:
	//glTexParameteri(texType, GL_TEXTURE_STORAGE_HINT_APPLE , GL_STORAGE_CACHED_APPLE);
	//glPixelStorei(GL_UNPACK_CLIENT_STORAGE_APPLE, GL_TRUE);
	
	// Activate = alias pixels
	//glTexParameteri(texType, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	//glTexParameteri(texType, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	
	
	// Bytes in one row + "pad bytes" (for example when using word-boundary steps; GL_UNPACK_ALIGNMENT=8)
	glPixelStorei(GL_UNPACK_ROW_LENGTH, [bmp bytesPerRow] / ([bmp bitsPerPixel] >> 3));
	
	/* GL_UNPACK_ALIGNMENT
	   Specifies the alignment requirements for the start of each pixel row in memory. 
		The allowable values are 
		1 (byte-alignment), 
		2 (rows aligned to even-numbered bytes), 
		4 (word-alignment), and 
		8 (rows start on double-word boundaries).
	*/
	if( ([bmp bytesPerRow] / ([bmp bitsPerPixel] >> 3)) == size.width ) {
		glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
	}
	else {
		glPixelStorei(GL_UNPACK_ALIGNMENT, 8);
	}
	//glPixelStorei(GL_UNPACK_IMAGE_HEIGHT, height);
	
	DLog(@"size: %d x %d", size.width, size.height);
	DLog(@"bitmapFormat: %d", [bmp bitmapFormat]);
	DLog(@"bitsPerPixel: %d", [bmp bitsPerPixel]);
	DLog(@"bytesPerPlane: %d", [bmp bytesPerPlane]);
	DLog(@"bytesPerRow: %d", [bmp bytesPerRow]);
	DLog(@"isPlanar: %d", [bmp isPlanar]);
	DLog(@"numberOfPlanes: %d", [bmp numberOfPlanes]);
	DLog(@"samplesPerPixel: %d", [bmp samplesPerPixel]);
	
	// TODO: Solve CMYK input problem - color order is not RGB or BGR
	GLenum inputDataFormat = 0;
	switch([bmp samplesPerPixel]) {
		case 4:
			/*if(!([bmp bitmapFormat] & NSAlphaFirstBitmapFormat))
				inputDataFormat = GL_BGRA;
			else*/
				inputDataFormat = GL_RGBA;
			break;
		case 3:
			inputDataFormat = GL_RGB;
			break;
		case 1:
			inputDataFormat = GL_LUMINANCE;
			break;
		default:
			NSLog(@"Unknown input data format!");
			return;
	}
	
	glTexImage2D( texType, 0, GL_RGBA, size.width, size.height, 0, inputDataFormat, GL_UNSIGNED_BYTE, (GLubyte*)[bmp bitmapData] );
}



#pragma mark -- Drawing the image


- (void) drawInRect:(NSRect)dstRect sourceRect:(NSRect)srcRect
{
	glBindTexture(texType, texId);
	glBegin(GL_QUADS);
	
	// BL
	glTexCoord2f(srcRect.origin.x, srcRect.size.height);
	glVertex2f(dstRect.origin.x, dstRect.origin.y);
	
	// TL
	glTexCoord2f(srcRect.origin.x, srcRect.origin.y);
	glVertex2f(dstRect.origin.x, dstRect.size.height);
	
	// TR
	glTexCoord2f(srcRect.size.width, srcRect.origin.y);
	glVertex2f(dstRect.size.width, dstRect.size.height);
	
	// BR
	glTexCoord2f(srcRect.size.width, srcRect.size.height);
	glVertex2f(dstRect.size.width, dstRect.origin.y);
	
	glEnd();
}


- (void) drawInRect:(NSRect)rect
{
	[self drawInRect:rect sourceRect:NSMakeRect(0.0f, 0.0f, size.width, size.height)];
}


- (void) draw
{
	[self drawInRect:[[[NSOpenGLContext currentContext] view] bounds]];
}



#pragma mark -- Getting image properties

- (NSSize) size
{
	return size;
}

- (GLuint) textureId
{
	return texId;
}

- (GLenum) textureType
{
	return texType;
}



@end
