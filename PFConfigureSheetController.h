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

#import "PFScreenSaverView.h"

@interface PFConfigureSheetController : NSWindowController
{
	IBOutlet NSTextField* fps;
	IBOutlet NSPanel*     providerSettingsPanel;
	
	PFScreenSaverView* ssv;
	NSUserDefaults*    defaults;
}

- (id)initWithWindowNibName:(NSString*)filename withReferenceToSSV:(PFScreenSaverView*)ssv;

- (IBAction)done:(id)sender;
- (IBAction)about:(id)sender;
//- (void)loadSavedStates;

@end
