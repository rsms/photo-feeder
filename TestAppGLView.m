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
	NSArray *fileTypes = [PFGLImage acceptableFileExtensions];
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
	else if(!lastFilePathOpened) {
		// First call to open-file and user pressed close or cancel
		[[NSApplication sharedApplication] terminate:self];
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
