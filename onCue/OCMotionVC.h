//
//  OCMotionVC.h
//  onCue
//
//  Created by Jake Van Alstyne on 10/6/11.
//  Copyright 2011 EggDevil. All rights reserved.
//

#import "Accelerate/Accelerate.h"
#import <QuartzCore/CIPlugIn.h>
#import <QuartzCore/CIFilter.h>
#import "OCViewController.h"

@interface OCMotionVC : OCViewController <NSTextFieldDelegate>{
	NSButton *waitButton;
	NSTextField *waitTimeInput;
	NSTextField *recordTimeInput;
	NSTextField *motionAlertText;
	NSSlider  *sensSlider;
	
	CIImage *oldImage;
	CIFilter *mafilter;
	CIFilter *cropFilter;
	CIFilter* backgroundFilter; // Uses Difference blend mode to filter out background
	
	CVImageBufferRef mCurrentBuffer;
	CIImage			 *currentCIImage;
	
	vImagePixelCount				_histogramA[256];
	vImagePixelCount				_histogramR[256];
	vImagePixelCount				_histogramG[256];
	vImagePixelCount				_histogramB[256];
	
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
@property (retain) CIImage *oldImage;
@property (retain) CIImage *currentCIImage;
@property (retain) NSString *delayMinutes;
@property (retain) NSString *recordLengthSeconds;
@property (assign) NSInteger motionLevelValue;

- (IBAction)toggleWaiting:(id)sender;
-(IBAction)validateWaitTime:(id)sender;
-(IBAction)validateRecordTime:(id)sender;
- (BOOL)motionDetected:(NSBitmapImageRep *)input;
- (CIVector *)vectorFromExtent:(CGRect)extent;

- (IBAction)setSaveLocation:(id)sender;

-(void)setMotionDetector;
-(void)deactivateMotionDetector;

-(void)shouldStartRecording:(id)sender;
@end
