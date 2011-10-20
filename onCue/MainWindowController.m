//
//  MainWindowController.m
//  onCue
//
//  Created by Jake Van Alstyne on 9/23/11.
//  Copyright 2011 EggDevil. All rights reserved.
//

#import "MainWindowController.h"
#import "OCContinuousVC.h"

@implementation MainWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
	if (!self)
		return nil;
	
	
	
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}
-(void)closePanel{
	[preferencePanel close];
}
@end
