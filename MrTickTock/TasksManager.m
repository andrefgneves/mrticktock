//
//  TasksManager.m
//  MrTickTock
//
//  Created by André Neves on 10/13/12.
//  Copyright (c) 2012 André Neves. All rights reserved.
//

#import "TasksManager.h"

@implementation TasksManager

SYNTHESIZE_SINGLETON_FOR_CLASS(TasksManager);

@synthesize hasRunningTask = _hasRunningTask;
@synthesize runningTaskId = _runningTaskId;
@synthesize runningTaskIndex = _runningTaskIndex;

- (id)init {
    self = [super init];

	if (self) {
        _hasRunningTask = false;
        _runningTaskId = -1;
        _runningTaskIndex = -1;
    }

    return self;
}

@end
