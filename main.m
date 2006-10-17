#import "PhotoFeederView.h"

int main(int argc, char *argv[])
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	NSLog(@"main");
	
	PhotoFeederView* pfv = [[PhotoFeederView alloc] initWithFrame:NSMakeRect(0,0,800,600) isPreview:NO];
	[pfv startAnimation];
	int i = 900000;
	
	while(i--) {
		[pfv animateOneFrame];
		usleep(50*1000);
	}
	
	[pfv stopAnimation];
	[pool release];
	return 0;
}