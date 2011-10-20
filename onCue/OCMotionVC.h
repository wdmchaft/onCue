//
//  OCMotionVC.h
//  onCue
//
//  Created by Jake Van Alstyne on 10/6/11.
//  Copyright 2011 EggDevil. All rights reserved.
//

#import <QTKit/QTKit.h>
#import "OCMotionVC.h"
#import "OCViewController.h"

@interface OCMotionVC : OCViewController <NSTextFieldDelegate>{
	NSButton *waitButton;
	NSTextField *waitTimeInput;
	NSTextField *recordTimeInput;
	NSTextField *motionAlertText;
	NSSlider  *sensSlider;
	
	CIImage *oldImage;
	
	NSString						*delayMinutes;
	NSString						*recordLengthSeconds;
	
	NSTimer						*motionLevelTimer;
	IBOutlet NSLevelIndicator	*motionLevelMeter;
	NSInteger					motionLevelValue;
}

@property (retain) IBOutlet NSButton *waitButton;
@property (retain) IBOutlet NSTextField *waitTimeInput;
@property (retain) IBOutlet NSTextField *recordTimeInput;
@property (retain) IBOutlet NSTextField *motionAlertText;
@property (retain) IBOutlet NSSlider *sensSlider;

@property (retain) NSString *delayMinutes;
@property (retain) NSString *recordLengthSeconds;
@property (assign) NSInteger motionLevelValue;

- (IBAction)toggleWaiting:(id)sender;
-(IBAction)validateWaitTime:(id)sender;
-(IBAction)validateRecordTime:(id)sender;

- (IBAction)setSaveLocation:(id)sender;

-(void)setMotionDetector;
-(void)deactivateMotionDetector;

-(void)shouldStartRecording:(id)sender;
@end
