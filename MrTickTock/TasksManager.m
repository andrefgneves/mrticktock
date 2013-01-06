//
//  TasksManager.m
//  MrTickTock
//
//  Created by André Neves on 10/13/12.
//  Copyright (c) 2012 André Neves. All rights reserved.
//

#import "TasksManager.h"
#import "AppDelegate.h"
#import "MainNavigationController.h"

@interface TasksManager()
{
    NSMutableDictionary * _tasks;
    NSMutableArray * _allTasks;
    NSMutableArray * _taskNames;

    NSMutableArray * _customers;
    NSMutableArray * _allCustomers;
}

@end

@implementation TasksManager

SYNTHESIZE_SINGLETON_FOR_CLASS(TasksManager);

- (id)init {
    self = [super init];

	if (self) {
        _runningTaskId = -1;

        _tasks = [[NSMutableDictionary alloc] init];
        _allTasks = [[NSMutableArray alloc] init];

        _customers = [[NSMutableArray alloc] init];
        _allCustomers = [[NSMutableArray alloc] init];
        _taskNames = [[NSMutableArray alloc] init];

        _syncing = NO;
    }

    return self;
}

- (NSArray *)customers
{
    return [NSArray arrayWithArray:_customers];
}

- (NSArray *)tasksForCustomer:(NSString *)customer
{
    return [_tasks objectForKey:customer];
}

- (BOOL)hasRunningTask
{
    return _runningTaskId != -1;
}

- (void)sync
{
    if (_syncing) {
        return;
    }

    _syncing = YES;

    [SVProgressHUD show];

    [[AFMrTickTockAPIClient sharedClient] postPath:@"is_timer_active" parameters:[[AFMrTickTockAPIClient sharedClient] authParams] success:^(AFHTTPRequestOperation *operation, NSDictionary * JSON) {

        NSArray * errors = [JSON objectForKey:@"errors"];
        if (errors.count) {
            [self showError:[errors objectAtIndex:0]];

            return;
        }

        AppDelegate * app = [[UIApplication sharedApplication] delegate];

        [(MainNavigationController *) app.deckController.leftController showAvatar];

        NSDictionary * response = [[JSON objectForKey:@"content"] objectAtIndex:0];

        if ([[response objectForKey:@"is_timer"] intValue] == 1) {
            _runningTaskId = [[response objectForKey:@"task_id"] integerValue];
        } else {
            _runningTaskId = -1;
        }

        [self syncTasks];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showError:error.description];
    }];
}

- (void)syncTasks
{
    [self cleanup:YES];

    NSMutableDictionary * params = [[NSMutableDictionary alloc] initWithDictionary:[[AFMrTickTockAPIClient sharedClient] authParams]];
    
    [params setObject:@"false" forKey:@"closed"];
    [params setObject:@"true" forKey:@"visible"];
    [params setObject:@"user" forKey:@"type"];
    [params setObject:@"false" forKey:@"get_hidden_timer"];

    [[AFMrTickTockAPIClient sharedClient] postPath:@"get_tasks" parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary * JSON) {
        NSArray * errors = [JSON objectForKey:@"errors"];
        if (errors.count) {
            [self showError:[errors objectAtIndex:0]];

            return;
        }

        int i = 0;
        for (NSDictionary * attributes in [JSON objectForKey:@"content"]) {
            Task * task = [[Task alloc] initWithAttributes:attributes];

            if (task.id == _runningTaskId) {
                task.isRunning = YES;
            }

            [_allTasks addObject:task];

            i++;
        }

        [self groupTasksByCustomer:_allTasks];

        [self syncTimers];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showError:error.description];
    }];
}

- (void)syncTimers
{
    self.totalTimeDate = [NSDate dateFromString:@"2012-01-01 00:00:00"];

    __block int count = 0;

    for (NSString * customer in _customers) {
        NSMutableArray * tasks = [_tasks objectForKey:customer];

        for (NSUInteger i = 0; i < tasks.count; i++) {
            Task * task = [tasks objectAtIndex:i];

            NSMutableDictionary * params = [[NSMutableDictionary alloc] initWithDictionary:[[AFMrTickTockAPIClient sharedClient] authParams]];

            [params setObject:[NSString stringWithFormat:@"%d", task.id] forKey:@"task_id"];

            [[AFMrTickTockAPIClient sharedClient] postPath:@"get_task_details" parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary * JSON) {
                NSArray * errors = [JSON objectForKey:@"errors"];
                if (errors.count) {
                    return;
                }

                NSDictionary * attributes = [JSON objectForKey:@"content"];

                task.time = [attributes objectForKey:@"timer_time"];
                task.totalTime = [attributes objectForKey:@"total_time"];

                NSTimeInterval taskTotalTimeInterval = task.timeInterval;

                self.totalTimeDate = [self.totalTimeDate dateByAddingTimeInterval:taskTotalTimeInterval];

                [tasks replaceObjectAtIndex:i withObject:task];

                count++;

                if (count == _allTasks.count) {
                    [SVProgressHUD dismiss];

                    _syncing = NO;

                    if (self.delegate && [self.delegate respondsToSelector:@selector(taskManagerDidFinishSyncing:)]) {
                        [self.delegate taskManagerDidFinishSyncing:self];
                    }
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {}];
        }

        [_tasks setObject:tasks forKey:customer];
    }
}

- (void)startTask:(Task *)task
{
    [self startTask:task sync:YES];
}

- (void)startTask:(Task *)task sync:(BOOL)sync
{
    [SVProgressHUD show];

    NSMutableDictionary * params = [[NSMutableDictionary alloc] initWithDictionary:[[AFMrTickTockAPIClient sharedClient] authParams]];
    [params setObject:[NSString stringWithFormat:@"%d", task.id] forKey:@"task_id"];

    if (sync) {
        [[AFMrTickTockAPIClient sharedClient] postPath:@"start_timer" parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary * JSON) {
            NSArray * errors = [JSON objectForKey:@"errors"];
            if (errors.count) {
                [self showError:[errors objectAtIndex:0]];
                
                return;
            }
            
            // Stop the previously running task
            [self stopTask:nil sync:NO];
            
            task.isRunning = YES;
            
            _runningTaskId = task.id;
            
            [SVProgressHUD dismiss];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(taskManagerDidFinishSyncing:)]) {
                [self.delegate taskManagerDidFinishSyncing:self];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self showError:error.description];
        }];
    } else {
        task.isRunning = YES;

        _runningTaskId = task.id;
    }
}

- (void)stopTask:(Task *)task
{
    [self stopTask:task sync:YES];
}

- (void)stopTask:(Task *)task sync:(BOOL)sync
{
    if (!self.hasRunningTask) {
        return;
    }

    [SVProgressHUD show];

    if (!task) {
        task = [self taskById:_runningTaskId];
    }

    if (sync) {
        NSMutableDictionary * params = [[NSMutableDictionary alloc] initWithDictionary:[[AFMrTickTockAPIClient sharedClient] authParams]];
        [params setObject:[NSString stringWithFormat:@"%d", task.id] forKey:@"task_id"];
        
        [[AFMrTickTockAPIClient sharedClient] postPath:@"stop_timer" parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary * JSON) {
            NSArray * errors = [JSON objectForKey:@"errors"];
            if (errors.count) {
                [self showError:[errors objectAtIndex:0]];

                return;
            }

            task.isRunning = NO;

            _runningTaskId = -1;

            [self syncTimers];

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self showError:error.description];
        }];
    } else {
        task.isRunning = NO;
    }
}

- (void)toggleTask:(Task *)task
{
    [self toggleTask:task sync:YES];
}

- (void)toggleTask:(Task *)task sync:(BOOL)sync
{
    if (task.isRunning) {
        [self stopTask:task sync:sync];
    } else {
        [self startTask:task sync:sync];
    }
}

- (Task *)taskById:(NSUInteger)taskId
{
    NSMutableArray * allTasks = [[NSMutableArray alloc] init];

    for (NSString * customer in _customers) {
        [allTasks addObjectsFromArray:[_tasks objectForKey:customer]];
    }

    for (Task * task in allTasks) {
        if (task.id == taskId) {
            return task;
        }
    }

    return nil;
}

- (Task *)taskAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_customers.count || !_tasks.count || (indexPath.section > _customers.count)) {
        return nil;
    }

    NSString * customer = [_customers objectAtIndex:indexPath.section];
    NSArray * tasks = [_tasks objectForKey:customer];

    if (indexPath.row > tasks.count) {
        return nil;
    }

    return [tasks objectAtIndex:indexPath.row];
}

- (void)groupTasksByCustomer:(NSMutableArray *)tasks
{
    NSMutableArray * customerTasks;

    NSSortDescriptor * projectSorter = [[NSSortDescriptor alloc] initWithKey:@"projectName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSSortDescriptor * nameSorter = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];

    for (Task * task in tasks) {
        if ([_tasks objectForKey:task.customerName]) {
            customerTasks = [_tasks objectForKey:task.customerName];
        } else {
            customerTasks = [[NSMutableArray alloc] init];
        }

        [customerTasks addObject:task];
        [customerTasks sortUsingDescriptors:@[projectSorter, nameSorter]];

        [_tasks setObject:customerTasks forKey:task.customerName];

        if (![_customers containsObject:task.customerName]) {
            [_customers addObject:task.customerName];
        }
    }

    [_customers sortUsingSelector:@selector(caseInsensitiveCompare:)];
}

- (void)prepareSearch
{
    _taskNames = [[NSMutableArray alloc] init];

    for (Task * task in _allTasks) {
        [_taskNames addObject:[NSString stringWithFormat:@"%@ %@", [task.projectName lowercaseString], [task.name lowercaseString]]];
    }
}

- (void)clearSearch
{
    [self cleanup:NO];

    [self groupTasksByCustomer:_allTasks];
}

- (void)search:(NSString *)text
{
    [_tasks removeAllObjects];
    [_customers removeAllObjects];

    NSMutableArray * results = [[NSMutableArray alloc] init];
    text = [text lowercaseString];

    int i = 0;
    for (NSString * name in _taskNames) {
        if (([text isEqualToString:@""]) ||[name rangeOfString:text].length > 0) {
            [results addObject:[_allTasks objectAtIndex:i]];
        }

        i++;
    }

    [self groupTasksByCustomer:results];
}

- (void)cleanup:(BOOL)clearAll
{
    [_tasks removeAllObjects];

    if (clearAll) {
        [_allTasks removeAllObjects];
    }

    [_taskNames removeAllObjects];
    [_customers removeAllObjects];
    [_allCustomers removeAllObjects];
}

- (void)showError:(NSString *)error
{
    _syncing = NO;

    [SVProgressHUD dismiss];

    [[[UIAlertView alloc] initWithTitle:@"Error"
                                message:error
                               delegate:self
                      cancelButtonTitle: @"OK"
                      otherButtonTitles: nil] show];
}

@end
