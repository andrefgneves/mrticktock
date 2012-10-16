//
//  NavigationBar.m
//  MrTickTock
//
//  Created by André Neves on 10/16/12.
//  Copyright (c) 2012 André Neves. All rights reserved.
//

#import "NavigationBar.h"

@implementation NavigationBar

- (void)drawRect:(CGRect)rect
{
    UIColor *color = [UIColor redColor];
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColor(context, CGColorGetComponents( [color CGColor]));
    CGContextFillRect(context, rect);
}

@end
