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

// TODO: Replace this class with bindings and a NSArrayController
// like in http://cocoadevcentral.com/articles/000080.php

#import "PFActiveProvidersTableViewDataSource.h"
@implementation PFActiveProvidersTableViewDataSource


- (id) initWithDefaults:(NSDictionary*)defaults
{
	self = [super init];
	records = [[NSMutableArray alloc] init];
	
	// Iterate defaults and add info from it
	//NSEnumerator *enumerator = [myDictionary keyEnumerator];
	
	// add test-data
	[records addObject:[NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithBool:YES], @"enabled",
		@"Flickr 1", @"name",
		nil]];
	[records addObject:[NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithBool:YES], @"enabled",
		@"Disk 1", @"name",
		nil]];
	
	return self;
}


- (void) dealloc
{
	[records release];
	[super dealloc];
}


- (id) tableView:(NSTableView *)aTableView  objectValueForTableColumn:(NSTableColumn *)aTableColumn  row:(int)rowIndex
{
	id theRecord, theValue;
	
	NSParameterAssert(rowIndex >= 0 && rowIndex < [records count]);
	theRecord = [records objectAtIndex:rowIndex];
	theValue = [theRecord objectForKey:[aTableColumn identifier]];
	return theValue;
}


- (void) tableView:(NSTableView *)aTableView  setObjectValue:anObject  forTableColumn:(NSTableColumn *)aTableColumn  row:(int)rowIndex
{
	id theRecord;
	
	NSParameterAssert(rowIndex >= 0 && rowIndex < [records count]);
	theRecord = [records objectAtIndex:rowIndex];
	[theRecord setObject:anObject forKey:[aTableColumn identifier]];
	return;
}


- (int) numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [records count];
}


@end
