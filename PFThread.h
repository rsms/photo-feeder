

@interface PFThread : NSObject {
	NSThread* t;
	BOOL      running;
}

-(void)start;
-(void)startWithObject:(NSObject*)obj;
-(void)run;
-(void)stop;

@end
