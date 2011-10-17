//
//  OCContinuousVC.m
//  onCue
//
//  Created by Jake Van Alstyne on 10/2/11.
//  Copyright 2011 EggDevil. All rights reserved.
//

#import <QTKit/QTKit.h>
#import "OCContinuousVC.h"

@implementation OCContinuousVC

@synthesize startTime, endTime,startInputDesc,endInputDesc,startInputString,endInputString;

typedef enum {
	startNow_selection = 30,
	startDate_selection,
	startDelay_selection,
	
	endNever_selection = 40,
	endDate_selection,
	endDuration_selection
} inputSelection;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) 
		return nil;

	[self setVideoRecordingCompression:@"QTCompressionOptionsSD480SizeH264Video"];
	
	self.startTime = [NSDate date];
	self.endTime = [NSDate date];
	timePickersTimer = [[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES] retain];
	
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
	[self disableDateInput:startTimeInput];
	[self disableDateInput:endTimeInput];
	self.startInputDesc = [NSString stringWithFormat:@"New recording begins upon command."];
	self.endInputDesc = [NSString stringWithFormat:@"Recording will stop upon command."];
	
		// Force color on save location placeholder
    [[self.saveToTextField cell] setAttributedStringValue: [[[NSAttributedString alloc]    
															 initWithString: @"No location set… onCue will prompt you for a location to save to after recording is complete."
															 attributes: [NSDictionary 
																		  dictionaryWithObject: [NSColor colorWithCalibratedRed:0.326 green:0.000 blue:0.000 alpha:1.000] 
																		  forKey: NSForegroundColorAttributeName]] autorelease]];
}


- (void)disableDateInput:(NSTextField *)input{
    [input setEnabled:NO];
    [input setHidden:YES];
}
- (void)enableDateInput:(NSTextField *)input{
    [input setEnabled:YES];
    [input setHidden:NO];
}

- (IBAction)switchVideoStartOption:(id)sender{
    NSButtonCell *selCell = [sender selectedCell];
	
    CGRect frame = NSRectToCGRect([startTimeInput frame]);
	
	NSString *formatString;
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	
    switch ([selCell tag]) {
            
                // Now
        case startNow_selection:
            [self disableDateInput:startTimeInput];
			[unitsLabelStart setHidden:YES];
            frame.size.width = 139;
            self.startInputDesc = [NSString stringWithFormat:@"New recording begins upon command."];
			if (!camController.isRecording && !camController.isWaiting)
				[camController setReady];
            break;
            
                // Time
        case startDate_selection:
            [self enableDateInput:startTimeInput];
			[unitsLabelStart setHidden:YES];
			formatString = [NSDateFormatter dateFormatFromTemplate:@"h:mm a" options:0 locale:[NSLocale currentLocale]];
			[formatter setDateFormat:formatString];
			[startTimeInput setFormatter:formatter];
			[startTimeInput setObjectValue:self.startTime];
			self.startInputDesc = [NSString stringWithFormat:@"Schedule recording to begin at %@.",[startTimeInput stringValue]];
			if (!camController.isRecording && !camController.isWaiting)
				camController.actionText = @"Schedule";
            frame.size.width = 100;
            break;
            
                // Delay
        case startDelay_selection:
			[unitsLabelStart setHidden:NO];
            [self enableDateInput:startTimeInput];
			NSNumberFormatter *number_formatter = [[NSNumberFormatter alloc] init];
			[number_formatter setNumberStyle:NSNumberFormatterNoStyle];
			[startTimeInput setFormatter:number_formatter];
			[startTimeInput setIntValue:10];
			[number_formatter release];
			if (!camController.isRecording && !camController.isWaiting)
				camController.actionText = @"Schedule";
            frame.size.width = 100;
            break;
            
        default:
            break;
    }
	[formatter release];
	[self updateTextField:startTimeInput];
}
- (IBAction)switchVideoEndOption:(id)sender{
    NSButtonCell *selCell = [sender selectedCell];
    CGRect frame = NSRectToCGRect([endTimeInput frame]);
	
	NSString *formatString;
	
    switch ([selCell tag]) {
            
                // Never
        case endNever_selection:
            [self disableDateInput:endTimeInput];
			[unitsLabelEnd setHidden:YES];
            frame.size.width = 139;
            self.endInputDesc = [NSString stringWithFormat:@"Recording will stop upon command."];
            break;
            
                // Time
        case endDate_selection:
            [self enableDateInput:endTimeInput];
			[unitsLabelEnd setHidden:YES];
			NSDateFormatter *date_formatter = [[NSDateFormatter alloc] init];
			formatString = [NSDateFormatter dateFormatFromTemplate:@"h:mm a" options:0 locale:[NSLocale currentLocale]];
			[date_formatter setDateFormat:formatString];
			[endTimeInput setFormatter:date_formatter];
			[date_formatter release];
			[endTimeInput setObjectValue:self.endTime];
			self.endInputDesc = [NSString stringWithFormat:@"Recording will stop at %@",[endTimeInput stringValue]];
            frame.size.width = 100;
            break;
            
                // Duration
        case endDuration_selection:
            [self enableDateInput:endTimeInput];
			[unitsLabelEnd setHidden:NO];
			NSNumberFormatter *number_formatter = [[NSNumberFormatter alloc] init];
			[number_formatter setNumberStyle:NSNumberFormatterNoStyle];
			[endTimeInput setFormatter:number_formatter];
			[endTimeInput setIntValue:10];
			[number_formatter release];
            frame.size.width = 100;
            break;
            
        default:
            break;
    }
	[self updateTextField:endTimeInput];
}
- (void)updateTime:(id)sender{
	self.startTime = [[NSDate date] dateByAddingTimeInterval:60]; // 1 minute in the future
	self.endTime = [[NSDate date] dateByAddingTimeInterval:600]; // 10 minutes in the future
}
-(void)activateAllOptions{
	[startTimeInput setEnabled:YES];
	[endTimeInput setEnabled:YES];
	[_startSelection setEnabled:YES];
	[_endSelection setEnabled:YES];
	[self.saveButton setEnabled:YES];
	[audioInputPopUp setEnabled:YES];
	[videoInputPopUp setEnabled:YES];
}
-(void)deactivateAllOptions{
	[startTimeInput setEnabled:NO];
	[endTimeInput setEnabled:NO];
	[_startSelection setEnabled:NO];
	[_endSelection setEnabled:NO];
	[self.saveButton setEnabled:NO];
	[audioInputPopUp setEnabled:NO];
	[videoInputPopUp setEnabled:NO];
}
- (NSDate *)startDate{
	switch ([[_startSelection selectedCell] tag]) {
		case startNow_selection:
			return nil;
			break;
		case startDate_selection:
			return [NSDate dateWithNaturalLanguageString:[startTimeInput stringValue]];
			break;
		case startDelay_selection:
			return [[NSDate date] dateByAddingTimeInterval:60*[[startTimeInput stringValue] intValue]]; 
			break;
		default:
			return nil;
			break;
	}
	return nil;
}
- (NSDate *)endDate{
	switch ([[_endSelection selectedCell] tag]) {
		case endNever_selection:
			return nil;
			break;
		case endDate_selection:
			return [NSDate dateWithNaturalLanguageString:[endTimeInput stringValue]];
			break;
		case endDuration_selection:
			if ([self startDate] == nil)
				return [[NSDate date] dateByAddingTimeInterval:60*[[endTimeInput stringValue] intValue]]; 
			else
				return [[self startDate] dateByAddingTimeInterval:60*[[endTimeInput stringValue] intValue]]; 
			break;
		default:
			return nil;
			break;
	}
	return nil;
}
- (NSString *)startTimeString{
	NSDateFormatter *date_formatter = [[[NSDateFormatter alloc] init] autorelease];
	[date_formatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"h:mm a" options:0 locale:[NSLocale currentLocale]]];
	switch ([[_startSelection selectedCell] tag]) {
		case startNow_selection:
			return nil;
			break;
		case startDate_selection:
			return [startTimeInput stringValue];
			break;
		case startDelay_selection:
			return [date_formatter stringFromDate:[self startDate]];
			break;
	}
	
	return nil;
}
- (NSString *)endTimeString{
	NSDateFormatter *date_formatter = [[[NSDateFormatter alloc] init] autorelease];
	[date_formatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"h:mm a" options:0 locale:[NSLocale currentLocale]]];
	switch ([[_endSelection selectedCell] tag]) {
		case endNever_selection:
			return nil;
			break;
		case endDate_selection:
			return [endTimeInput stringValue];
			break;
		case endDuration_selection:
			return [date_formatter stringFromDate:[self endDate]];
			break;
	}
	return nil;
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
	
    if (self.saveToURL == nil)
	{
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"quietSave"]){
				//First, set up the save to directory
			NSDateFormatter *formatter = [[NSDateFormatter alloc] init]; 
			NSString *path = [@"~/Movies/onCue/" stringByExpandingTildeInPath];
			NSError *err = nil;
			BOOL directory;
			if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&directory])
				[[NSFileManager defaultManager] createDirectoryAtURL:[NSURL fileURLWithPath:path isDirectory:YES]  withIntermediateDirectories:YES attributes:nil error:&err];
			if (err != nil)
				NSLog(@"Error creating save path directory.");
			
				// Now set up the file itself
			[formatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"MMMdyyyyhmma" options:0 locale:[NSLocale currentLocale]]];
			path = [[[path stringByAppendingString:@"/"] stringByAppendingString:[formatter stringFromDate:[NSDate date]]] stringByAppendingString:@".mov"];
			NSLog(@"%@",path);
			
			[[NSFileManager defaultManager] moveItemAtURL:outputFileURL 
													toURL:[NSURL fileURLWithPath:path]
													error:nil];
			
			[formatter release];
		}
		else{
				// SAVE PANEL ATTACHED TO WINDOW
			if ([[self.windowController window] isVisible]){
					// Move the recorded temporary file to a user-specified location
				NSSavePanel *savePanel = [NSSavePanel savePanel];
				[savePanel setAllowedFileTypes:[NSArray arrayWithObject:@"mov"]];
				[savePanel setCanCreateDirectories:YES];
				[savePanel setCanSelectHiddenExtension:NO];
				[savePanel beginSheetModalForWindow:self.mainWindow completionHandler:^(NSInteger result) {
					if (result == NSOKButton) {
							// No save location was specified, so force one to be chosen
						NSURL *filename = [savePanel URL];
						[[NSFileManager defaultManager] moveItemAtURL:outputFileURL toURL:filename error:nil];
					} else {
							// Delete the file if they cancel
						[[NSFileManager defaultManager] removeItemAtPath:[outputFileURL path] error:nil];
						[self reset];
					}
				}];
			}
				// FREE FLOATING SAVE PANEL
			else { 
				NSSavePanel *savePanel = [NSSavePanel savePanel];
				[savePanel setAllowedFileTypes:[NSArray arrayWithObject:@"mov"]];
				[savePanel setCanCreateDirectories:YES];
				[savePanel setCanSelectHiddenExtension:NO];
				[[savePanel.windowController window] orderFrontRegardless];
				void (^handler) (NSInteger);
				handler = ^(NSInteger result) {
						//If cancelled, onCue continues recording
					if (result == NSOKButton) {
						NSURL *filename = [savePanel URL];
						[[NSFileManager defaultManager] moveItemAtURL:outputFileURL toURL:filename error:nil];
					}
					else{
							// Delete the file if they cancel
						[[NSFileManager defaultManager] removeItemAtPath:[outputFileURL path] error:nil];
						[self reset];
					}
				};
				[savePanel beginWithCompletionHandler:handler];
			}
		}
	}
	else
		[[NSFileManager defaultManager] moveItemAtURL:outputFileURL toURL:self.saveToURL error:nil];
	
	
	[self reset];
}
- (void)controlTextDidEndEditing:(NSNotification *)obj
{
	NSTextField *ed = [obj object];
	[self updateTextField:ed];
}
- (void)updateTextField:(NSTextField *)ed{
	NSDate *startDate;
	NSDate *endDate;
	
	if (ed == endTimeInput) {
		if ([[_endSelection selectedCell] tag] == endDate_selection ||
			[[_endSelection selectedCell] tag] == endDuration_selection) {
			
			endDate = [self endDate];
			self.endInputDesc = [NSString stringWithFormat:@"Recording will stop at %@.",[self endTimeString]];
				// If the end is set to earlier than the start, announce it
			if ([endDate earlierDate:[NSDate date]] == endDate)
				self.endInputDesc = [NSString stringWithFormat:@"Stop time is in the past. Recording will not stop automatically."];
			
			if ([[_startSelection selectedCell] tag] == startDate_selection ||
				[[_startSelection selectedCell] tag] == startDelay_selection) {
				
				startDate = [self startDate];
				self.startInputDesc = [NSString stringWithFormat:@"Schedule recording to begin at %@.",[self startTimeString]];
				if ([startDate earlierDate:[NSDate date]] == startDate)
					self.startInputDesc = [NSString stringWithFormat:@"Start time is in the past. Recording will begin upon command."];
				if ([endDate earlierDate:startDate] == endDate)
					self.endInputDesc = [NSString stringWithFormat:@"Stop time is earlier than start time. Recording will not stop automatically.",[self endTimeString]];	
			}
		}
	}
	else if (ed == startTimeInput){
		if ([[_startSelection selectedCell] tag] == startDate_selection ||
			[[_startSelection selectedCell] tag] == startDelay_selection) {
			
			startDate = [self startDate];
			self.startInputDesc = [NSString stringWithFormat:@"Schedule recording to begin at %@.",[self startTimeString]];
			if ([startDate earlierDate:[NSDate date]] == startDate)
				self.startInputDesc = [NSString stringWithFormat:@"Start time is in the past. Recording will begin upon command."];
			
			if ([[_endSelection selectedCell] tag] == endDate_selection ||
				[[_endSelection selectedCell] tag] == endDuration_selection) {
				
				endDate = [self endDate];
				if ([endDate earlierDate:startDate] == endDate)
					self.endInputDesc = [NSString stringWithFormat:@"Stop time is earlier than start time. Recording will not stop automatically."];
			}
		}
	}
}
@end
