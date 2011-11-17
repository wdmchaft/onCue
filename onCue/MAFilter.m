//
//  MAFilterFilter.m
//  MAFilter
//
//  Created by Jake Van Alstyne on 9/29/11.
//  Copyright 2011 EggDevil. All rights reserved.
//

#import "MAFilter.h"
#import <Foundation/Foundation.h>
#import <ApplicationServices/ApplicationServices.h>

@implementation MAFilter

static CIKernel *_MAFilterKernel = nil;

- (id)init
{
    if(_MAFilterKernel == nil) {
		NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"MAFilter")];
		NSStringEncoding encoding = NSUTF8StringEncoding;
		NSError     *error = nil;
		NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"MAFilterKernel" ofType:@"cikernel"] encoding:encoding error:&error];
		NSArray     *kernels = [CIKernel kernelsWithString:code];

		_MAFilterKernel = [[kernels objectAtIndex:0] retain];
    }
    return [super init];
}

// called when setting up for fragment program and also calls fragment program
- (CIImage *)outputImage
{
    CISampler *src1;
	CISampler *src2;
    
    src1 = [CISampler samplerWithImage:inputImage1];
	src2 = [CISampler samplerWithImage:inputImage2];
	
    return [self apply:_MAFilterKernel, src1, src2, nil];
}

@end
