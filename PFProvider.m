/**
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
#import "PFProvider.h"

@implementation PFProvider


// An array of file extensions this implementation can read and parse
static NSArray *acceptableFileExtensions = nil;


- (id) initWithConfiguration:(NSDictionary*)conf
{
	return [super init];
}


-(NSImage*)nextImage
{
	throw_ex(@"PFProviderException", @"[PFProvider nextImage] method is abstract and not overridden");
	return nil;
}


+ (BOOL)initClass:(NSBundle*)theBundle
{
	return NO;
}


+ (void)terminateClass
{
}


+ (NSArray*) acceptableFileExtensions
{
	if(!acceptableFileExtensions)
	{
		// init on demand
		acceptableFileExtensions = [[NSArray arrayWithObjects:
			@"jpeg", @"jpg", @"gif", @"png", @"tif", @"tiff", @"psd", @"pict", nil] retain];
	}
	return acceptableFileExtensions;
}

@end
