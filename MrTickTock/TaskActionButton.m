//
//  TaskActionButton.m
//  MrTickTock
//
//  Created by André Neves on 1/6/13.
//  Copyright (c) 2013 André Neves. All rights reserved.
//

#import "TaskActionButton.h"
#import "Constants.h"
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
                                                         cornerRadii:CGSizeMake(20, 20)];

    self.contentLayer = [CAShapeLayer layer];
    self.contentLayer.frame = self.bounds;
    self.contentLayer.path = path.CGPath;
    self.contentLayer.strokeColor = KTaskActionStrokeColor;
    self.contentLayer.lineWidth = 1;
    self.contentLayer.fillColor = UIColor.clearColor.CGColor;

    [self.layer addSublayer:self.contentLayer];

    [self setTitleColor:UIColor.grayColor forState:UIControlStateNormal];
    [self setTitleColor:UIColor.blackColor forState:UIControlStateHighlighted];
    [self setTitleColor:[UIColor colorWithWhite:0.867 alpha:1.000] forState:UIControlStateDisabled];
}

- (void)setEnabled:(BOOL)enabled
{
    [CATransaction setDisableActions:YES];
    self.contentLayer.strokeColor = enabled ? KTaskActionStrokeColor : [UIColor colorWithWhite:0.867 alpha:1.000].CGColor;

    [super setEnabled:enabled];

    [CATransaction setDisableActions:NO];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [CATransaction setDisableActions:YES];
    self.contentLayer.strokeColor = highlighted ? UIColor.blackColor.CGColor : KTaskActionStrokeColor;

    [super setHighlighted:highlighted];

    [CATransaction setDisableActions:NO];
}

@end
