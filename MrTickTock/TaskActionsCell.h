//
//  ActionsCell.h
//  MrTickTock
//
//  Created by André Neves on 1/5/13.
//  Copyright (c) 2013 André Neves. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"

@protocol TaskActionsCellDelegate <NSObject>

- (void)setTaskTime:(Task *)task time:(NSString *)time;

@end

@interface TaskActionsCell : UITableViewCell <UIActionSheetDelegate>

@property (nonatomic, strong) id<TaskActionsCellDelegate> delegate;
@property (nonatomic, strong) Task * task;

@end
