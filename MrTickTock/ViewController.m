//
//  ViewController.m
//  MrTickTock
//
//  Created by André Neves on 9/26/12.
//  Copyright (c) 2012 André Neves. All rights reserved.
//

#import "ViewController.h"
#import "AFMrTickTockAPIClient.h"
#import "Task.h"
#import "TaskCell.h"
#import "ACSimpleKeychain.h"

@interface ViewController ()
{
    NSMutableArray * _tasks;
    NSInteger runningTaskIndex;
    NSInteger runningTaskId;

    ACSimpleKeychain * keychain;
}

- (void)checkCredentials;
- (void)setRunningTask:(NSInteger)index;
- (void)stopRunningTask;
- (void)refreshTasks;

@end

@implementation ViewController

@synthesize table = _table;

- (void)viewDidLoad
{
    [super viewDidLoad];

    keychain = [ACSimpleKeychain defaultKeychain];

    [self getActiveTimer];

    _tasks = [[NSMutableArray alloc] init];
    runningTaskIndex = -1;
    runningTaskId = -1;
}

- (void)checkCredentials {
    //NSDictionary * credentials = [keychain credentialsForIdentifier:@"account" service:@"MrTickTock"];
}

- (void)getActiveTimer {
    [[AFMrTickTockAPIClient sharedClient] postPath:@"is_timer_active" parameters:[[AFMrTickTockAPIClient sharedClient] authParams] success:^(AFHTTPRequestOperation *operation, NSDictionary * JSON) {

        NSDictionary * response = [[JSON objectForKey:@"content"] objectAtIndex:0];

        if ([[response objectForKey:@"is_timer"] intValue] == 1) {
            runningTaskId = [[response objectForKey:@"task_id"] integerValue];
        }

        [self refreshTasks];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.debugDescription);
    }];
}

- (void)refreshTasks {
    [_tasks removeAllObjects];

    NSMutableDictionary * params = [[NSMutableDictionary alloc] initWithDictionary:[[AFMrTickTockAPIClient sharedClient] authParams]];
    [params setObject:@"false" forKey:@"closed"];
    [params setObject:@"type" forKey:@"user"];
    [params setObject:@"true" forKey:@"get_hidden_timer"];

    [[AFMrTickTockAPIClient sharedClient] postPath:@"get_tasks" parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary * JSON) {

        int i = 0;
        for (NSDictionary * attributes in [JSON objectForKey:@"content"]) {
            Task * task = [[Task alloc] initWithAttributes:attributes];

            if (task.id == runningTaskId) {
                runningTaskIndex = i;
                task.isRunning = YES;
            }

            [_tasks addObject:task];

            i++;
        }
        
        [_table reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.debugDescription);
    }];
}

- (void)setRunningTask:(NSInteger)index {
    Task * task = [_tasks objectAtIndex:index];

    NSMutableDictionary * params = [[NSMutableDictionary alloc] initWithDictionary:[[AFMrTickTockAPIClient sharedClient] authParams]];
    [params setObject:[NSNumber numberWithInteger:task.id] forKey:@"task_id"];

    [[AFMrTickTockAPIClient sharedClient] postPath:@"start_timer" parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary * JSON) {
        if (runningTaskIndex != -1) {
            Task * runningTask = [_tasks objectAtIndex:runningTaskIndex];
            runningTask.isRunning = NO;
        }

        task.isRunning = YES;

        runningTaskIndex = index;
        runningTaskId = task.id;

        [_table reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.debugDescription);
    }];
}

- (void)stopRunningTask {
    if (runningTaskIndex == -1) {
        return;
    }

    Task * task = [_tasks objectAtIndex:runningTaskIndex];

    NSMutableDictionary * params = [[NSMutableDictionary alloc] initWithDictionary:[[AFMrTickTockAPIClient sharedClient] authParams]];
    [params setObject:[NSNumber numberWithInteger:task.id] forKey:@"task_id"];

    [[AFMrTickTockAPIClient sharedClient] postPath:@"stop_timer" parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary * JSON) {
        task.isRunning = NO;

        runningTaskIndex = -1;
        runningTaskId = -1;

        [_table reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.debugDescription);
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _tasks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TaskCell * cell = [tableView dequeueReusableCellWithIdentifier:@"TASK_CELL" forIndexPath:indexPath];
    Task * task = [_tasks objectAtIndex:indexPath.row];

    cell.label.text = task.projectName;

    return cell;
}

- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath NS_DEPRECATED_IOS(2_0, 3_0) {
    Task * task = [_tasks objectAtIndex:indexPath.row];

    return task.isRunning ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == runningTaskIndex) {
        [self stopRunningTask];
    } else {
        [self setRunningTask:indexPath.row];
    }
}


@end
