//
//  OCButton.m
//  onCue
//
//  Created by Jake Van Alstyne on 9/27/11.
//  Copyright 2011 EggDevil. All rights reserved.
//

#import "OCButton.h"

@implementation OCButton

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}
-(void)setTitle:(NSString *)title{
		// Center the label on the button
    NSMutableParagraphStyle *ps = [[[NSMutableParagraphStyle alloc] init] autorelease];
    [ps setAlignment:NSCenterTextAlignment];
		// Set the color and paragraph style
    NSDictionary *textDictionary = [NSDictionary
									dictionaryWithObjectsAndKeys:[NSColor colorWithCalibratedRed:0.326 green:0.000 blue:0.000 alpha:1.000],
									NSForegroundColorAttributeName, ps, NSParagraphStyleAttributeName, nil];
	[self setAttributedTitle:[[[NSAttributedString alloc]    
											 initWithString:title
											 attributes: textDictionary] autorelease]];
}
@end
