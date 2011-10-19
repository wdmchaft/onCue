//
//  CamController.m
//  onCue
//
//  Created by Jake Van Alstyne on 10/6/11.
//  Copyright 2011 EggDevil. All rights reserved.
//

#import "CamController.h"

@implementation CamController

@synthesize isRecording,isWaiting,buttonLight,actionText,readyText,waitingText,recordingText,flashTimer; 

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
	[recordingAlertText setHidden:YES];
	if ([self.flashTimer isValid])
		[self.flashTimer invalidate];
	self.isRecording = NO;
	self.isWaiting = NO;
	self.buttonLight = [[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ready" ofType:@"png"]] autorelease];
    self.actionText = self.readyText;
}
-(void)setWaiting{
	[recordingAlertText setHidden:YES];
	if ([self.flashTimer isValid])
		[self.flashTimer invalidate];
	self.isRecording = NO;
	self.isWaiting = YES;
	self.buttonLight = [[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"waiting" ofType:@"png"]] autorelease];
    self.actionText = self.waitingText;
}
-(void)setRecording{
	[recordingAlertText setHidden:NO];
	self.flashTimer = [NSTimer scheduledTimerWithTimeInterval:.75 target:self selector:@selector(flashRecordingText:) userInfo:nil repeats:YES];
	self.isRecording = YES;
	self.isWaiting = NO;
	self.buttonLight = [[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"recording" ofType:@"png"]] autorelease];
    self.actionText = self.recordingText;
}

-(void)flashRecordingText:(id)sender{
	[recordingAlertText setHidden:![recordingAlertText isHidden]];
}

@end
