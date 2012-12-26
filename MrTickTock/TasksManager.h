//
//  TasksManager.h
//  MrTickTock
//
//  Created by André Neves on 10/13/12.
//  Copyright (c) 2012 André Neves. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"
#import "AFMrTickTockAPIClient.h"
#import "SVProgressHUD.h"
#import "Task.h"
#import "NSDate+Helper.h"

@interface TasksManager : NSObject

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(TasksManager);

@property (nonatomic, strong) id delegate;
@property (nonatomic) BOOL syncing;
@property (nonatomic) NSInteger runningTaskId;
@property (nonatomic, retain) __block NSDate * totalTimeDate;

- (void)sync;
- (void)cleanup:(BOOL)clearAll;
- (BOOL)hasRunningTask;

- (NSArray *)customers;
- (NSArray *)tasksForCustomer:(NSString *)customer;

- (void)startTask:(Task *)task;
- (void)startTask:(Task *)task sync:(BOOL)sync;

- (void)stopTask:(Task *)task;
- (void)stopTask:(Task *)task sync:(BOOL)sync;

- (void)toggleTask:(Task *)task;
- (void)toggleTask:(Task *)task sync:(BOOL)sync;

- (Task *)taskById:(NSUInteger)taskId;
- (Task *)taskAtIndexPath:(NSIndexPath *)indexPath;

- (void)prepareSearch;
- (void)clearSearch;
- (void)search:(NSString *)text;

@end

@protocol TaskManagerDelegate <NSObject>

- (void)taskManagerDidFinishSyncing:(TasksManager *)taskManager;

@end