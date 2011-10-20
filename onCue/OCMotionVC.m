//
//  OCMotionVC.m
//  onCue
//
//  Created by Jake Van Alstyne on 10/6/11.
//  Copyright 2011 EggDevil. All rights reserved.
//
#import "OCMotionVC.h"
#import "OCMotionVideoView.h"

@implementation OCMotionVC

@synthesize waitButton,waitTimeInput,recordTimeInput,motionAlertText, sensSlider, delayMinutes, recordLengthSeconds, motionLevelValue;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) 
		return nil;
	
	NSNumberFormatter *number_formatter = [[NSNumberFormatter alloc] init];
	[number_formatter setNumberStyle:NSNumberFormatterNoStyle];
	[waitTimeInput setFormatter:number_formatter];
	delayMinutes = @"2";
	recordLengthSeconds = @"10";
	
	[number_formatter release];
	
	dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"M-d-yy_h-mm_a"];
	
	_preview = [[OCMotionVideoView alloc] initWithFrame:drawer.contentView.frame andSession:session];
	[(OCMotionVideoView*)_preview setDelegate:self];
    
    return self;
}
-(void)viewWillAppear{
	[super viewWillAppear];
}
-(void)viewWillDisappear{
	[super viewWillDisappear];
}
-(void)awakeFromNib{
	[super awakeFromNib];
	camController.readyText = @"Set Trigger";
	camController.waitingText = @"Clear Trigger";
	[camController setReady];
	[[self.saveToTextField cell] setAttributedStringValue: [[[NSAttributedString alloc]    
															 initWithString: @"No location set. onCue will automatically save to your Movies folder."
															 attributes: [NSDictionary 
																		  dictionaryWithObject: [NSColor colorWithCalibratedRed:0.326 green:0.000 blue:0.000 alpha:1.000] 
																		  forKey: NSForegroundColorAttributeName]] autorelease]];
}
-(void)dealloc{
	[super dealloc];
}
- (IBAction)toggleWaiting:(id)sender{
	[waitTimeInput setEnabled:[waitButton state]];
	delayMinutes = @"2";
}
- (void)startRecordingImages{
	[super startRecordingImages];
	self.startTimer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(takeSnapshot) userInfo:nil repeats:YES];
}
- (void)stopRecordingImages{
	
}
-(void)takeSnapshot{
	[session startRunning];
	[session stopRunning];
}

-(IBAction)validateWaitTime:(id)sender{
	NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
	if (![f numberFromString:self.delayMinutes] || !([self.delayMinutes intValue] > 0))
		self.delayMinutes = @"2";
	[f release];
}
-(IBAction)validateRecordTime:(id)sender{
	NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
	int val = [self.recordLengthSeconds intValue];
	if (![f numberFromString: self.recordLengthSeconds] || !(val > 0))
		self.recordLengthSeconds = @"10";
	[f release];
}
- (void)activateAllOptions{
	[self.waitButton setEnabled:YES];
	[self.waitTimeInput setEnabled:self.waitButton.state];
	[self.recordTimeInput setEnabled:YES];
	[self.sensSlider setEnabled:YES];
	
	[super activateAllOptions];

}
- (void)deactivateAllOptions{
	[self.waitTimeInput setEnabled:NO];
	[self.waitButton setEnabled:NO];
	[self.recordTimeInput setEnabled:NO];
	[self.sensSlider setEnabled:NO];

	[super deactivateAllOptions];
}
- (NSDate *)startDate{
	if (waitButton.state)
		return [[NSDate date] dateByAddingTimeInterval:60*[[waitTimeInput stringValue] intValue]];
	return nil;
}
- (NSDate *)endDate{
	if ( [recordLengthSeconds intValue] > 0)
		return [[NSDate date] dateByAddingTimeInterval:[recordLengthSeconds intValue]];
	return nil;
}


- (IBAction)setSaveLocation:(id)sender{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	
		//
	NSString *path = [@"~/Movies/onCue/" stringByExpandingTildeInPath];
	NSError *err = nil;
	BOOL directory;
	if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&directory])
		[[NSFileManager defaultManager] createDirectoryAtURL:[NSURL fileURLWithPath:path isDirectory:YES]  withIntermediateDirectories:YES attributes:nil error:&err];
	if (err != nil)
		NSLog(@"Error creating save path directory.");
    
	[openPanel setDirectoryURL:[NSURL URLWithString:path]];	
	
	void (^handler)(NSInteger result);
    
    handler = ^(NSInteger result) {
        if (result != 0){
			
			NSURL *url  = [openPanel URL];
			NSString *urlString = [url absoluteString];
			urlString = [[urlString stringByAppendingString:[dateFormatter stringFromDate:[NSDate date]]] stringByAppendingString:@".mov"];
			self.saveToURL =  [NSURL URLWithString:urlString];
			NSString *path = [[openPanel URL] path];
				// Clear off text field
			[self.saveToTextField setHidden:YES];
				// Make the button wider to fit path
			NSRect frame = [self.saveButton frame];
			frame.size.width = [path length] * 7;
			[[self.saveButton animator] setFrame:frame];
				// Set the path as button label
			[self.saveButton setTitle:path];
		}
        else
            [self reset];
		
    };
	[openPanel setCanChooseDirectories:YES];
	[openPanel setCanChooseFiles:NO];
    [openPanel setCanSelectHiddenExtension:NO];
    [openPanel beginSheetModalForWindow:[self.view window] completionHandler:handler];
}

- (void)captureOutput:(QTCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL forConnections:(NSArray *)connections dueToError:(NSError *)error
{
	NSLog(@"Recorded:\n%llu Bytes\n%@ Duration\n%@ ", [captureOutput recordedFileSize], QTStringFromTime([captureOutput recordedDuration]),outputFileURL);
	
	if (error && ![[[error userInfo] objectForKey:QTErrorRecordingSuccessfullyFinishedKey] boolValue]) {
		[[NSAlert alertWithError:error] beginSheetModalForWindow:self.mainWindow 
                                                   modalDelegate:self 
                                                  didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) 
                                                     contextInfo:NULL];
		return;
	}

	NSURL *moveTo = [self getSaveURL];
	NSError *err = nil;
	[[NSFileManager defaultManager] moveItemAtURL:outputFileURL 
												toURL:moveTo
												error:&err];
	if (err != nil)
		NSLog(@"%@",err);
	NSLog(@"Moved From:%@ To:%@ ",outputFileURL,moveTo);
}
-(NSString*)getSaveString{
	return [[self getSaveURL] absoluteString];
}
-(NSURL*)getSaveURL{
	NSString *rootpath = [@"~/Movies/onCue" stringByExpandingTildeInPath];
	NSString *dirpath = @"";
	NSString *filepath = @"";
	NSString *suffix = @".mov";
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"recordImages"])
		suffix = @".png";
	
	NSError *err = nil;
	BOOL directory;
	if (self.saveToURL == nil)
	{
			//First, set up the save to directory
		if (![[NSFileManager defaultManager] fileExistsAtPath:rootpath isDirectory:&directory])
			[[NSFileManager defaultManager] createDirectoryAtURL:[NSURL fileURLWithPath:rootpath isDirectory:YES]  withIntermediateDirectories:YES attributes:nil error:&err];
		if (err != nil)
			NSLog(@"Error creating save path directory.");
		
			// Now set up the file itself
		dirpath = [[rootpath stringByAppendingString:@"/"] stringByAppendingString:[dateFormatter stringFromDate:[NSDate date]]];
		filepath = [dirpath stringByAppendingString:suffix];
	}
	else{
		dirpath = [[[self.saveToURL absoluteString] stringByAppendingString:@"/"] stringByAppendingString:[dateFormatter stringFromDate:[NSDate date]]];
		filepath = [dirpath stringByAppendingString:suffix];
	}
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:filepath isDirectory:&directory] || [[NSFileManager defaultManager] fileExistsAtPath:dirpath isDirectory:&directory]){
		if (![[NSFileManager defaultManager] fileExistsAtPath:dirpath isDirectory:&directory]){
			[[NSFileManager defaultManager] createDirectoryAtURL:[NSURL fileURLWithPath:dirpath isDirectory:YES]  withIntermediateDirectories:YES attributes:nil error:&err];
			if (err != nil)
				[[NSAlert alertWithError:err] beginSheetModalForWindow:[self.view window] 
														 modalDelegate:self 
														didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) 
														   contextInfo:NULL];
			int i = 1;
			NSString *moveTo = [dirpath stringByAppendingString:[@"/1" stringByAppendingString:suffix]];
			while ([[NSFileManager defaultManager] fileExistsAtPath:moveTo isDirectory:&directory]){
				moveTo = [[dirpath stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", ++i]] stringByAppendingString:suffix];
			}
			if ([[NSFileManager defaultManager] fileExistsAtPath:filepath isDirectory:&directory]){
				[[NSFileManager defaultManager] moveItemAtPath:filepath
													toPath:moveTo
													error:&err];
				i++;
			}
			if (err != nil)
				[[NSAlert alertWithError:err] beginSheetModalForWindow:[self.view window] 
														 modalDelegate:self 
														didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) 
														   contextInfo:NULL];
			return [NSURL fileURLWithPath:[dirpath stringByAppendingPathComponent:[[NSString stringWithFormat:@"%d",i] stringByAppendingString:suffix]]];
		}
		int i = 1;
		filepath = [dirpath stringByAppendingPathComponent:[@"1" stringByAppendingString:suffix]];
		while ([[NSFileManager defaultManager] fileExistsAtPath:filepath isDirectory:&directory]){
			filepath = [[dirpath stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", ++i]] stringByAppendingString:suffix];
		}
		
	}
		
	return [NSURL fileURLWithPath:filepath];
}
-(void)start{
	if ([self isRecording] || [self.startTimer isValid])
		return;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"runFromMenubar"]){
		[self launchMenuBar];
		[self closeMainWindow];
	}
	[self deactivateAllOptions];
	[camController setWaiting];
	
	if (self.waitButton.state)
		self.startTimer = [NSTimer scheduledTimerWithTimeInterval:60*[waitTimeInput intValue] target:self selector:@selector(setMotionDetector) userInfo:nil repeats:NO];
	else
		[self setMotionDetector];
	
	[self.recordButton setState:NO];
}
-(void)stop{
	[super stop];
	if ([self.startTimer isValid])
		[self.startTimer invalidate];
	if ([self.stopTimer isValid])
		[self.stopTimer invalidate];
	[camController setReady];
}
-(void)setMotionDetector{
	[self deactivateMotionDetector];
	self.startTimer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(shouldStartRecording:) userInfo:nil repeats:YES];
}
-(void)deactivateMotionDetector{
	if ([self.startTimer isValid])
		[self.startTimer invalidate];
}
-(void)shouldStartRecording:(id)sender{
	if(![motionAlertText isHidden]){
		[self scheduleStopDate:[self endDate]];
		if (self.isWaiting)
			[self startRecording];
	}
}
-(void)stopRecording{
	[super stopRecording];
	[camController setWaiting];
}
-(BOOL)scheduleStopDate:(NSDate *)stopDate{
	if ([self.stopTimer isValid])
		[self.stopTimer invalidate];
	if (stopDate == nil)
		return NO;
	
	NSTimeInterval interval = [stopDate timeIntervalSinceDate:[NSDate date]];
	
	self.stopTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(stopRecording) userInfo:nil repeats:NO];
	return YES;
}
@end
