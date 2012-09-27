//
//  TaskCell.m
//  MrTickTock
//
//  Created by André Neves on 9/27/12.
//  Copyright (c) 2012 Andr√© Neves. All rights reserved.
//

#import "TaskCell.h"

@implementation TaskCell

@synthesize label = _label;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
