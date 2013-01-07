//
//  TaskCell.m
//  MrTickTock
//
//  Created by André Neves on 9/27/12.
//  Copyright (c) 2012 André Neves. All rights reserved.
//

#import "TaskCell.h"

@interface TaskCell()

@property (strong, nonatomic) UIView * separator;

@end

@implementation TaskCell

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];

    if (!self.separator) {
        self.separator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 1)];

        self.separator.backgroundColor = [UIColor colorWithWhite:0.949 alpha:1.000];

        [self.contentView addSubview:self.separator];
    }
}

- (void)setShoudDrawSeparator:(BOOL)shoudDrawSeparator
{
    _shoudDrawSeparator = shoudDrawSeparator;

    self.separator.hidden = !shoudDrawSeparator;
}

@end
