//
//  OCViewController.h
//  onCue
//
//  Created by Jake Van Alstyne on 10/2/11.
//  Copyright 2011 EggDevil. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MainWindowController.h"
#import "CamController.h"

@class QTCaptureView;
@class QTCaptureSession;
@class QTCaptureDeviceInput;
@class QTCaptureMovieFileOutput;
@class QTCaptureVideoPreviewOutput;
@class QTCaptureAudioPreviewOutput;
@class QTCaptureDecompressedVideoOutput;
@class QTCaptureConnection;
@class QTCaptureOutput;
@class QTCaptureDevice;
@class QTSampleBuffer;
@class QTMovieView;

@interface OCViewController : NSViewController{
	NSStatusItem	*statusItem;
	IBOutlet CamController *camController;
	IBOutlet NSPopUpButton *videoInputPopUp;
	IBOutlet NSPopUpButton *audioInputPopUp;
	
@private
	NSTimer *_startTimer;
	NSTimer *_stopTimer;
	NSLevelIndicator *_audioLevelMeter;
	NSButton *recordButton;
	NSButton *_saveButton;
	NSTextField *_saveToTextField;
	MainWindowController *windowController;
	NSWindow *mainWindow;
	NSDrawer *drawer;
					/* Menu bar stuff */
    IBOutlet NSMenu *statusMenu;
    NSImage			*statusImage;
    NSImage			*statusHighlightImage;
					/* Timers */
	NSTimer				*audioLevelTimer;
					/* Outputs */
	QTCaptureView               *captureView;
	QTCaptureVideoPreviewOutput *previewOutput;
	QTCaptureMovieFileOutput    *movieFileOutput;
    QTCaptureAudioPreviewOutput *audioPreviewOutput;
					/* Session */
	QTCaptureSession			*session;
					/* Devices */
    QTCaptureDeviceInput        *videoDeviceInput;
    QTCaptureDeviceInput        *audioDeviceInput;
	NSArray						*videoDevices;
	NSArray						*audioDevices;
					/* Recording */
    NSURL                       *saveToURL;
	CVImageBufferRef            mCurrentImageBuffer;
}

	/* Window */
@property (retain) IBOutlet MainWindowController *windowController;
@property (retain) IBOutlet NSWindow *mainWindow;

	/* UI */
@property (retain) IBOutlet NSLevelIndicator *audioLevelMeter;
@property (retain) IBOutlet NSButton *recordButton;
@property (retain) IBOutlet NSButton *saveButton;
@property (retain) IBOutlet NSTextField *saveToTextField;
	/* Timers */
@property (retain) NSTimer *startTimer;
@property (retain) NSTimer *stopTimer;
@property (retain) NSURL *saveToURL;
@property (retain) QTCaptureMovieFileOutput *movieFileOutput;
@property (retain, nonatomic) NSArray *videoDevices;
@property (retain, nonatomic) NSArray *audioDevices;


- (void)launchMenuBar;
- (void)restoreMainWindow;
- (void)closeMainWindow;

- (IBAction)toggleDrawer:(id)sender;

/* Device selection */
- (void)refreshDevices;
- (NSArray *)videoDevices;
- (NSArray *)audioDevices;
- (QTCaptureDevice *)selectedVideoDevice;
- (void)setSelectedVideoDevice:(QTCaptureDevice *)selectedVideoDevice;
- (QTCaptureDevice *)selectedAudioDevice;
- (void)setSelectedAudioDevice:(QTCaptureDevice *)selectedAudioDevice;
- (BOOL)selectedVideoDeviceProvidesAudio;
- (BOOL)hasRecordingDevice;
/* Recording */
-(IBAction)recordButtonPressed:(id)sender;
- (void)start;
- (void)stop;
-(void)reset;
- (void) setVideoRecordingCompression:(NSString *)compression;
- (void)startRecording;
- (void)stopRecording;
- (void)setRecording:(BOOL)recording;
- (BOOL)isRecording;
- (BOOL)isWaiting;

-(NSView *)preview;

-(NSDate *)endDate;
-(NSDate *)startDate;
-(BOOL)scheduleStopDate:(NSDate *)date;
-(BOOL)scheduleStartDate:(NSDate *)date;

- (void)activateAllOptions;
- (void)deactivateAllOptions;

-(void)viewWillAppear;
-(void)viewWillDisappear;
@end
