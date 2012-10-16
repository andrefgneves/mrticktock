//
//  TaskCell.m
//  MrTickTock
//
//  Created by André Neves on 9/27/12.
//  Copyright (c) 2012 André Neves. All rights reserved.
//

#import "TaskCell.h"

@implementation TaskCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self) {
        self.projectName.textColor = [UIColor redColor];
    }

    return self;
}

@end
