//
//  TaskActionButton.m
//  MrTickTock
//
//  Created by André Neves on 1/6/13.
//  Copyright (c) 2013 André Neves. All rights reserved.
//

#import "TaskActionButton.h"
#import <QuartzCore/QuartzCore.h>

@interface TaskActionButton()

@property (nonatomic) CAShapeLayer * contentLayer;

@end

@implementation TaskActionButton

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    UIRectCorner corners = UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomRight | UIRectCornerBottomLeft;
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                   byRoundingCorners:corners
                                                         cornerRadii:CGSizeMake(8, 8)];

    self.contentLayer = [CAShapeLayer layer];
    self.contentLayer.frame = self.bounds;
    self.contentLayer.path = path.CGPath;
    self.contentLayer.strokeColor = UIColor.grayColor.CGColor;
    self.contentLayer.lineWidth = 1.7;
    self.contentLayer.fillColor = UIColor.clearColor.CGColor;

    [self.layer addSublayer:self.contentLayer];

    [self setTitleColor:UIColor.grayColor forState:UIControlStateNormal];
    [self setTitleColor:UIColor.blackColor forState:UIControlStateHighlighted];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [CATransaction setDisableActions:YES];
    self.contentLayer.strokeColor = UIColor.blackColor.CGColor;

    [self setHighlighted:YES];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [CATransaction setDisableActions:YES];
    self.contentLayer.strokeColor = UIColor.grayColor.CGColor;

    [self setHighlighted:NO];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [CATransaction setDisableActions:YES];
    self.contentLayer.strokeColor = UIColor.grayColor.CGColor;

    [self setHighlighted:NO];
}

@end
