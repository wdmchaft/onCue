//
//  CamController.h
//  onCue
//
//  Created by Jake Van Alstyne on 10/6/11.
//  Copyright 2011 EggDevil. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CamController : NSObject{
	BOOL isRecording;
	BOOL isWaiting;
	NSImage *buttonLight;
	NSString *actionText;
	
	NSString *readyText;
	NSString *waitingText;
	NSString *recordingText;
	
	NSTimer *flashTimer;
	
	IBOutlet NSTextField *recordingAlertText;
}

@property (assign) BOOL isRecording;
@property (assign) BOOL isWaiting;
@property (retain) NSImage *buttonLight;
@property (retain) NSString *actionText;
@property (retain) NSString *readyText;
@property (retain) NSString *waitingText;
@property (retain) NSString *recordingText;
@property (retain) NSTimer *flashTimer;

-(void)setReady;
-(void)setWaiting;
-(void)setRecording;
-(void)flashRecordingText:(id)sender;
@end
