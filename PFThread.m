#import "PFThread.h"

@interface PFThread (Private)
-(void)_start;
@end

//-------------------------------------

@implementation PFThread

-(void)start {
	[self startWithObject:nil];
}

-(void)startWithObject:(NSObject*)param {
	if(!running)
		[NSThread detachNewThreadSelector:@selector(_run:) toTarget:self withObject:param];
}

-(void)_run
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	t = [NSThread currentThread];
	running = YES;
	[self run];
    [pool release];
}

-(void)run {
	// override
	while(running) {
	}
}

-(void)stop {
	running = NO;
}

@end
