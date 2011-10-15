//
//  CamController.h
//  onCue
//
//  Created by Jake Van Alstyne on 10/6/11.
//  Copyright 2011 EggDevil. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CamController : NSObject{
	BOOL isRecording;
	BOOL isWaiting;
	NSImage *buttonLight;
	NSString *actionText;
}

@property (assign) BOOL isRecording;
@property (assign) BOOL isWaiting;
@property (retain) NSImage *buttonLight;
@property (retain) NSString *actionText;

-(void)setReady;
-(void)setWaiting;
-(void)setRecording;

@end
