//
//  UIImage+UIImage_Utils.m
//  MrTickTock
//
//  Created by André Neves on 10/16/12.
//  Copyright (c) 2012 André Neves. All rights reserved.
//

#import "UIImage+Utils.h"

@implementation UIImage (Utils)

+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();

    CGRect fillRect = CGRectMake(0, 0, size.width, size.height);

    CGContextSetFillColorWithColor(currentContext, color.CGColor);

    CGContextFillRect(currentContext, fillRect);

    UIImage * retval = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return retval;
}

@end
