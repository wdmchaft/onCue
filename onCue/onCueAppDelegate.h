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
	IBOutlet NSButton *quietSave;
	
	OCViewController *currentVC;
	
	 /* Preload the various views */
	OCContinuousVC *continuousVC;
	OCMotionVC *motionVC;
	
	@private
	NSInteger drawerOpen;
}

- (void)switchViewController:(NSTabView*)tabView item:(NSTabViewItem*)nextItem;
-(IBAction)pictureOutputToggled:(id)sender;
@end
