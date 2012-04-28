//
//  onCueAppDelegate.m
//  onCue
//
//  Created by Jake Van Alstyne on 10/2/11.
//  Copyright (C) 2011 EggDevil. All rights reserved.
//
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.


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
	
	switch ([myTabView indexOfTabViewItem:[myTabView selectedTabViewItem]]){
		case 0:
			currentVC = [continuousVC retain];
			break;
		case 1:
			currentVC = [motionVC retain];
			break;
	}
	
	drawerOpen = 0;
}

-(void)dealloc{
	[continuousVC release];
	[motionVC release];
    [super dealloc];
}

- (BOOL)tabView:(NSTabView *)tabView shouldSelectTabViewItem:(NSTabViewItem *)tabViewItem{
	if ([currentVC isRecording] || [currentVC isWaiting])
		return NO;
	return YES;
}
- (void)tabView:(NSTabView *)tabView willSelectTabViewItem:(NSTabViewItem *)tabViewItem{
	 [self switchViewController:tabView item:tabViewItem];
}
-(void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem{
	if (drawerOpen > 0)
		[currentVC.drawer open];
}

- (void)switchViewController:(NSTabView*)tabView item:(NSTabViewItem*)nextItem {
	OCViewController *newController = nil;
	OCViewController *oldController = nil;
	drawerOpen = [currentVC.drawer state];
		// assume a different identifier has been assigned to each tab view item in IB
	NSInteger itemIndex = [tabView indexOfTabViewItemWithIdentifier:[nextItem identifier]];
	switch (itemIndex) {
		case 0:
			newController = continuousVC;
			oldController = motionVC;
			[quietSave setEnabled:YES];
			quietSave.state = [[NSUserDefaults standardUserDefaults] boolForKey:@"quietSave"];
			break;
		case 1:
			newController = motionVC;
			oldController = continuousVC;
			quietSave.state = YES;
			[quietSave setEnabled:NO];
			break;
	}
	[oldController viewWillDisappear];
	[newController viewWillAppear];
	if (currentVC) {
		[currentVC release];
	}
	currentVC = [newController retain];
}
-(IBAction)restoreMainWindow:(id)sender{
	[windowController showWindow:window];
}
@end
