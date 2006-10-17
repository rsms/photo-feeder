
#import <ScreenSaver/ScreenSaver.h>

@interface PhotoFeederView : ScreenSaverView 
{
}

- (void)queueFillerThread:(id)obj;
- (void)imageCreatorThread:(id)obj;

@end
