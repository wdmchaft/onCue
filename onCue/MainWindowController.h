//
//  MainWindowController.h
//  onCue
//
//  Created by Jake Van Alstyne on 9/23/11.
//  Copyright 2011 EggDevil. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MainWindowController : NSWindowController{
	IBOutlet NSPanel* preferencePanel;
}

-(void)closePanel;

@end
