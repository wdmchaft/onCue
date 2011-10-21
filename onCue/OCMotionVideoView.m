//
//  OCMotionVideoView.m
//  onCue
//
//  Created by Jake Van Alstyne on 10/19/11.
//  Copyright (c) 2011 EggDevil. All rights reserved.
//

#import <QTKit/QTKit.h>
#import "OCMotionVideoView.h"

@implementation OCMotionVideoView
- (id)initWithFrame:(NSRect)frame andSession:(QTCaptureSession*)session
{
    self = [super initWithFrame:frame andSession:session];
    if (!self) 
        return nil;
	[CIPlugIn loadAllPlugIns];
	
	mafilter = [[CIFilter filterWithName:@"MAFilter"] retain]; //No defaults
	
	cropFilter = [[CIFilter filterWithName:@"CICrop"] retain];
	[cropFilter setDefaults];
	
	backgroundFilter = [[CIFilter filterWithName:@"CIDifferenceBlendMode"] retain];	    // Background filter by using difference blend mode
	[backgroundFilter setDefaults]; 
    return self;
}
-(void)dealloc{
	[viewDelegate release];
	[super dealloc];
}
-(void)setDelegate:(OCMotionVC *)delegate{
	if (viewDelegate)
		[viewDelegate release];
	viewDelegate = [delegate retain];
}
-(void)captureOutput:(QTCaptureOutput *)captureOutput 
 didOutputVideoFrame:(CVImageBufferRef)videoFrame 
	withSampleBuffer:(QTSampleBuffer *)sampleBuffer 
	  fromConnection:(QTCaptureConnection *)connection{
	CIImage *image = [CIImage imageWithCVImageBuffer:videoFrame];
	CGRect extent = [image extent];
	if (oldImage == nil)
		oldImage = image;
	
	[mafilter setValue: image forKey: @"inputImage2"];
	[mafilter setValue: oldImage forKey: @"inputImage1"];
	
	oldImage = image;
	
	[backgroundFilter setValue:image forKey:@"inputBackgroundImage"];
	[backgroundFilter setValue:[mafilter valueForKey:@"outputImage"] forKey:@"inputImage"];
	
	[cropFilter setValue:[backgroundFilter valueForKey:@"outputImage"] forKey:@"inputImage"];
	[cropFilter setValue:[self vectorFromExtent:extent]  forKey:@"inputRectangle"];
	
	NSBitmapImageRep *rep = [[NSBitmapImageRep alloc]initWithCIImage:[cropFilter valueForKey:@"outputImage"]];
	if([self motionDetected:rep]){
		[viewDelegate.motionAlertText setHidden:NO];
	}
	else
		[viewDelegate.motionAlertText setHidden:YES];
	[rep release];
	
	[cropFilter setValue:[mafilter valueForKey:@"outputImage"] forKey:@"inputImage"];
	[cropFilter setValue:[self vectorFromExtent:extent]  forKey:@"inputRectangle"];
	self.currentImage = [cropFilter valueForKey:@"outputImage"];
	[self setNeedsDisplay:YES];
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
	viewDelegate.motionLevelValue = _sum;
	
	double val = [viewDelegate.sensSlider maxValue] - [viewDelegate.sensSlider intValue];
	if (_sum >= val)
		return TRUE;
	return FALSE;
}
- (CIVector *)vectorFromExtent:(CGRect)extent{
	return [CIVector vectorWithX:extent.origin.x Y:extent.origin.y Z:extent.size.width	W:extent.size.height];
}
@end
