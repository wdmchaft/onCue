//
//  OCMotionVC.m
//  onCue
//
//  Created by Jake Van Alstyne on 10/6/11.
//  Copyright 2011 EggDevil. All rights reserved.
//

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
	delayMinutes = @"0";
	recordLengthSeconds = @"10";
	
	[number_formatter release];
    
    return self;
}
-(void)awakeFromNib{
	[super awakeFromNib];
}
-(void)dealloc{
	[mafilter release];
	[cropFilter release];
	[backgroundFilter release];
	
	[super dealloc];
}
- (IBAction)toggleWaiting:(id)sender{
	[waitTimeInput setEnabled:[waitButton state]];
	delayMinutes = @"0";
}
- (CIImage *)view:(QTCaptureView *)view willDisplayImage:(CIImage *)image
{
	return self.currentCIImage;
}
-(void)captureOutput:(QTCaptureOutput *)captureOutput 
 didOutputVideoFrame:(CVImageBufferRef)videoFrame 
	withSampleBuffer:(QTSampleBuffer *)sampleBuffer 
	  fromConnection:(QTCaptureConnection *)connection{
	
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

    int bytesPerRow = size.width * 4 * sizeof( uint8_t);
    
		//Prevent bytesPerRow from becoming a power of 2
    if( 0 == ( bytesPerRow & (bytesPerRow - 1 ) ) )
        bytesPerRow += 128;

	vImage_Error	    err;
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
	err = vImageHistogramCalculation_ARGB8888(&srcBuffer,
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
-(BOOL)scheduleStopDate:(NSDate *)stopDate{
	if ([self.stopTimer isValid])
		[self.stopTimer invalidate];
	if (stopDate == nil)
		return NO;
	
	NSTimeInterval interval = [stopDate timeIntervalSinceDate:[NSDate date]];
	
	self.stopTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(stop) userInfo:nil repeats:NO];
	return YES;
}
-(BOOL)scheduleStartDate:(NSDate *)startDate{
	if (startDate == nil)
		return NO;
	[camController setWaiting];
	NSTimeInterval interval = [startDate timeIntervalSinceDate:[NSDate date]];
	self.startTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(startRecording) userInfo:nil repeats:NO];
	return YES;
}
-(IBAction)validateWaitTime:(id)sender{
	NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
	if (![f numberFromString:self.delayMinutes] || !([self.delayMinutes intValue] > 0))
		self.delayMinutes = @"0";
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
	[self.waitTimeInput setEnabled:YES];
	[self.waitButton setEnabled:YES];
	[self.recordTimeInput setEnabled:YES];
	[self.sensSlider setEnabled:YES];
}
- (void)deactivateAllOptions{
	[self.waitTimeInput setEnabled:NO];
	[self.waitButton setEnabled:NO];
	[self.recordTimeInput setEnabled:NO];
	[self.sensSlider setEnabled:NO];
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
- (IBAction)recordButtonPressed:(id)sender{
	NSButton *button = (NSButton*)sender;
	if (button.state)
		[self start];
	else
		[self stop];
}

- (void)reset{
}
- (IBAction)setSaveLocation:(id)sender{
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    void (^handler)(NSInteger result);
    
    handler = ^(NSInteger result) {
        if (result != 0){
			self.saveToURL = [savePanel URL];
			NSString *path = [[savePanel URL] path];
				// Clear off text field
			[self.saveToTextField setHidden:YES];
				// Make the button wider to fit path
			NSRect frame = [self.saveButton frame];
			
			frame.size.width = [path length] * 7;
			
			[[self.saveButton animator] setFrame:frame];
			
				// Set the path as button label
			[self.saveButton setTitle:path];
		}
        else{
			
            [self reset];
        }
        
    };
    [savePanel setAllowedFileTypes:[NSArray arrayWithObject:@"mov"]];
    [savePanel setCanSelectHiddenExtension:NO];
    [savePanel beginSheetModalForWindow:[self.view window] completionHandler:handler];
}
@end
