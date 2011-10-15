	//
	//  OCViewController.m
	//  onCue
	//
	//  Created by Jake Van Alstyne on 10/2/11.
	//  Copyright 2011 EggDevil. All rights reserved.
	//

#import <QTKit/QTKit.h>
#import "OCViewController.h"

@implementation OCViewController

@synthesize startTimer=_startTimer, stopTimer=_stopTimer, audioLevelMeter=_audioLevelMeter, 
recordButton, saveButton=_saveButton, 
saveToTextField=_saveToTextField, windowController, 
saveToURL, movieFileOutput, 
videoDevices, audioDevices,
mainWindow;

-(void)dealloc
{
	[session release];
	[movieFileOutput release];
	[audioPreviewOutput release];
	[captureView release];
	[previewOutput release];
	
	[super dealloc];
}
-(void)viewWillAppear{
//	[session startRunning];
}
-(void)viewWillDisappear{
	[drawer close];
//	[session stopRunning];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) 
		return nil;
	
	session = [[QTCaptureSession alloc] init];
	
		// Create Outputs
	movieFileOutput = [[QTCaptureMovieFileOutput alloc] init];
	[movieFileOutput setDelegate:self];
	[session addOutput:movieFileOutput error:nil];
	
	audioPreviewOutput = [[QTCaptureAudioPreviewOutput alloc] init];
	[audioPreviewOutput setVolume:0.0];
	[session addOutput:audioPreviewOutput error:nil];

	captureView = [[QTCaptureView alloc] init];
    [captureView setCaptureSession:session];
    [captureView setDelegate:self];
	
	previewOutput = [[QTCaptureVideoPreviewOutput alloc] init];
	[previewOutput setDelegate:self];
	[session addOutput:previewOutput error:nil];
	
	[session startRunning];
	
		// Select devices if any exist
	NSArray *myVideoDevices = [self videoDevices];
    
	if ([myVideoDevices count] > 0) {
        int i = 0;
        for (; i < [myVideoDevices count]; i++)
            if ([[[myVideoDevices objectAtIndex:i] localizedDisplayName] isEqualToString:@"Built-in iSight"])
                break;
		[self setSelectedVideoDevice:[myVideoDevices objectAtIndex:i]];
	}
    
	NSArray *myAudioDevices = [self audioDevices];
	if ([myAudioDevices count] > 0) {
        int i = 0;
        for (; i < [myAudioDevices count]; i++)
            if ([[[myAudioDevices objectAtIndex:i] localizedDisplayName] isEqualToString:@"Built-in Microphone"])
                break;
		[self setSelectedAudioDevice:[myAudioDevices objectAtIndex:i]];
	}	
    
        // Register for notifications
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(devicesDidChange:)  
                                                 name:QTCaptureDeviceWasConnectedNotification 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(devicesDidChange:) 
                                                 name:QTCaptureDeviceWasDisconnectedNotification 
                                               object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(connectionFormatWillChange:) 
                                                 name:QTCaptureConnectionFormatDescriptionWillChangeNotification 
                                               object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(connectionFormatDidChange:) 
                                                 name:QTCaptureConnectionFormatDescriptionDidChangeNotification 
                                               object:nil];
//	[[NSNotificationCenter defaultCenter] addObserver:self 
//                                             selector:@selector(deviceAttributeWillChange:) 
//                                                 name:QTCaptureDeviceAttributeWillChangeNotification 
//                                               object:nil];
//	[[NSNotificationCenter defaultCenter] addObserver:self 
//                                             selector:@selector(deviceAttributeDidChange:) 
//                                                 name:QTCaptureDeviceAttributeDidChangeNotification 
//                                               object:nil];
//    
    audioLevelTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateAudioLevels:) userInfo:nil repeats:YES];

	[self setVideoRecordingCompression:@"QTCompressionOptionsSD480SizeH264Video"];
	
    return self;
}
-(void)awakeFromNib{
	CGFloat offset = 80;
	drawer = [[NSDrawer alloc] initWithContentSize:NSSizeFromCGSize(CGSizeMake(480, 320)) preferredEdge:NSMaxYEdge];
	[drawer setLeadingOffset:offset];
	[drawer setTrailingOffset:offset];
	[drawer setContentView:[self preview]];
	[drawer setParentWindow:self.mainWindow];
}
-(IBAction)changeModes:(id)sender{
	[[self.view superview] replaceSubview:self.view with:[self.windowController.views objectAtIndex:1]]; 
}
-(void)captureOutput:(QTCaptureOutput *)captureOutput 
 didOutputVideoFrame:(CVImageBufferRef)videoFrame 
	withSampleBuffer:(QTSampleBuffer *)sampleBuffer 
	  fromConnection:(QTCaptureConnection *)connection{
//	CVImageBufferRef imageBufferToRelease;
	
//    CVBufferRetain(videoFrame);
//	
//    @synchronized (self) {
//        imageBufferToRelease = mCurrentImageBuffer;
//        mCurrentImageBuffer = videoFrame;
//    }
//    CVBufferRelease(imageBufferToRelease);
}
-(CIImage*)view:(QTCaptureView *)view willDisplayImage:(CIImage *)image{
	return image;
}
-(void)launchMenuBar{
		//Create the NSStatusBar and set its length
	if (!statusItem){
		statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] retain];
		NSBundle *bundle = [NSBundle mainBundle];
		statusImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"menu_icon" ofType:@"png"]];
		statusHighlightImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"menu_icon" ofType:@"png"]];
		[statusItem setImage:statusImage];
		[statusItem setAlternateImage:statusHighlightImage];
		[statusItem setMenu:statusMenu];
		[statusItem setToolTip:@"onCue"];
		[statusItem setHighlightMode:NO];
	}
}

-(IBAction)restoreMainWindow:(id)sender{
	[statusItem release];
	statusItem = nil;
	[self restoreMainWindow];
}
-(IBAction)handleRecordMenuItem:(id)sender{
	if (![self isRecording]){
		[self start];
		[self.recordButton setState:NSOnState];
	}
	else {
		[self stop];
		[self.recordButton setState:NSOffState];
	}
}
#pragma mark Recording
-(IBAction)recordButtonPressed:(id)sender{
	NSButton *button = (NSButton*)sender;
	if (button.state)
		[self start];
	else
		[self stop];
}
-(void)start{
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"runFromMenubar"]){
		[self launchMenuBar];
		[self closeMainWindow];
	}
	[self scheduleStopDate:[self endDate]];
	if (![self scheduleStartDate:[self startDate]])
		[self startRecording];
	[self deactivateAllOptions];
}
-(void)stop{
	if ([self.startTimer isValid])
		[self.startTimer invalidate];
	[self stopRecording];
	[self activateAllOptions];
}
-(void)reset{
	NSRect frame = [self.saveButton frame];
	frame.size.width = 76;
	frame.origin.x = 20;
	self.saveToURL = nil;
	
	[[self.saveButton animator] setFrame:frame];
	
	[self.saveButton setTitle:@"Save To…"];
	self.saveToURL = nil;
}
- (NSDate *)startDate{
	return nil;
}
- (NSDate *)endDate{
	return nil;
}
-(BOOL)scheduleStopDate:(NSDate *)date{
	return NO;
}
-(BOOL)scheduleStartDate:(NSDate *)date{
	return NO;
}
- (void)activateAllOptions{}
- (void)deactivateAllOptions{}
-(NSView *)preview{
	return captureView;
}
- (IBAction)toggleDrawer:(id)sender
{
	[drawer toggle:sender];
}
#pragma mark Device selection
- (void)devicesDidChange:(NSNotification *)notification
{
	[self refreshDevices];
}
- (void)refreshDevices
{
	[videoDevices release];
	videoDevices = [[[QTCaptureDevice inputDevicesWithMediaType:QTMediaTypeVideo] 
					  arrayByAddingObjectsFromArray:[QTCaptureDevice inputDevicesWithMediaType:QTMediaTypeMuxed]] retain];
	
	[audioDevices release];
	audioDevices = [[[NSArray alloc] initWithArray:[QTCaptureDevice inputDevicesWithMediaType:QTMediaTypeSound]] retain];
	
	if (![videoDevices containsObject:[self selectedVideoDevice]]) {
		[self setSelectedVideoDevice:nil];
	}
	
	if (![audioDevices containsObject:[self selectedAudioDevice]]) {
		[self setSelectedAudioDevice:nil];
	}	
}
- (NSArray *)videoDevices
{
	if (!videoDevices)
		[self refreshDevices];
	
	return videoDevices;
}

- (NSArray *)audioDevices
{
	if (!audioDevices)
		[self refreshDevices];
	
	return audioDevices;
}

- (BOOL)hasRecordingDevice
{
	return ((videoDeviceInput != nil) || (audioDeviceInput != nil));
}
- (QTCaptureDevice *)selectedVideoDevice
{
	return [videoDeviceInput device];
}

- (void)setSelectedVideoDevice:(QTCaptureDevice *)theSelectedVideoDevice
{
	if (videoDeviceInput) {
            // Remove the old device input from the session and close the device
		[session removeInput:videoDeviceInput];
		[[videoDeviceInput device] close];
		[videoDeviceInput release];
		videoDeviceInput = nil;
	}
	
	if (theSelectedVideoDevice) {
		NSError *error = nil;
		BOOL success;
		
            // Try to open the new device
		success = [theSelectedVideoDevice open:&error];
		if (!success) {
			[[NSAlert alertWithError:error] beginSheetModalForWindow:[self.view window] 
                                                       modalDelegate:self 
                                                      didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) 
                                                         contextInfo:NULL];
			return;
		}
		
            // Create a device input for the device and add it to the session
		videoDeviceInput = [[QTCaptureDeviceInput alloc] initWithDevice:theSelectedVideoDevice];
		NSError *err;
		success = [session addInput:videoDeviceInput error:&err];
		if (!success) {
			[[NSAlert alertWithError:error] beginSheetModalForWindow:[self.view window] 
                                                       modalDelegate:self 
                                                      didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) 
                                                         contextInfo:NULL];
			[videoDeviceInput release];
			videoDeviceInput = nil;
			[theSelectedVideoDevice close];
			return;
		}
        
	}
	
        // If this video device also provides audio, don't use another audio device
	if ([self selectedVideoDeviceProvidesAudio]) {
		[self setSelectedAudioDevice:nil];
	}
}

- (QTCaptureDevice *)selectedAudioDevice
{
	return [audioDeviceInput device];
}

- (void)setSelectedAudioDevice:(QTCaptureDevice *)theSelectedAudioDevice
{
	if (audioDeviceInput) {
            // Remove the old device input from the session and close the device
		[session removeInput:audioDeviceInput];
		[[audioDeviceInput device] close];
		[audioDeviceInput release];
		audioDeviceInput = nil;
	}
	
	if (theSelectedAudioDevice && ![self selectedVideoDeviceProvidesAudio]) {
		NSError *error = nil;
		BOOL success;
		
            // Try to open the new device
		success = [theSelectedAudioDevice open:&error];
		if (!success) {
			[[NSAlert alertWithError:error] beginSheetModalForWindow:[self.view window] 
                                                       modalDelegate:self 
                                                      didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) 
                                                         contextInfo:NULL];
			return;
		}
		
            // Create a device input for the device and add it to the session
		audioDeviceInput = [[QTCaptureDeviceInput alloc] initWithDevice:theSelectedAudioDevice];
		NSError *err;
		success = [session addInput:audioDeviceInput error:&err];
		if (!success) {
			[[NSAlert alertWithError:error] beginSheetModalForWindow:[self.view window] 
                                                       modalDelegate:self 
                                                      didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) 
                                                         contextInfo:NULL];
			[audioDeviceInput release];
			audioDeviceInput = nil;
			[theSelectedAudioDevice close];
			return;
		}
	}
}

- (BOOL)selectedVideoDeviceProvidesAudio
{
	return ([[self selectedVideoDevice] hasMediaType:QTMediaTypeMuxed] || [[self selectedVideoDevice] hasMediaType:QTMediaTypeSound]);
}
- (IBAction)inputSelectionChanged:(id)sender{
    if (![self hasRecordingDevice])
        [self.recordButton setEnabled:NO];
    else
        [self.recordButton setEnabled:YES];
}
#pragma mark Media format summary
- (NSString *)mediaFormatSummary
{
	if (!videoDeviceInput && !audioDeviceInput)
		return nil;
	
	NSMutableString *mediaFormatSummary = [NSMutableString stringWithCapacity:0];
	
	NSEnumerator *videoConnectionEnumerator = [[videoDeviceInput connections] objectEnumerator];
	QTCaptureConnection *videoConnection;
	while ((videoConnection = [videoConnectionEnumerator nextObject])) {
		[mediaFormatSummary appendString:[[videoConnection formatDescription] localizedFormatSummary]];
		[mediaFormatSummary appendString:@"\n"];
	}
	
	NSEnumerator *audioConnectionEnumerator = [[audioDeviceInput connections] objectEnumerator];
	QTCaptureConnection *audioConnection;
	while ((audioConnection = [audioConnectionEnumerator nextObject])) {
		[mediaFormatSummary appendString:[[audioConnection formatDescription] localizedFormatSummary]];
		[mediaFormatSummary appendString:@"\n"];
	}	
	
	return mediaFormatSummary;
}

- (void)connectionFormatWillChange:(NSNotification *)notification
{
	id owner = [[notification object] owner];
	if ((owner == videoDeviceInput) || (owner == audioDeviceInput)) {
		[self willChangeValueForKey:@"mediaFormatSummary"];
	}
}

- (void)connectionFormatDidChange:(NSNotification *)notification
{
	id owner = [[notification object] owner];
	if ((owner == videoDeviceInput) || (owner == audioDeviceInput)) {
		[self didChangeValueForKey:@"mediaFormatSummary"];
	}
}
-(void)restoreMainWindow{
	[self.windowController showWindow:self.mainWindow];
}
-(void)closeMainWindow{
	[self.mainWindow close];
	[self.windowController close];
}
#pragma mark Recording
-(void) setVideoRecordingCompression:(NSString *)compression{
        // Set Compression
    NSEnumerator *connectionEnumerator = [[movieFileOutput connections] objectEnumerator];
    QTCaptureConnection *connection;
    while ((connection = [connectionEnumerator nextObject])) {
        NSString *mediaType = [connection mediaType];
        QTCompressionOptions *compressionOptions = nil;
        if ([mediaType isEqualToString:QTMediaTypeVideo]) {
            compressionOptions = [QTCompressionOptions compressionOptionsWithIdentifier:compression];
        } else if ([mediaType isEqualToString:QTMediaTypeSound]) {
            compressionOptions = [QTCompressionOptions compressionOptionsWithIdentifier:@"QTCompressionOptionsHighQualityAACAudio"];
        }
        
        [movieFileOutput setCompressionOptions:compressionOptions forConnection:connection];
    }
}
- (void)startRecording{
	[self setRecording:TRUE];
	[camController setRecording];
}
- (void)stopRecording{
	[self setRecording:FALSE];
	[camController setReady];
}
- (BOOL)isRecording
{
    return ([movieFileOutput outputFileURL] != nil);
}
- (BOOL)isWaiting{
	return ![self isRecording] && [self.startTimer isValid];
}
- (void)setRecording:(BOOL)recording
{
    if (recording != [self isRecording]) {
        if (recording) {
            if (self.saveToURL == nil) {
                    // Record to a temporary file, which the user will relocate when recording is finished
                char *tempNameBytes = tempnam([NSTemporaryDirectory() fileSystemRepresentation], "QTRecorder_");
                NSString *tempName = [[[NSString alloc] initWithBytesNoCopy:tempNameBytes length:strlen(tempNameBytes) encoding:NSUTF8StringEncoding freeWhenDone:YES] autorelease];
                
                [movieFileOutput recordToOutputFileURL:[NSURL fileURLWithPath:[tempName stringByAppendingPathExtension:@"mov"]]];
            } else {
                [movieFileOutput recordToOutputFileURL:self.saveToURL];
            }
        } else {
            [movieFileOutput recordToOutputFileURL:nil];
        }
    }
}
- (void)updateAudioLevels:(NSTimer *)timer
{
        // Get the mean audio level from the movie file output's audio connections	
	float totalDecibels = 0.0;
	
	QTCaptureConnection *connection = nil;
	NSUInteger i = 0;
	NSUInteger numberOfPowerLevels = 0;	// Keep track of the total number of power levels in order to take the mean
	
	for (i = 0; i < [[movieFileOutput connections] count]; i++) {
		connection = [[movieFileOutput connections] objectAtIndex:i];
		
		if ([[connection mediaType] isEqualToString:QTMediaTypeSound]) {
			NSArray *powerLevels = [connection attributeForKey:QTCaptureConnectionAudioAveragePowerLevelsAttribute];
			NSUInteger j, powerLevelCount = [powerLevels count];
			
			for (j = 0; j < powerLevelCount; j++) {
				NSNumber *decibels = [powerLevels objectAtIndex:j];
				totalDecibels += [decibels floatValue];
				numberOfPowerLevels++;
			}
		}
	}
	
	if (numberOfPowerLevels > 0)
		[self.audioLevelMeter setFloatValue:(pow(10., 0.05 * (totalDecibels / (float)numberOfPowerLevels)) * 25.0)];
	else
		[self.audioLevelMeter setFloatValue:0];
}
	//elsewhere
- (void) alertDidEnd:(NSAlert *) alert returnCode:(int) returnCode contextInfo:(int *) contextInfo
{
	
}
#pragma mark Movie File Output delegate methods
- (void)captureOutput:(QTCaptureFileOutput *)captureOutput didOutputSampleBuffer:(QTSampleBuffer *)sampleBuffer fromConnection:(QTCaptureConnection *)connection
{
    
}

- (void)captureOutput:(QTCaptureFileOutput *)captureOutput willStartRecordingToOutputFileAtURL:(NSURL *)fileURL forConnections:(NSArray *)connections
{
	NSLog(@"Will start recording to %@", [fileURL description]);
}

- (void)captureOutput:(QTCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL forConnections:(NSArray *)connections
{
	NSLog(@"Did start recording to %@", [fileURL description]);
}

- (BOOL)captureOutput:(QTCaptureFileOutput *)captureOutput shouldChangeOutputFileAtURL:(NSURL *)outputFileURL forConnections:(NSArray *)connections dueToError:(NSError *)error
{
	NSLog(@"Should change file due to error %@", [error description]);
	
	return NO;
}

- (void)captureOutput:(QTCaptureFileOutput *)captureOutput mustChangeOutputFileAtURL:(NSURL *)outputFileURL forConnections:(NSArray *)connections dueToError:(NSError *)error
{
	NSLog(@"Must change file due to error %@", [error description]);
}

- (void)captureOutput:(QTCaptureFileOutput *)captureOutput willFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL forConnections:(NSArray *)connections dueToError:(NSError *)error
{
	NSLog(@"Will finish recording to %@ due to error %@", [outputFileURL description], [error description]);	
}
	// Implement this in child classes
	//- (void)captureOutput:(QTCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL forConnections:(NSArray *)connections dueToError:(NSError *)error
@end
