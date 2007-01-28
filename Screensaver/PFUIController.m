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
#import "PFUIController.h"
#import "../Core/PFUtil.h"
#import "../Core/PFMain.h"
#import "../Core/version.h"

@implementation PFUIController


- (void)awakeFromNib
{
	DLog(@"");
}


#pragma mark -
#pragma mark Add Provider


- (IBAction) addProviderBegin:(id)sender
{
	DLog(@"");
	[NSApp runModalForWindow:addProviderWindow];
}


- (IBAction) addProviderCommit:(id)sender
{
	Class providerClass;
	NSObject<PFProvider>* provider;
	
	providerClass = [[availableProvidersController selectedObjects] lastObject];
	[addProviderWindow performClose:sender];
	provider = [[PFMain instance] instantiateProviderWithIdentifier: nil
																			  ofClass: providerClass
																usingConfiguration: nil];
	if(provider)
	{
		[activeProvidersController rearrangeObjects];
		[self displayConfigurationUIForProvider:provider];
	}
}


- (void) displayConfigurationUIForProvider:(NSObject<PFProvider>*)provider
{
	DLog(@"provider = %@", provider);
	
	//PFProvider* provider = [[self activeProviders] objectAtIndex:[selectionIndex intValue]];
	
	if(provider && [provider hasConfigureSheet])
	{
		NSWindow* win = [provider configureSheet];
		[win center];
		[win setLevel:NSModalPanelWindowLevel];
		[win setTitle:[NSString stringWithFormat:@"%@: %@", [[provider class] pluginName], [provider name]]];
		[win makeKeyAndOrderFront:self];
	}
}


/*- (void) onActiveProvidersDidChange:(NSNotification*)notification
{
	DLog(@"");
	[activeProvidersController rearrangeObjects];
}*/


- (void) controlTextDidEndEditing:(NSNotification *)notification
{
	// Refresh sorting (if used) if active providers table was edited
	if([notification object] == activeProvidersTable)
		[activeProvidersController rearrangeObjects];
}



#pragma mark -
#pragma mark Window delegate methods

- (void)windowWillClose:(NSNotification *)notification
{
	if([notification object] == addProviderWindow)
		[NSApp stopModal];
}


#pragma mark -
#pragma mark TableView delegate methods

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	if([notification object] == activeProvidersTable)
	{
		if([activeProvidersTable selectedRow] == -1)
			[activeProvidersRemoveButton setEnabled:NO];
		else
			[activeProvidersRemoveButton setEnabled:YES];
	}
}


#pragma mark -
#pragma mark Bindings


-(int) fps
{
	return [PFUtil defaultIntForKey:@"fps"];
}

-(void) setFps:(int)d
{
	[[PFUtil defaults] setInteger:d forKey:@"fps"];
	[[PFMain instance] renderingParametersDidChange];
}


-(float) displayInterval
{
	return [PFUtil defaultIntForKey:@"displayInterval"];
}

-(void) setDisplayInterval:(float)f
{
	[[PFUtil defaults] setInteger:f forKey:@"displayInterval"];
	[[PFMain instance] renderingParametersDidChange];
}


-(float) fadeInterval
{
	return [PFUtil defaultIntForKey:@"fadeInterval"];
}

-(void) setFadeInterval:(float)f
{
	[[PFUtil defaults] setInteger:f forKey:@"fadeInterval"];
	[[PFMain instance] renderingParametersDidChange];
}


- (NSArray*) availableProviders
{
	return [[PFMain instance] availableProviders];
}


- (void) setAvailableProviders:(NSArray*)v
{
	// Can't alter available providers
}


- (NSMutableArray *) activeProviders
{
	return [[PFMain instance] activeProviders];
}


- (void) setActiveProviders:(NSMutableArray *)v
{
	[[PFMain instance] setActiveProviders:v];
}


- (int) appRevision
{
	return PF_REVISION;
}


- (NSString*) buildDate
{
	return [[NSDate dateWithTimeIntervalSince1970:PF_BUILD_TIMESTAMP] description];
}



#pragma mark -
#pragma mark Other actions


- (IBAction) done:(id)sender
{
	[NSApp endSheet:[self window]];
	[[PFMain instance] synchronizeProviderConfigurations];
}


- (IBAction)about:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://trac.hunch.se/PhotoFeeder"]];
}
@end
