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
