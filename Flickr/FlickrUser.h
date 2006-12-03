/*
 * Flickr Objective-C Framework is the legal property of its developers.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version. You should have received a copy 
 * of the GNU General Public License along with this program; if not, 
 * write to the Free Software Foundation, Inc., 59 Temple Place, 
 * Suite 330, Boston, MA 02111-1307 USA
 */
#import "FlickrContext.h"

@interface FlickrUser : NSObject {
	FlickrContext* ctx;
	NSString*      uid;
	NSString*      name;
	NSString*      realName;
	NSString*      location;
	NSURL*         photosURL;
	NSURL*         profileURL;
	NSURL*         mobileURL;
	NSDate*        firstDateUploaded;
	NSDate*        firstDateTaken;
	int            numberOfPhotos;
	BOOL           _hasFetchedInfo;
}


+ (FlickrUser*) userWithId:(NSString*)uid context:(FlickrContext*)ctx;
+ (FlickrUser*) userWithId:(NSString*)uid;
+ (FlickrUser*) userWithName:(NSString*)name context:(FlickrContext*)ctx;
+ (FlickrUser*) userWithName:(NSString*)name;

- (id) initWithContext:(FlickrContext*)context uid:(NSString*)i name:(NSString*)n;

- (NSString*) uid;
- (NSString*) name;
- (NSString*) realName;
- (NSString*) location;
- (NSURL*)    photosURL;
- (NSURL*)    profileURL;
- (NSURL*)    mobileURL;
- (NSDate*)   firstDateUploaded;
- (NSDate*)   firstDateTaken;
- (int)       numberOfPhotos;

/*
- (NSArray*) favoritePhotos; // flickr.favorites.getList
- (NSArray*) publicPhotos;   // flickr.people.getPublicPhotos
- (NSArray*) publicGroups;   // flickr.people.getPublicGroups
- (NSArray*) contactsPhotos; // flickr.photos.getContactsPhotos (auth r)
*/

@end
