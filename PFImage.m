#import "PFImage.h"

#include <QuickTime/ImageCompression.h> // for image loading and decompression
#include <QuickTime/QuickTimeComponents.h> // for file type support


/*static GLuint LoadTextureRAW( const char * filename, int wrap )
{
    GLuint texture;
    int width, height;
    unsigned char * data;
    int * file;
	
    // open texture data
    file = fopen( filename, "rb" );
    if ( file == NULL ) return 0;
	
    // allocate buffer
    width = 231;
    height = 100;
    data = malloc( width * height * 3 );
	
    // read texture data
    fread( data, width * height * 3, 1, file );
    fclose( file );
	
    // allocate a texture name
    glGenTextures( 1, &texture );
	
    // select our current texture
    glBindTexture( GL_TEXTURE_2D, texture );
	
    // select modulate to mix texture with color for shading
    glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
	
    // when texture area is small, bilinear filter the closest mipmap
    glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,
                     GL_LINEAR_MIPMAP_NEAREST );
    // when texture area is large, bilinear filter the first mipmap
    glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
	
    // if wrap is true, the texture wraps over at the edges (repeat)
    //       ... false, the texture ends at the edges (clamp)
    glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S,
                     wrap ? GL_REPEAT : GL_CLAMP );
    glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T,
                     wrap ? GL_REPEAT : GL_CLAMP );
	
    // build our texture mipmaps
    gluBuild2DMipmaps( GL_TEXTURE_2D, 3, width, height,
                       GL_RGB, GL_UNSIGNED_BYTE, data );
	
    // free buffer
    free( data );
	
    return texture;
}*/




@implementation PFImage

+ (PFImage*) imageWithContentsOfURL:(NSURL*)url
{
	/*NSBitmapImageRep* im = (NSBitmapImageRep*)[NSImageRep imageRepWithContentsOfURL:url];
	return [[PFImage alloc] initWithData:[im bitmapData] 
									   w:[im size].width 
									   h:[im size].height 
							  components:[im samplesPerPixel]
								hasAlpha:[im hasAlpha]];*/
	
	NSBitmapImageRep* im = [NSBitmapImageRep imageRepWithData:[NSData dataWithContentsOfURL:url]];
	[im retain];
	return [[PFImage alloc] initWithData:[im bitmapData] 
									   w:[im size].width 
									   h:[im size].height 
							  components:[im samplesPerPixel]
								hasAlpha:[im hasAlpha]];
	
	/*CFDictionaryRef options = CFDictionaryCreate( NULL, NULL, NULL, 0, NULL, NULL );
	
	CFURLRef url = CFURLCreateWithFileSystemPath( NULL, (CFStringRef)"/Users/rasmus/Desktop/bild_1024.jpg", kCFURLPOSIXPathStyle, 0 );
	CGImageSourceRef isrc = CGImageSourceCreateWithURL( url, options );
	CFRelease( url );
	CGImageRef im = CGImageSourceCreateImageAtIndex( isrc, 0, options );
	
	
	CGImageGetDataProvider(im);
	
	CFRelease( options );
	
	
	return [[PFImage alloc] initWithData:[im bitmapData] 
									   w:[im size].width 
									   h:[im size].height 
							  components:[im samplesPerPixel]
								hasAlpha:[im hasAlpha]];*/
}


- (id) initWithData:(unsigned char *)data w:(int)w h:(int)h components:(int)components hasAlpha:(BOOL)hasA
{
	GLenum bpp = hasA ? GL_RGBA : GL_RGB;
	
	
	/*
	// 1
	// allocate a texture name
	glGenTextures( 1, &texture );
	
    // select our current texture
	glBindTexture( GL_TEXTURE_2D, texture );
	
    // select modulate to mix texture with color for shading
    //glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
	
    // when texture area is small, bilinear filter the closest mipmap
    //glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_NEAREST );
	
    // when texture area is large, bilinear filter the first mipmap
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
	
	// http://www.mevis.de/opengl/glTexImage2D.html
	DLog(@"[PFImage initWithData] components: %d", components);
	glTexImage2D( GL_TEXTURE_2D, 0, components, w, h, 0, GL_RGB, GL_UNSIGNED_BYTE, data );
	*/
	
	
	/*
	// 2
	texture = LoadTextureRAW("/Users/rasmus/Desktop/Picture1.raw", 0);
	*/
	
	
	/*
	// 3
	// allocate a texture name
    glGenTextures( 1, &texture );
	
    // select our current texture
    glBindTexture( GL_TEXTURE_RECTANGLE_EXT, texture );
	
	glTexParameteri( GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
	
    // build our texture mipmaps
	gluBuild2DMipmaps( GL_TEXTURE_RECTANGLE_EXT, GL_RGB, w, h, bpp, GL_UNSIGNED_BYTE, data );
	//glTexImage2D( GL_TEXTURE_2D, 0, GL_RGB, w, h, 0, bpp, GL_UNSIGNED_BYTE, data );
	*/
	
	
	GLubyte *dat = (GLubyte *) malloc(w * h * (/*IMAGE_DEPTH*/32 >> 3));
	[self loadBufferFromImageFile:@"/Users/rasmus/Desktop/bild_1000.jpg"
							 data:dat
							width:1000
						   height:1000
					   pixelDepth:/*IMAGE_DEPTH*/32];
	
	
	
	// 4
	glDisable(GL_TEXTURE_2D);
	glEnable(GL_TEXTURE_RECTANGLE_EXT);
	glBindTexture(GL_TEXTURE_RECTANGLE_EXT, texture);
	
	// (fast) glTexParameteri(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_STORAGE_HINT_APPLE , GL_STORAGE_CACHED_APPLE);
	// (fast) glPixelStorei(GL_UNPACK_CLIENT_STORAGE_APPLE, GL_TRUE);
	glTexParameteri( GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri( GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri( GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri( GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glPixelStorei( GL_UNPACK_ROW_LENGTH, 0);
	
	glTexImage2D( GL_TEXTURE_RECTANGLE_EXT, 0, GL_RGB, w, h, 0, bpp, GL_UNSIGNED_BYTE, dat);
	
	data = dat;
	
	// Save size
	bounds = PFRectMake(0,0,w,h);
	
	return self;
}



- (void) loadBufferFromImageFile:(NSString*)path
							data:(GLubyte *)imagePtr
						   width:(GLuint)imageWidth
						  height:(GLuint)imageHeight
					  pixelDepth:(GLuint)imageDepth
{
	CFURLRef url;
 	FSRef fsRef;
	BOOL ok;
	GWorldPtr pGWorld = NULL;
	OSType pixelFormat;
	FSSpec fsspecImage;
	long rowStride; // length, in bytes, of a pixel row in the image
	GraphicsImportComponent giComp; // componenet for importing image
	Rect rectImage; // rectangle of source image
    ImageDescriptionHandle hImageDesc; // handle to image description used to get image depth
    MatrixRecord matrix;
	GDHandle origDevice; // save field for current graphics device
	CGrafPtr origPort; // save field for current graphics port
	OSStatus err = noErr; // err return value
	long origImageWidth, origImageHeight;
	
	url = CFURLCreateWithFileSystemPath(NULL, (CFStringRef) path, kCFURLPOSIXPathStyle, false);
	if(!url) return;
	
	ok = CFURLGetFSRef(url, &fsRef);
	CFRelease(url);
	if(!ok) return;
	
	err = FSGetCatalogInfo(&fsRef, kFSCatInfoNone, NULL, NULL, &fsspecImage, NULL);
	if(err) return;
	
	// get imorter for the image tyoe in file
	GetGraphicsImporterForFile (&fsspecImage, &giComp);
    if (err != noErr) return;
	
	// Create GWorld
    err = GraphicsImportGetNaturalBounds (giComp, &rectImage); //get the image bounds
    if (err != noErr) return;
	
    hImageDesc = (ImageDescriptionHandle) NewHandle (sizeof (ImageDescriptionHandle)); // create a handle for the image description
    HLock ((Handle) hImageDesc); // lock said handle
    err = GraphicsImportGetImageDescription (giComp, &hImageDesc); // retrieve the image description
    if (err != noErr) return;
	
    origImageWidth = (long) (rectImage.right - rectImage.left); // find width from right side - left side bounds
    origImageHeight = (long) (rectImage.bottom - rectImage.top); // same for height
	if (imageDepth <= 16) // we are using a 16 bit texture for all images 16 bits or less
	{
		imageDepth = 16;
		pixelFormat = k16BE555PixelFormat;
	}
    else // otherwise
	{
		imageDepth = 32;
		pixelFormat = k32ARGBPixelFormat;
	}
	
	SetRect (&rectImage, 0, 0, (short) imageWidth, (short) imageHeight); // l, t, r. b  set image rectangle for creation of GWorld
	rowStride = imageWidth * (imageDepth >> 3); // set stride in bytes width of image * pixel depth in bytes
	
	// create a new gworld using our unpadded buffer, ensure we set the pixel type correctly for the expected image bpp
	QTNewGWorldFromPtr (&pGWorld, pixelFormat, &rectImage, NULL, NULL, 0, imagePtr, rowStride); 
	if (NULL == pGWorld)
	{
		CloseComponent(giComp);
		return;
    }
    
	GetGWorld (&origPort, &origDevice); // save onscreen graphics port
	// decompress (draw) to gworld and thus fill buffer
    SetIdentityMatrix (&matrix); // set transform matrix to identity (basically pass thorugh)
	// this scale really only does something the case of non-tiled textures to inset them one pixel 
	//  thus maintaining the power of 2 (or desired) dimension of the overall texture
	ScaleMatrix (&matrix, X2Fix ((float) (imageWidth) / (float) origImageWidth), 
				 X2Fix ((float) (imageHeight) / (float) origImageHeight), 
				 X2Fix (0.0), X2Fix (0.0));
	// inset texture size to image size and offset by 1 pixel into the image so the 
	//  decompression puts the image into to center of the pixmap inset by one on each side
	TranslateMatrix (&matrix, X2Fix (0.0), X2Fix (0.0)); // step in for border
	err = GraphicsImportSetMatrix(giComp, &matrix); // set our matrix as the importer matrix
    if (err == noErr)
		err = GraphicsImportSetGWorld (giComp, pGWorld, NULL); // set the destination of the importer component
	if (err == noErr)
		err = GraphicsImportSetQuality (giComp, codecLosslessQuality); // we want lossless decompression
	if ((err == noErr) && GetGWorldPixMap (pGWorld) && LockPixels (GetGWorldPixMap (pGWorld)))
		GraphicsImportDraw (giComp); // if everything looks good draw image to locked pixmap
	else
	{
    	DisposeGWorld (pGWorld); // dump gworld
    	pGWorld = NULL;
		CloseComponent(giComp); // dump component
        return;
    }
	UnlockPixels (GetGWorldPixMap (pGWorld)); // unlock pixels
	CloseComponent(giComp); // dump component
	SetGWorld(origPort, origDevice); // set current graphics port to offscreen
	// done with gworld and image since they are loaded to a texture
	DisposeGWorld (pGWorld); // do not need gworld
	pGWorld = NULL;
}



- (GLubyte*) data { return data; }
- (GLuint) texture { return texture; }
- (PFRect) bounds { return bounds; }
- (PFMovingType) movingType { return movingType; }
- (float) stepSize { return stepSize; }
- (int) stepsLeft { return stepsLeft; }
- (int) stepCount { return stepCount; }

@end
