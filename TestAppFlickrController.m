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
#import "TestAppFlickrController.h"
#import <Flickr/Flickr.h>

@implementation TestAppFlickrController

- (void) awakeFromNib
{
	// Get context
	FlickrContext* ctx = [FlickrContext defaultContext];
	
	// set api key
	[ctx setApiKey:@"9b4439ce94de7e2ec2c2e6ffadc22bcf"];
	
	// find user by alias
	FlickrUser* u = [FlickrUser userWithName:@"rsms" context:ctx];
	if(u)
		DLog(@"Got FlickrUser:  id: '%@'  name: '%@'", [u uid], [u name]);
	
	// find by id
	u = [FlickrUser userWithId:[u uid] context:ctx];
	if(u)
		DLog(@"Got FlickrUser:  id: '%@'  name: '%@'", [u uid], [u name]);
	DLog(@"  realName:          %@", [u realName]);
	DLog(@"  location:          %@", [u location]);
	DLog(@"  photosURL:         %@", [u photosURL]);
	DLog(@"  profileURL:        %@", [u profileURL]);
	DLog(@"  mobileURL:         %@", [u mobileURL]);
	DLog(@"  firstDateUploaded: %@", [u firstDateUploaded]);
	DLog(@"  firstDateTaken:    %@", [u firstDateTaken]);
	DLog(@"  numberOfPhotos:    %d", [u numberOfPhotos]);
}

@end
