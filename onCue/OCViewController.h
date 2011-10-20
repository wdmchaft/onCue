//
//  OCViewController.h
//  onCue
//
//  Created by Jake Van Alstyne on 10/2/11.
//  Copyright 2011 EggDevil. All rights reserved.
//

#import "CamController.h"

@class MainWindowController;
@class OCVideoView;
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

@interface OCViewController : NSViewController <NSDrawerDelegate>{
	NSStatusItem	*statusItem;
	IBOutlet CamController *camController;
	IBOutlet NSPopUpButton *videoInputPopUp;
	IBOutlet NSPopUpButton *audioInputPopUp;
	
	NSDateFormatter				*dateFormatter;
	
	NSTimer *_startTimer;
	NSTimer *_stopTimer;
	NSLevelIndicator *_audioLevelMeter;
	NSButton *recordButton;
	NSButton *_saveButton;
	IBOutlet NSButton *previewButton;
	NSTextField *_saveToTextField;
	MainWindowController *windowController;
	NSWindow *mainWindow;
	NSDrawer *drawer;
	NSTabView *tabView;
					/* Menu bar stuff */
    IBOutlet NSMenu *statusMenu;
    NSImage			*statusImage;
    NSImage			*statusHighlightImage;
					/* Timers */
	NSTimer				*audioLevelTimer;
	NSTimer				*snapshotTimer;
					/* Outputs */
	QTCaptureView               *captureView;
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
	
	BOOL _recordingImages;
	
	OCVideoView *_preview;
}

	/* Window */
@property (retain) IBOutlet MainWindowController *windowController;
@property (retain) IBOutlet NSWindow *mainWindow;
@property (retain) NSTabView *tabView;
@property (retain) NSDrawer *drawer;

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

-(IBAction)pictureOutputToggled;
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
- (void)startRecordingImages;
- (void)stopRecordingImages;
- (void)setRecording:(BOOL)recording;
- (BOOL)isRecording;
- (BOOL)isRecordingImages;
- (BOOL)isWaiting;

-(NSDate *)endDate;
-(NSDate *)startDate;
-(BOOL)scheduleStopDate:(NSDate *)date;
-(BOOL)scheduleStartDate:(NSDate *)date;

- (void)activateAllOptions;
- (void)deactivateAllOptions;

-(void)viewWillAppear;
-(void)viewWillDisappear;

-(void)saveImage:(CIImage*)image toURL:(NSURL*)url;

-(NSURL*)getSaveURL;
-(NSString*)getSaveString;
@end
