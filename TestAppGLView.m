#import "TestAppGLView.h"

#import <OpenGL/CGLCurrent.h>
#import <OpenGL/CGLContext.h>

@implementation TestAppGLView


- (id) initWithFrame:(NSRect)frameRect
{
	DLog(@"");
	
	NSOpenGLPixelFormat* pixFmt;
	
	// Setup pixel format
	NSOpenGLPixelFormatAttribute attrs[] = {
		NSOpenGLPFAAccelerated,
		NSOpenGLPFANoRecovery,
		NSOpenGLPFAColorSize, 32,
		0
	};
	
	if( !(pixFmt = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs]) )
	{
		NSLog(@"Failed to aquire pixel format!", self);
		return nil;
	}
	
	self = [super initWithFrame:frameRect pixelFormat:pixFmt];
	[[self openGLContext] makeCurrentContext];
	
	
	// Setup some basic OpenGL stuff
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
	
	return self;
}


- (void) dealloc
{
	[image release];
	[super dealloc];
}


- (void) awakeFromNib
{
	[self openFile:self];
}


// Select and open an image
- (IBAction) openFile:(id)sender
{
	NSArray *fileTypes = [NSArray arrayWithObjects:@"jpg", @"gif", @"png", @"tif", @"tiff", @"psd", @"pdf", nil];
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
    [oPanel setAllowsMultipleSelection:NO];
	
	NSString* startDir = NSHomeDirectory();
	if(lastFilePathOpened)
		startDir = [lastFilePathOpened stringByDeletingLastPathComponent];
	
    if( [oPanel runModalForDirectory:startDir file:[lastFilePathOpened lastPathComponent] types:fileTypes] == NSOKButton )
	{
        NSArray *filesToOpen = [oPanel filenames];
        int i, count = [filesToOpen count];
		
        for (i=0; i<count; i++)
		{
			if(lastFilePathOpened)
				[lastFilePathOpened release];
            lastFilePathOpened = [[filesToOpen objectAtIndex:i] retain];
			DLog(@"Loading image %@", lastFilePathOpened);
			[self setImage:[[PFGLImage alloc] initWithContentsOfFile:lastFilePathOpened]];
        }
    }
}


- (void) setImage:(PFGLImage*)im
{
	PFGLImage *old = image;
	image = [im retain];
	if(old)
		[old release];
	[self setNeedsDisplay:YES];
}


- (IBAction) toggleFullscreen:(id)sender
{
	[[self openGLContext] setFullScreen];
}


- (void)drawRect:(NSRect)rect
{
	// Make this context current
	[[self openGLContext] makeCurrentContext];
	[[self openGLContext] update];
	
	glClear(GL_COLOR_BUFFER_BIT);
	
	if(image)
	{
		[image draw];
		[image drawInRect:NSMakeRect(100,100, 300,100) sourceRect:NSMakeRect(0,0, 300,100)];
		[image drawInRect:NSMakeRect(100,210, 300,100)];
	}
	
	// Flush gl buffer
	glFlush();
	
	// Swap buffer to screen
	//[[self openGLContext] flushBuffer];
}



- (void) reshape	// scrolled, moved or resized
{
	[super reshape];
	
	//[[self openGLContext] makeCurrentContext];
	//[[self openGLContext] update];
	
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


- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	return YES;
}

@end
