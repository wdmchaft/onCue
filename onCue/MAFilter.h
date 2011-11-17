//
//  MAFilterFilter.h
//  MAFilter
//
//  Created by Jake Van Alstyne on 9/29/11.
//  Copyright 2011 EggDevil. All rights reserved.

#import <QuartzCore/QuartzCore.h>

@interface MAFilter : CIFilter {
    CIImage      *inputImage1;
	CIImage		 *inputImage2;
}

@end
