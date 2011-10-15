//
//  onCueAppDelegate.m
//  onCue
//
//  Created by Jake Van Alstyne on 10/2/11.
//  Copyright 2011 EggDevil. All rights reserved.
//

#import "onCueAppDelegate.h"
#import "OCContinuousVC.h"

@implementation onCueAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	continuousVC = [[OCContinuousVC alloc] initWithNibName:@"OCContinuous" bundle:[NSBundle mainBundle]];
	continuousVC.mainWindow = window;
	continuousVC.windowController = windowController;
	
	motionVC = [[OCMotionVC alloc] initWithNibName:@"OCMotion" bundle:[NSBundle mainBundle]];
	motionVC.mainWindow = window;
	motionVC.windowController = windowController;
	
	[[myTabView tabViewItemAtIndex:0] setView:continuousVC.view];
	[[myTabView tabViewItemAtIndex:1] setView:motionVC.view];
}

-(void)dealloc{
	[continuousVC release];
	[motionVC release];
}

//- (BOOL)tabView:(NSTabView *)tabView shouldSelectTabViewItem:(NSTabViewItem *)tabViewItem{
//	return YES;
//}
- (void)tabView:(NSTabView *)tabView willSelectTabViewItem:(NSTabViewItem *)tabViewItem{
	 [self switchViewController:tabView item:tabViewItem];
}
//- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem{
//
//}
//- (void)tabViewDidChangeNumberOfTabViewItems:(NSTabView *)tabView{
//	
//}

- (void)switchViewController:(NSTabView*)tabView item:(NSTabViewItem*)nextItem {
	OCViewController *newController = nil;
	OCViewController *oldController = nil;
		// assume a different identifier has been assigned to each tab view item in IB
	NSInteger itemIndex = [tabView indexOfTabViewItemWithIdentifier:[nextItem identifier]];
	switch (itemIndex) {
		case 0:
			newController = continuousVC;
			oldController = motionVC;
			break;
		case 1:
			newController = motionVC;
			oldController = continuousVC;
			break;
	}
	[oldController viewWillDisappear];
	[newController viewWillAppear];

}

@end
