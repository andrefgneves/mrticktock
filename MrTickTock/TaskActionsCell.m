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
#import <ActionSheetPicker/ActionSheetDatePicker.h>
#import <QuartzCore/QuartzCore.h>

@interface TaskActionsCell()

@property (strong, nonatomic) IBOutlet UIView * buttonsView;
@property (strong, nonatomic) IBOutlet TaskActionButton * setTimeButton;

@end

@implementation TaskActionsCell

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    int r = 2;

    self.buttonsView.layer.masksToBounds = YES;
    self.buttonsView.backgroundColor = [UIColor colorWithWhite:0.961 alpha:1.000];

    CALayer * layer = [CALayer layer];

    layer.frame = CGRectMake(-r, -r, self.buttonsView.frame.size.width + (r * 2), r);
    layer.backgroundColor = UIColor.whiteColor.CGColor;
    layer.shadowOpacity = .8;
    layer.shadowRadius = r;
    layer.shadowOffset = CGSizeMake(0, 1);
    layer.shadowPath = [UIBezierPath bezierPathWithRect:layer.frame].CGPath;

    [self.buttonsView.layer addSublayer:layer];

    for (UIView * view in self.buttonsView.subviews) {
        if ([view class] == [TaskActionButton class]) {
            UIButton * button = (UIButton *)view;

            button.titleLabel.font = [UIFont fontWithName:@"ProximaNova-Bold" size:13];
            button.titleEdgeInsets = UIEdgeInsetsMake(1, 0, 0, 0);
        }
    }
}

- (void)didMoveToSuperview {
    self.setTimeButton.enabled = !self.task.isRunning;
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
    LOG_FUNCTION();
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
