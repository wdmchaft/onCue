//
//  onCueAppDelegate.h
//  onCue
//
//  Created by Jake Van Alstyne on 10/2/11.
//  Copyright 2011 EggDevil. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface onCueAppDelegate : NSObject <NSApplicationDelegate> {
	NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
