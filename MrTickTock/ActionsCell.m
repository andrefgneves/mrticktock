//
//  ActionsCell.m
//  MrTickTock
//
//  Created by André Neves on 1/5/13.
//  Copyright (c) 2013 André Neves. All rights reserved.
//

#import "ActionsCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation ActionsCell

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    int r = 2;

    self.buttonsView.layer.masksToBounds = YES;

    CALayer * layer = [CALayer layer];

    layer.frame = CGRectMake(-r, -r, self.buttonsView.frame.size.width + (r * 2), r);
    layer.backgroundColor = UIColor.redColor.CGColor;
    layer.shadowOpacity = .8;
    layer.shadowRadius = r;
    layer.shadowOffset = CGSizeMake(0, 1);

    UIBezierPath * path = [UIBezierPath bezierPathWithRect:layer.frame];
    layer.shadowPath = path.CGPath;

    [self.buttonsView.layer addSublayer:layer];
}

@end
