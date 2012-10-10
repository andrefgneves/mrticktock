//
//  ViewController.m
//  MrTickTock
//
//  Created by André Neves on 9/26/12.
//  Copyright (c) 2012 André Neves. All rights reserved.
//

#import "TasksViewController.h"
#import "AFMrTickTockAPIClient.h"
#import "Task.h"
#import "TaskCell.h"
#import "ACSimpleKeychain.h"
#import "SVProgressHUD.h"
#import "IIViewDeckController.h"
#import "Task.h"

@interface TasksViewController ()
{
    NSArray * _tasks;
    NSInteger runningTaskIndex;
    NSInteger runningTaskId;
    BOOL isIOS6;

    ACSimpleKeychain * keychain;
}

@end

@implementation TasksViewController

@synthesize table = _table;

- (void)viewDidLoad
{
    [super viewDidLoad];

    isIOS6 =  NSClassFromString(@"UIRefreshControl") != nil;

    self.navigationController.delegate = self;
    self.navigationItem.hidesBackButton = YES;

    if (isIOS6) {
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl addTarget:self action:@selector(refreshInvoked:forState:) forControlEvents:UIControlEventValueChanged];
    } else {
        UIBarButtonItem * refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                        target:self
                                                                                        action:@selector(refreshInvoked:forState:)];
        self.navigationItem.rightBarButtonItem = refreshButton;
    }

    [self showLogoutButton:NO];

    keychain = [ACSimpleKeychain defaultKeychain];

    _tasks = [Task findAll];

    runningTaskIndex = -1;
    runningTaskId = -1;
}

- (void)viewDidAppear:(BOOL)animated
{
    self.viewDeckController.panningMode = IIViewDeckNavigationBarPanning;
}

- (void)showLogoutButton:(BOOL)visible {
    self.navigationItem.leftBarButtonItem = visible ? self.logoutButton : nil;
}

-(void) refreshInvoked:(id)sender forState:(UIControlState)state {
    if (isIOS6) {
        [self.refreshControl endRefreshing];
    }

    [self getActiveTimer];
}

- (void)showLogin {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)confirmLogout:(id)sender {
    [[[UIActionSheet alloc] initWithTitle:@"Really logout?"
                                 delegate:self
                        cancelButtonTitle:@"Cancel"
                   destructiveButtonTitle:@"Logout"
                        otherButtonTitles: nil] showInView:self.view];
}

- (void)logout {
    [keychain deleteAllCredentialsForService:@"MrTickTock"];

    [self showLogoutButton:NO];

    _tasks = nil;
    [_table reloadData];

    [self showLogin];
}

- (void)getActiveTimer {
    [SVProgressHUD show];

    [[AFMrTickTockAPIClient sharedClient] postPath:@"is_timer_active" parameters:[[AFMrTickTockAPIClient sharedClient] authParams] success:^(AFHTTPRequestOperation *operation, NSDictionary * JSON) {

        NSArray * errors = [JSON objectForKey:@"errors"];
        if (errors.count) {
            [self showError:[errors objectAtIndex:0]];

            [self logout];

            return;
        }

        NSDictionary * response = [[JSON objectForKey:@"content"] objectAtIndex:0];

        if ([[response objectForKey:@"is_timer"] intValue] == 1) {
            runningTaskId = [[response objectForKey:@"task_id"] integerValue];
        }

        [TestFlight passCheckpoint:@"USER_LOGGED_IN"];
        
        [self showLogoutButton:YES];

        [self refreshTasks];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showError:error.description];
    }];
}

- (void)refreshTasks {
    [Task truncateAll];

    _tasks = nil;
    [_table reloadData];

    NSMutableDictionary * params = [[NSMutableDictionary alloc] initWithDictionary:[[AFMrTickTockAPIClient sharedClient] authParams]];
    [params setObject:@"false" forKey:@"closed"];
    [params setObject:@"type" forKey:@"user"];
    [params setObject:@"true" forKey:@"get_hidden_timer"];

    [[AFMrTickTockAPIClient sharedClient] postPath:@"get_tasks" parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary * JSON) {

        NSArray * errors = [JSON objectForKey:@"errors"];
        if (errors.count) {
            [self showError:[errors objectAtIndex:0]];

            return;
        }

        NSArray * fetchedTasks = [JSON objectForKey:@"content"];
        int i = 0;

        for (NSDictionary * attributes in fetchedTasks) {
            Task * localTask = [Task createEntity];

                localTask.id = [NSNumber numberWithInteger:[[attributes valueForKey:@"id"] integerValue]];
                localTask.name = [attributes objectForKey:@"task_name"];
                localTask.isClosed = [NSNumber numberWithBool:[[attributes valueForKey:@"closed"] boolValue]];
                localTask.isVisible = [NSNumber numberWithBool:[[attributes valueForKey:@"visibility"] isEqualToString:@"visible"]];
                localTask.isRunning = NO;

                localTask.projectId = [NSNumber numberWithInteger:[[attributes valueForKey:@"project_id"] integerValue]];
                localTask.projectName = [attributes valueForKey:@"project_name"];

                localTask.customerId = [NSNumber numberWithInteger:[[attributes valueForKey:@"customer_id"] integerValue]];
                localTask.customerName = [attributes valueForKey:@"customer_name"];

                if ([localTask.id integerValue] == runningTaskId) {
                    runningTaskIndex = i;
                    localTask.isRunning = @YES;
                }
            i++;
        }

        [SVProgressHUD dismiss];
        
        _tasks = [Task findAll];
        [_table reloadData];
        
        [self getTasksTime];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showError:error.description];
    }];
}

- (void)getTasksTime {
    return;
    for (NSUInteger i = 0; i < _tasks.count; i++) {
        Task * task = [_tasks objectAtIndex:i];

        NSMutableDictionary * params = [[NSMutableDictionary alloc] initWithDictionary:[[AFMrTickTockAPIClient sharedClient] authParams]];
        [params setObject:task.id forKey:@"task_id"];

        [[AFMrTickTockAPIClient sharedClient] postPath:@"get_task_details" parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary * JSON) {
            NSArray * errors = [JSON objectForKey:@"errors"];
            if (errors.count) {
                return;
            }

            NSDictionary * attributes = [JSON objectForKey:@"content"];

            task.time = [attributes objectForKey:@"timer_time"];
            task.totalTime = [attributes objectForKey:@"total_time"];

//            [task save];
//
//            _tasks = [Task all];
            [_table reloadData];

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {}];
    }
}

- (void)setRunningTask:(NSInteger)index {
    Task * task = [_tasks objectAtIndex:index];

    [SVProgressHUD show];

    NSMutableDictionary * params = [[NSMutableDictionary alloc] initWithDictionary:[[AFMrTickTockAPIClient sharedClient] authParams]];
    [params setObject:task.id forKey:@"task_id"];

    [[AFMrTickTockAPIClient sharedClient] postPath:@"start_timer" parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary * JSON) {
        NSArray * errors = [JSON objectForKey:@"errors"];
        if (errors.count) {
            [self showError:[errors objectAtIndex:0]];
            
            return;
        }

        if (runningTaskIndex != -1) {
            Task * runningTask = [_tasks objectAtIndex:runningTaskIndex];
            runningTask.isRunning = NO;
        }

        task.isRunning = @YES;

        runningTaskIndex = index;
        runningTaskId = [task.id integerValue];

        [SVProgressHUD dismiss];
        [_table reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showError:error.description];
    }];
}

- (void)stopRunningTask {
    if (runningTaskIndex == -1) {
        return;
    }

    [SVProgressHUD show];

    Task * task = [_tasks objectAtIndex:runningTaskIndex];

    NSMutableDictionary * params = [[NSMutableDictionary alloc] initWithDictionary:[[AFMrTickTockAPIClient sharedClient] authParams]];
    [params setObject:task.id forKey:@"task_id"];

    [[AFMrTickTockAPIClient sharedClient] postPath:@"stop_timer" parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary * JSON) {
        NSArray * errors = [JSON objectForKey:@"errors"];
        if (errors.count) {
            [self showError:[errors objectAtIndex:0]];
            
            return;
        }

        task.isRunning = NO;

        runningTaskIndex = -1;
        runningTaskId = -1;

        [SVProgressHUD dismiss];
        [_table reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showError:error.description];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _tasks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TaskCell * cell;

    if (isIOS6) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"TASK_CELL" forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"TASK_CELL"];
    }

    Task * task = [_tasks objectAtIndex:indexPath.row];

    cell.projectName.text = [NSString stringWithFormat:@"%@ (%@)", task.projectName, task.name];
//    cell.taskName.text = task.totalTime != @"" ? [NSString stringWithFormat:@"%@ (%@ total)", task.time, task.totalTime] : @"";

    return cell;
}

- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
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

- (void)showError:(NSString *)error {
    [SVProgressHUD dismiss];

    [[[UIAlertView alloc] initWithTitle:@"Error"
                               message:error
                              delegate:self
                     cancelButtonTitle: @"OK"
                     otherButtonTitles: nil] show];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (viewController == self) {
        [self getActiveTimer];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self logout];
    }
}

@end
