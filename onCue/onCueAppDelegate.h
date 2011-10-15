//
//  onCueAppDelegate.h
//  onCue
//
//  Created by Jake Van Alstyne on 10/2/11.
//  Copyright 2011 EggDevil. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MainWindowController.h"
#import "OCViewController.h"
#import "OCContinuousVC.h"
#import "OCMotionVC.h"

@interface onCueAppDelegate : NSObject <NSApplicationDelegate, NSTabViewDelegate> {
	IBOutlet NSWindow *window;
	IBOutlet NSTabView *myTabView;
	IBOutlet MainWindowController *windowController;
	
	 /* Preload the various views */
	OCContinuousVC *continuousVC;
	OCMotionVC *motionVC;
}

- (void)switchViewController:(NSTabView*)tabView item:(NSTabViewItem*)nextItem;

@end
