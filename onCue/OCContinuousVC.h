//
//  OCContinuousVC.h
//  onCue
//
//  Created by Jake Van Alstyne on 10/2/11.
//  Copyright 2011 EggDevil. All rights reserved.
//

#import "OCViewController.h"

@interface OCContinuousVC : OCViewController <NSTextFieldDelegate>{
	
	IBOutlet NSTextField	*startTimeInput;
    IBOutlet NSTextField    *endTimeInput;
	NSString				*startInputString; //These allow us to validate immediately
	NSString				*endInputString;
	
		// Text Inputs 
	NSDate *startTime;
	NSDate *endTime;
	NSString *startInputDesc;
	NSString *endInputDesc;
	NSTimer *timePickersTimer;
	
	IBOutlet NSControl *_startSelection;
	IBOutlet NSControl *_endSelection;
	
	IBOutlet NSTextField *unitsLabelStart;
	IBOutlet NSTextField *unitsLabelEnd;
}
@property (retain) NSDate *startTime;
@property (retain) NSDate *endTime;
@property (retain) NSString *startInputDesc;
@property (retain) NSString *endInputDesc;
@property (retain) NSString *startInputString;
@property (retain) NSString *endInputString;

- (void)disableDateInput:(NSTextField *)input;
- (void)enableDateInput:(NSTextField *)input;
- (IBAction)switchVideoStartOption:(id)sender;
- (IBAction)switchVideoEndOption:(id)sender;
- (void)updateTime:(id)sender;
- (void)updateTextField:(NSTextField *)ed;

@end
