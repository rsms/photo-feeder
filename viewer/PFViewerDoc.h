#import <PhotoFeeder/PhotoFeeder.h>
#import <PhotoFeeder/PFView.h>
#import <PhotoFeeder/PFController.h>

@interface PFViewerDoc : NSDocument
{
  IBOutlet NSView     *drawInView;
  NSWindowController  *winController;
	NSWindow            *configureSheet;
	PFView              *pfView;
}

@end
