//
//  OCVideoView.h
//  onCue
//
//  Created by Jake Van Alstyne on 10/19/11.
//  Copyright (c) 2011 EggDevil. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OCMotionVC.h"

@class QTCaptureVideoPreviewOutput;
@class QTCaptureSession;

@interface OCVideoView : NSView{
	QTCaptureVideoPreviewOutput *previewOutput;
	CIImage *currentImage;
	OCViewController *_delegate;
}

@property (retain, readwrite) CIImage *currentImage;

- (id)initWithFrame:(NSRect)frame andSession:(QTCaptureSession*)session;
@end
