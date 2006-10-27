#import <Flickr/Flickr.h>

static int test() {
	
	FlickrUser* u;
	FlickrContext* ctx;
	
	// Get context & set api key
	assert(ctx = [FlickrContext defaultContext]);
	[ctx setApiKey:@"9b4439ce94de7e2ec2c2e6ffadc22bcf"];
	
	// find user by alias
	assert(u = [FlickrUser userWithName:@"rsms" context:ctx]);
	
	// find by id
	assert(u = [FlickrUser userWithId:[u uid] context:ctx]);
	assert([u uid] != nil);
	assert([u name] != nil);
	assert([u realName] != nil);
	assert([u location] != nil);
	assert([u photosURL] != nil);
	assert([u profileURL] != nil);
	assert([u mobileURL] != nil);
	assert([u firstDateUploaded] != nil);
	assert([u firstDateTaken] != nil);
	assert([u numberOfPhotos] > -1);
	
	return 0;
}


int main(int argc, char *argv[]) {
	NSAutoreleasePool* ap = [NSAutoreleasePool new];
	int status = 0;
	@try {
		status = test();
	}
	@catch(NSException* e) {
		NSLog(@"Failed with exception: %@", e);
		status = 2;
	}
	[ap release];
	return status;
}
