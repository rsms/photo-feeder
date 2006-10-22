#import "PFConfigureSheetController.h"

@implementation PFConfigureSheetController


- (id)initWithWindowNibName:(NSString*)filename withReferenceToSSV:(PFScreenSaverView*)_ssv
{
	[self initWithWindowNibName:filename];
	ssv = _ssv;
	return self;
}


- (IBAction)done:(id)sender
{
	NSLog(@"[%@ done]", self);
	
	// tag 0 = OK, tag 1 = cancel
	/*if([(NSButton*)sender tag] == 0)
	{
		[[StarryView defaults] setInteger:[starsSlider intValue] forKey:@"numStars"];
		[[StarryView defaults] setFloat:[sizeSlider floatValue] forKey:@"starSize"];
		[[StarryView defaults] setInteger:[saturationSlider intValue] forKey:@"colorSaturation"];
		[[StarryView defaults] setInteger:[fpsSlider intValue] forKey:@"fps"];
	}
	else {
		[self loadSavedStates];
	}*/
	[[NSApplication sharedApplication] endSheet:[self window]];
}


- (IBAction)about:(id)sender
{
	NSLog(@"[%@ about]", self);
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://trac.hunch.se/PhotoFeeder"]];
}


- (void)awakeFromNib
{
	NSLog(@"[%@ awakeFromNib]", self);
	//[self loadSavedStates];
}

@end
