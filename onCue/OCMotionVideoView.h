//
//  OCMotionVideoView.h
//  onCue
//
//  Created by Jake Van Alstyne on 10/19/11.
//  Copyright (c) 2011 EggDevil. All rights reserved.
//

#import "Accelerate/Accelerate.h"
#import <QuartzCore/CIPlugIn.h>
#import <QuartzCore/CIFilter.h>
#import "OCVideoView.h"
#import "OCMotionVC.h"

@class QTCaptureVideoPreviewOutput;
@class QTCaptureSession;

@interface OCMotionVideoView : OCVideoView{
//	OCMotionVC *_delegate;
	
	CIImage *oldImage;
	CIFilter *mafilter;
	CIFilter *cropFilter;
	CIFilter* backgroundFilter; // Uses Difference blend mode to filter out background
	
	vImagePixelCount				_histogramA[256];
	vImagePixelCount				_histogramR[256];
	vImagePixelCount				_histogramG[256];
	vImagePixelCount				_histogramB[256];
}
-(void)setDelegate:(OCMotionVC *)delegate; 
- (BOOL)motionDetected:(NSBitmapImageRep *)input;
- (CIVector *)vectorFromExtent:(CGRect)extent;
@end
