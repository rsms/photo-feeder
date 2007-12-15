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
#import "PFView.h"
#import "PFProvider.h"
#import "PFController.h"
#import "PFUtil.h"

@implementation PFView

// Our two image ports
static NSString* qcImagePortId = @"Patch.x.value";


- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview {
  if(self = ([super initWithFrame:frame isPreview:isPreview])) {
    DLog(@"");
    
    // Register ourselves in PFMain
    [[PFController instance] registerView:self isPreview:isPreview];
    
    // Register for notificiations
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(renderingParametersDidChange:) 
                                                 name:PFRenderingParametersDidChangeNotification 
                                               object:nil];
    
    // Load composition into a QCView and keep it as a subview
    qcView = [[QCView alloc] initWithFrame:frame];
    [qcView loadCompositionFromFile:[[[PFController instance] bundle] pathForResource:@"standard" ofType:@"qtz"]];
    [qcView setAutostartsRendering:NO];
    [self addSubview: qcView];
  }
  return self;
}


- (void)dealloc {
  [qcView removeFromSuperview];
  [qcView release];
  [super dealloc];
}



#pragma mark -
#pragma mark Animation & Rendering


- (void) startAnimation {
  DLog(@"");
  
  // (Re)load rendering settings
  [self renderingParametersDidChange:nil];
  
  //[qcView setValue: @"Loading images..." forInputKey: @"statusMessageText"];
  
  // Start animation timer and unlock "critical section"
  hasResetTimer = NO;
  isFirstTime = YES;
  [super startAnimation];
  [qcView startRendering];
  //[qcView setValue:[NSNumber numberWithBool: TRUE] forInputKey:@"startTime"];
  [[PFController instance] animationStartedByView:self];
}


- (void) renderingParametersDidChange:(NSNotification *)notificaton {
  DLog(@"");
  
  // Cache these values in the instance
  userFps = [PFUtil defaultFloatForKey:@"fps"];
  userFadeInterval = [PFUtil defaultFloatForKey:@"fadeInterval"];
  userDisplayInterval = [PFUtil defaultFloatForKey:@"displayInterval"];
  
  // Berätta för Q-kompositionen hur länge bilder skall visas & fadeas
  // Regarding the "enabled" key... it has the following three states:
  // 0 means fading down and keeping it at 0% alpha
  // 1 means fading up and keeping it at 100% alpha
  // 2 means not fading at all, keeping it at 0% alpha
  //[qcView setValue: [NSNumber numberWithDouble:userDisplayInterval]  forInputKey: @"timeVisible"];
  //[qcView setValue: [NSNumber numberWithDouble:userFadeInterval]     forInputKey: @"timeFading"];
  [qcView setMaxRenderingFrameRate: userFps];
}


- (void) drawRect:(NSRect)r {
  [qcView setFrame:[self bounds]];
}


- (void) stopAnimation {
  DLog(@"");
  [[PFController instance] animationStoppedByView:self]; // need to be called first
  [qcView stopRendering];
  [super stopAnimation];
}


#pragma mark -
#pragma mark Delegate methods


- (BOOL)hasConfigureSheet {
  return YES;
}


- (NSWindow*)configureSheet {
  return [[PFController instance] configureSheet];
}


- (BOOL) isOpaque {
  return YES;
}


@end
