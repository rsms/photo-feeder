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

@interface PFUIController : NSWindowController
{
	IBOutlet NSWindow*          addProviderWindow;
	IBOutlet NSArrayController* availableProvidersController;
	IBOutlet NSArrayController* activeProvidersController;
	IBOutlet NSTableView*       activeProvidersTable;
}

- (IBAction) done:(id)sender;
- (IBAction) about:(id)sender;
- (IBAction) addProviderBegin:(id)sender;
- (IBAction) addProviderCommit:(id)sender;


#pragma mark -
#pragma mark Providers bindings

/// Active providers
- (NSMutableArray *) activeProviders;
- (void) setActiveProviders:(NSMutableArray *)a;

/// Available providers
- (NSArray*) availableProviders;
- (void) setAvailableProviders:(NSArray*)v;


#pragma mark -
#pragma mark Renderer bindings

/// FPS
-(int) fps;
-(void) setFps:(int)d;

/// Display interval
-(float) displayInterval;
-(void) setDisplayInterval:(float)f;

/// Fade interval
-(float) fadeInterval;
-(void) setFadeInterval:(float)f;


#pragma mark -
#pragma mark About bindings

/// Application revision number
- (int) appRevision;

/// Build date in users locale
- (NSString*) buildDate;

@end
