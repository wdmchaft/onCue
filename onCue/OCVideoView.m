//
//  OCVideoView.m
//  onCue
//
//  Created by Jake Van Alstyne on 10/19/11.
//  Copyright (c) 2011 EggDevil. All rights reserved.
//

#import <QTKit/QTKit.h>
#import "OCVideoView.h"

@implementation OCVideoView

@synthesize currentImage;

- (id)initWithFrame:(NSRect)frame andSession:(QTCaptureSession*)session
{
    self = [super initWithFrame:frame];
    if (!self) 
        return nil;
    
	previewOutput = [[QTCaptureVideoPreviewOutput alloc] init];
	[previewOutput setDelegate:self];
	[session addOutput:previewOutput error:nil];
	
    return self;
}
-(void)dealloc{
	[previewOutput release];
	[_delegate release];
	
	[super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect
{
//	if ([_delegate.drawer state]){
		if (self.currentImage != nil){
			CGRect extent = [self.currentImage extent];
			[self.currentImage drawInRect: NSRectFromCGRect(  extent )  fromRect: NSRectFromCGRect(  extent )  operation:NSCompositeCopy fraction:1];
		}
//	}
}
-(void)setDelegate:(OCViewController *)delegate{
	if (_delegate)
		[_delegate release];
	_delegate = [delegate retain];
}
-(void)captureOutput:(QTCaptureOutput *)captureOutput 
		didOutputVideoFrame:(CVImageBufferRef)videoFrame 
		withSampleBuffer:(QTSampleBuffer *)sampleBuffer 
		fromConnection:(QTCaptureConnection *)connection{
	self.currentImage = [CIImage imageWithCVImageBuffer:videoFrame];
	[self setNeedsDisplay:YES];
}
@end
