#import "PFGLImage.h"

@interface PFGLImage (Private)
/**
 * Load data onto a texture.
 * @return Success
 */
- (BOOL) _loadTexture:(NSBitmapImageRep *)bmp;
@end


@implementation PFGLImage

// Extension which allows for non-power-by-2 iamges to be 
// natively loaded by the GPU.
static GLenum texType = GL_TEXTURE_RECTANGLE_EXT;


#pragma mark -- Creating the image

/**
 * @returns Allocated, but unloaded, PFGLImage or nil if it failed to load or parse image.
 */
- (id) initWithContentsOfFile:(NSString*)path
{
	NSData* d = [NSData dataWithContentsOfFile:path];
	if(!d) {
		NSTrace(@"Failed to read file '%@'", path);
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
		NSTrace(@"Failed to read URL '%@'", url);
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
		NSTrace(@"data is nil");
		return nil;
	}
	
	NSBitmapImageRep* bmp = [NSBitmapImageRep imageRepWithData:data];
	if(!bmp) {
		NSTrace(@"Failed to load image data");
		return nil;
	}
	
	self = [super init];
	size = [bmp size];
	if( ![self _loadTexture:bmp]) {
		NSTrace(@"Failed to create OpenGL texture");
		return nil;
	}
	return self;
}


// TODO: Add tighter error-handling
- (BOOL) _loadTexture:(NSBitmapImageRep *)bmp
{
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
	
	// Dump image info if debug mode
	IFDEBUG(
		DLog(@"Image info:");
		NSString* bmpFmt = @"";
		if([bmp bitmapFormat] & NSAlphaFirstBitmapFormat)
			bmpFmt = @"NSAlphaFirstBitmapFormat ";
		if([bmp bitmapFormat] & NSAlphaNonpremultipliedBitmapFormat)
			bmpFmt = [bmpFmt stringByAppendingString:@"NSAlphaNonpremultipliedBitmapFormat "];
		if([bmp bitmapFormat] & NSFloatingPointSamplesBitmapFormat)
			bmpFmt = [bmpFmt stringByAppendingString:@"NSFloatingPointSamplesBitmapFormat"];
		fprintf(stderr,"  size:            %.0f, %.0f\n", size.width, size.height);
		fprintf(stderr,"  bitmapFormat:    %s\n", [bmpFmt cString]);
		fprintf(stderr,"  bitsPerPixel:    %d\n", [bmp bitsPerPixel]);
		fprintf(stderr,"  bytesPerPlane:   %d\n", [bmp bytesPerPlane]);
		fprintf(stderr,"  bytesPerRow:     %d\n", [bmp bytesPerRow]);
		fprintf(stderr,"  isPlanar:        %s\n", [bmp isPlanar] ? "YES" : "NO");
		fprintf(stderr,"  numberOfPlanes:  %d\n", [bmp numberOfPlanes]);
		fprintf(stderr,"  samplesPerPixel: %d\n", [bmp samplesPerPixel]);
	);
	
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
			NSTrace(@"Unknown input data format!");
			return NO;
	}
	
	glTexImage2D( texType, 0, GL_RGBA, size.width, size.height, 0, inputDataFormat, GL_UNSIGNED_BYTE, (GLubyte*)[bmp bitmapData] );
	return YES;
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
