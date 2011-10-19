//
//  OCMotionVC.m
//  onCue
//
//  Created by Jake Van Alstyne on 10/6/11.
//  Copyright 2011 EggDevil. All rights reserved.
//

#import <QTKit/QTKit.h>
#import "OCMotionVC.h"

@implementation OCMotionVC

@synthesize waitButton,waitTimeInput,recordTimeInput,motionAlertText, sensSlider, oldImage, currentCIImage, delayMinutes, recordLengthSeconds, motionLevelValue;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) 
		return nil;
	
	[CIPlugIn loadAllPlugIns];
	
	mafilter = [[CIFilter filterWithName:@"MAFilter"] retain]; //No defaults
	
	cropFilter = [[CIFilter filterWithName:@"CICrop"] retain];
	[cropFilter setDefaults];
	
	backgroundFilter = [[CIFilter filterWithName:@"CIDifferenceBlendMode"] retain];	    // Background filter by using difference blend mode
	[backgroundFilter setDefaults]; 
	
	NSNumberFormatter *number_formatter = [[NSNumberFormatter alloc] init];
	[number_formatter setNumberStyle:NSNumberFormatterNoStyle];
	[waitTimeInput setFormatter:number_formatter];
	delayMinutes = @"2";
	recordLengthSeconds = @"10";
	
	[number_formatter release];
	
	dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"M-d-yy_h-mm_a"];
    
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
	[mafilter release];
	[cropFilter release];
	[backgroundFilter release];
	
	[super dealloc];
}
- (IBAction)toggleWaiting:(id)sender{
	[waitTimeInput setEnabled:[waitButton state]];
	delayMinutes = @"2";
}
- (CIImage *)view:(QTCaptureView *)view willDisplayImage:(CIImage *)image {
	return self.currentCIImage;
}
-(void)captureOutput:(QTCaptureOutput *)captureOutput 
 didOutputVideoFrame:(CVImageBufferRef)videoFrame 
	withSampleBuffer:(QTSampleBuffer *)sampleBuffer 
	  fromConnection:(QTCaptureConnection *)connection{

	[self updateCurrentImage:videoFrame];
	
	CIImage *image = [CIImage imageWithCVImageBuffer:videoFrame];
	
	CGRect extent = [image extent];
	if (self.oldImage == nil)
		self.oldImage = image;
	
	[mafilter setValue: image forKey: @"inputImage2"];
	[mafilter setValue: self.oldImage forKey: @"inputImage1"];
	
	self.oldImage = image;
	
	[backgroundFilter setValue:image forKey:@"inputBackgroundImage"];
	[backgroundFilter setValue:[mafilter valueForKey:@"outputImage"] forKey:@"inputImage"];
	
	[cropFilter setValue:[backgroundFilter valueForKey:@"outputImage"] forKey:@"inputImage"];
	[cropFilter setValue:[self vectorFromExtent:extent]  forKey:@"inputRectangle"];
	
	NSBitmapImageRep *rep = [[NSBitmapImageRep alloc]initWithCIImage:[cropFilter valueForKey:@"outputImage"]];
	if([self motionDetected:rep]){
		[self.motionAlertText setHidden:NO];
		if ([self isRecording])
			[self scheduleStopDate:[self endDate]];
	}
	else
		[self.motionAlertText setHidden:YES];
	[rep release];
	
	[cropFilter setValue:[mafilter valueForKey:@"outputImage"] forKey:@"inputImage"];
	[cropFilter setValue:[self vectorFromExtent:extent]  forKey:@"inputRectangle"];
	self.currentCIImage = [cropFilter valueForKey:@"outputImage"];
}
- (BOOL)motionDetected:(NSBitmapImageRep *)input{
	NSSize			size = [ input size ];

    vImage_Buffer	    srcBuffer;
	srcBuffer.data = [input bitmapData];
	srcBuffer.rowBytes = [input bytesPerRow];
	srcBuffer.height = size.height;
	srcBuffer.width = size.width;
	vImagePixelCount *histograms[4];
		// Generate the buffer
	histograms[0] = _histogramA;
	histograms[1] = _histogramR;
	histograms[2] = _histogramG;
	histograms[3] = _histogramB;
	vImageHistogramCalculation_ARGB8888(&srcBuffer,
											  histograms,
											  kvImageNoFlags);
	
	long unsigned _sum = 0;
	int i;
	for (i = 128; i < 256; i++) // Ignore dark values
		_sum += _histogramR[i];
	self.motionLevelValue = _sum;
	
	double val = [self.sensSlider maxValue] - [self.sensSlider intValue];
	if (_sum >= val)
		return TRUE;
	return FALSE;
}
- (CIVector *)vectorFromExtent:(CGRect)extent{
	return [CIVector vectorWithX:extent.origin.x Y:extent.origin.y Z:extent.size.width	W:extent.size.height];
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

	[[NSFileManager defaultManager] moveItemAtURL:outputFileURL 
												toURL:[self getSaveURL]
												error:nil];
}
-(NSString*)getSaveString{
	return [[self getSaveURL] absoluteString];
}
-(NSURL*)getSaveURL{
	NSString *path = [@"~/Movies/onCue" stringByExpandingTildeInPath];
	NSString *suffix = @".mov";
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"recordImages"])
		suffix = @".png";
	
	NSError *err = nil;
	BOOL directory;
	if (self.saveToURL == nil)
	{
			//First, set up the save to directory
		if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&directory])
			[[NSFileManager defaultManager] createDirectoryAtURL:[NSURL fileURLWithPath:path isDirectory:YES]  withIntermediateDirectories:YES attributes:nil error:&err];
		if (err != nil)
			NSLog(@"Error creating save path directory.");
		
			// Now set up the file itself
		path = [[[path stringByAppendingString:@"/"] stringByAppendingString:[dateFormatter stringFromDate:[NSDate date]]] stringByAppendingString:suffix];
	}
	else
		path = [[[[self.saveToURL absoluteString] stringByAppendingString:@"/"] stringByAppendingString:[dateFormatter stringFromDate:[NSDate date]]] stringByAppendingString:suffix];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&directory]){
		NSString *newpath = [path stringByDeletingPathExtension];
		if (!directory){
			[[NSFileManager defaultManager] createDirectoryAtURL:[NSURL fileURLWithPath:newpath isDirectory:YES]  withIntermediateDirectories:YES attributes:nil error:&err];	
			NSURL *moveTo = [NSURL URLWithString:[newpath stringByAppendingString:[@"/1" stringByAppendingString:suffix]]];
			[[NSFileManager defaultManager] moveItemAtURL:[NSURL fileURLWithPath:path] 
													toURL:moveTo
													error:&err];
			if (err != nil)
				[[NSAlert alertWithError:err] beginSheetModalForWindow:[self.view window] 
														 modalDelegate:self 
														didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) 
														   contextInfo:NULL];
			return [NSURL URLWithString:[newpath stringByAppendingPathComponent:[@"2" stringByAppendingString:suffix]]];
		}
		int i = 1;
		path = [newpath stringByAppendingPathComponent:[@"1" stringByAppendingString:suffix]];
		while ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&directory]){
			path = [[path stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", ++i]] stringByAppendingString:suffix];
		}
		
	}
	
	
		
	return [NSURL URLWithString:path];
}
-(void)start{
	if ([self isRecording] || [self.startTimer isValid])
		return;
	
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
