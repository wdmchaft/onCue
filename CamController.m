//
//  CamController.m
//  onCue
//
//  Created by Jake Van Alstyne on 10/6/11.
//  Copyright 2011 EggDevil. All rights reserved.
//

#import "CamController.h"

@implementation CamController

@synthesize isRecording,isWaiting,buttonLight,actionText,readyText,waitingText,recordingText; 

- (id)init
{
    self = [super init];
    if (!self)
		return nil;
	
	self.readyText = @"Start Recording";
	self.waitingText = @"Cancel";
	self.recordingText = @"Stop Recording";
	
	[self setReady];
	
    return self;
}

-(void)setReady{
	self.isRecording = NO;
	self.isWaiting = NO;
	self.buttonLight = [[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ready" ofType:@"png"]] autorelease];
    self.actionText = self.readyText;
}
-(void)setWaiting{
	self.isRecording = NO;
	self.isWaiting = YES;
	self.buttonLight = [[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"waiting" ofType:@"png"]] autorelease];
    self.actionText = self.waitingText;
}
-(void)setRecording{
	self.isRecording = YES;
	self.isWaiting = NO;
	self.buttonLight = [[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"recording" ofType:@"png"]] autorelease];
    self.actionText = self.recordingText;
}

@end
