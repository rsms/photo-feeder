#import "TestAppFlickrController.h"

#import "FlickrContext.h"
#import "FlickrUser.h"

@implementation TestAppFlickrController

- (void) awakeFromNib
{
	// set api key
	[[FlickrContext defaultContext] setApiKey:@"9b4439ce94de7e2ec2c2e6ffadc22bcf"];
	
	// find user by alias
	FlickrUser* u = [FlickrUser userWithName:@"rsms"];
	if(!u) return;
	NSLog(@"Got FlickrUser:  id: '%@'  name: '%@'", [u uid], [u name]);
}

@end
