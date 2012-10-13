//
//  TasksManager.h
//  MrTickTock
//
//  Created by André Neves on 10/13/12.
//  Copyright (c) 2012 André Neves. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"

@interface TasksManager : NSObject

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(TasksManager);

@property (nonatomic) BOOL hasRunningTask;
@property (nonatomic) NSInteger runningTaskId;
@property (nonatomic) NSInteger runningTaskIndex;



@end