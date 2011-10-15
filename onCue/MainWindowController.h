//
//  MainWindowController.h
//  onCue
//
//  Created by Jake Van Alstyne on 9/23/11.
//  Copyright 2011 EggDevil. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MainWindowController : NSWindowController{
	NSViewController *currentViewController;
	NSArray *views;
	/* Preload the various views */
}
@property (retain) NSArray *views;
-(void)setMode:(int)index;
@end
