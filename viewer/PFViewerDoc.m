
#import "PFViewerDoc.h"

@implementation PFViewerDoc

- (id)init {
  self = [super init];
  if (self) {
    DLog(@"");
    // mos
  }
  return self;
}

- (NSString *)windowNibName {
  return @"PFViewerDoc";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController {
	DLog(@"");
  [super windowControllerDidLoadNib:aController];
  winController = aController;
  pfView = [[PFView alloc] initWithFrame:[[[winController window] contentView] bounds] isPreview:NO];
  //[window setContentView:pfView];
  [drawInView addSubview:pfView];
  [pfView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
  //[pfView startAnimation];
}

#pragma mark -
#pragma mark Specials

- (IBAction) showConfigureSheet:(id)sender {
	DLog(@"");
  configureSheet = [[PFController instance] configureSheet];
  
	if(!configureSheet) {
    NSTrace(@"Failed to activate configure sheet");
    return;
  }
  if([configureSheet isVisible]) {
    // Sheet is already visible
    [configureSheet makeKeyAndOrderFront:self];
  } else {
    // Display new sheet
    [NSApp beginSheet: configureSheet
       modalForWindow: [winController window]
        modalDelegate: self
       didEndSelector: @selector(didEndSheet:returnCode:contextInfo:)
          contextInfo: nil];
    // Sheet is up. Return processing to the event loop
  }
}


-(IBAction)toggleAnimation:(id)sender {
	if([pfView isAnimating]) {
		[pfView stopAnimation];
  } else {
		[pfView startAnimation];
  }
}


- (void)windowWillClose:(NSNotification *)aNotification
{
  DLog(@"");
	[pfView stopAnimation];
	[pfView removeFromSuperview];
	[pfView release];
}


- (void)didEndSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
  DLog(@"");
	[sheet orderOut:self];
}


@end
