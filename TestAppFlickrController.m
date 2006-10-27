#import "TestAppFlickrController.h"

#import "FlickrContext.h"
#import "FlickrUser.h"

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
		NSLog(@"Got FlickrUser:  id: '%@'  name: '%@'", [u uid], [u name]);
	
	// find by id
	u = [FlickrUser userWithId:[u uid] context:ctx];
	if(u)
		NSLog(@"Got FlickrUser:  id: '%@'  name: '%@'", [u uid], [u name]);
}

@end
