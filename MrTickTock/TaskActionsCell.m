//
//  ActionsCell.m
//  MrTickTock
//
//  Created by André Neves on 1/5/13.
//  Copyright (c) 2013 André Neves. All rights reserved.
//

#import "TaskActionsCell.h"
#import "TaskActionButton.h"
#import "UIImage+Utils.h"
#import "NSDate+Helper.h"
#import "Constants.h"
#import <ActionSheetPicker/ActionSheetDatePicker.h>
#import <QuartzCore/QuartzCore.h>

@interface TaskActionsCell()

@property (strong, nonatomic) IBOutlet UIView * buttonsView;
@property (strong, nonatomic) IBOutlet TaskActionButton * setTimeButton;
@property (strong, nonatomic) CALayer * shadowLayer;
@property (strong, nonatomic) CAShapeLayer * triangle;

@end

@implementation TaskActionsCell

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];

    int r = 2;

    if (!self.shadowLayer) {
        self.buttonsView.layer.masksToBounds = YES;
        self.buttonsView.backgroundColor = [UIColor colorWithWhite:0.961 alpha:1.000];

        self.shadowLayer = [CALayer layer];

        self.shadowLayer.frame = CGRectMake(-r, -r, self.buttonsView.frame.size.width + (r * 2), r);
        self.shadowLayer.backgroundColor = UIColor.whiteColor.CGColor;
        self.shadowLayer.shadowOpacity = .8;
        self.shadowLayer.shadowRadius = r;
        self.shadowLayer.shadowOffset = CGSizeMake(0, 1);
        self.shadowLayer.shadowPath = [UIBezierPath bezierPathWithRect:self.shadowLayer.frame].CGPath;
        
        [self.buttonsView.layer addSublayer:self.shadowLayer];

        for (UIView * view in self.buttonsView.subviews) {
            if ([view class] == [TaskActionButton class]) {
                UIButton * button = (UIButton *)view;

                button.titleLabel.font = [UIFont fontWithName:@"ProximaNova-Regular" size:13];
                button.titleEdgeInsets = UIEdgeInsetsMake(1, 0, 0, 0);
            }
        }
    }

    if (!self.triangle) {
        CGRect triangleRect = CGRectMake(self.buttonsView.frame.size.width / 2 - 5, 0, 10, 10);

        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, CGRectGetMinX(triangleRect), 0);
        CGPathAddLineToPoint(path, NULL, CGRectGetMidX(triangleRect), CGRectGetMidY(triangleRect));
        CGPathAddLineToPoint(path, NULL, CGRectGetMaxX(triangleRect), 0);
        CGPathCloseSubpath(path);

        self.triangle = [CAShapeLayer layer];
        self.triangle.path = path;
        self.triangle.fillColor = self.task.isRunning ? KTaskCellRunningBackgroundColor.CGColor : UIColor.whiteColor.CGColor;
        self.triangle.shadowOpacity = .3;
        self.triangle.shadowOffset = CGSizeMake(0, 1);
        self.triangle.shadowPath = path;
        self.triangle.shadowRadius = r;

        [self.buttonsView.layer addSublayer:self.triangle];
    }
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];

    self.setTimeButton.enabled = !self.task.isRunning;

    [CATransaction setDisableActions:YES];

    self.triangle.fillColor = self.task.isRunning ? KTaskCellRunningBackgroundColor.CGColor : UIColor.whiteColor.CGColor;

    [CATransaction setDisableActions:NO];
}

- (IBAction)showTimePicker:(id)sender
{
    if (self.task.isRunning) {
        return;
    }

    NSString * timeString = [NSString stringWithFormat:@"2012-01-01 %@:00", self.task.totalTime];

    ActionSheetDatePicker * _actionSheetPicker = [[ActionSheetDatePicker alloc] initWithTitle:@""
                                                                               datePickerMode:UIDatePickerModeCountDownTimer
                                                                                 selectedDate:[NSDate dateFromString:timeString]
                                                                                       target:self
                                                                                       action:@selector(setTaskTime:element:)
                                                                                       origin:sender];

    [_actionSheetPicker showActionSheetPicker];
}

- (void)setTaskTime:(NSDate *)selectedDate element:(id)element {
    NSString * time = [NSDate stringFromDate:selectedDate withFormat:@"HH:mm"];

    if (self.delegate && [self.delegate respondsToSelector:@selector(setTaskTime:time:)]) {
        [self.delegate setTaskTime:self.task time:time];
    }
}

- (IBAction)addNote:(id)sender
{
    // @TODO
}

- (IBAction)showMore:(id)sender
{
    [[[UIActionSheet alloc] initWithTitle:@"Task actions"
                                 delegate:self
                        cancelButtonTitle:@"Cancel"
                   destructiveButtonTitle:@"Delete"
                        otherButtonTitles:@"Hide", @"Close", nil] showInView:self];
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    UIImage * background = [UIImage imageWithColor:[UIColor colorWithWhite:0 alpha:.7] andSize:CGSizeMake(1, 1)];

    [[actionSheet layer] setContents:(id)background.CGImage];
}

@end
