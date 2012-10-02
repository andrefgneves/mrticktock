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

@interface TasksViewController ()
{
    NSMutableArray * _tasks;
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

    _tasks = [[NSMutableArray alloc] init];
    runningTaskIndex = -1;
    runningTaskId = -1;
}

- (void)showLogoutButton:(BOOL)visible {
    self.navigationItem.leftBarButtonItem = visible ? self.logoutButton : nil;
}

-(void) refreshInvoked:(id)sender forState:(UIControlState)state {
    if (isIOS6) {
        [self.refreshControl endRefreshing];
    }

    [self checkCredentials];
}

- (void)checkCredentials {
    NSDictionary * credentials = [keychain credentialsForIdentifier:@"account" service:@"MrTickTock"];

    if (credentials) {
        [self getActiveTimer];
    } else {
        [self showLogin];
    }
}

- (void)showLogin {
    UIViewController * loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];

    [self.navigationController pushViewController:loginViewController animated:YES];
}

- (IBAction)logout:(id)sender {
    [keychain deleteAllCredentialsForService:@"MrTickTock"];

    [self showLogoutButton:NO];
    [_tasks removeAllObjects];
    [_table reloadData];

    [self showLogin];
}

- (void)getActiveTimer {
    [SVProgressHUD show];

    [[AFMrTickTockAPIClient sharedClient] postPath:@"is_timer_active" parameters:[[AFMrTickTockAPIClient sharedClient] authParams] success:^(AFHTTPRequestOperation *operation, NSDictionary * JSON) {

        NSArray * errors = [JSON objectForKey:@"errors"];
        if (errors.count) {
            [self showError:[errors objectAtIndex:0]];

            [self logout:nil];

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
    [_tasks removeAllObjects];
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

        [SVProgressHUD dismiss];
        [_table reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showError:error.description];
    }];
}

- (void)setRunningTask:(NSInteger)index {
    Task * task = [_tasks objectAtIndex:index];

    [SVProgressHUD show];

    NSMutableDictionary * params = [[NSMutableDictionary alloc] initWithDictionary:[[AFMrTickTockAPIClient sharedClient] authParams]];
    [params setObject:[NSNumber numberWithInteger:task.id] forKey:@"task_id"];

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

        task.isRunning = YES;

        runningTaskIndex = index;
        runningTaskId = task.id;

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
    [params setObject:[NSNumber numberWithInteger:task.id] forKey:@"task_id"];

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

    cell.projectName.text = task.projectName;
    cell.taskName.text = task.taskName;

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

- (void)showError:(NSString *)error {
    [SVProgressHUD dismiss];

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:error
                                                   delegate:self
                                          cancelButtonTitle: @"OK"
                                          otherButtonTitles: nil];

    [alert show];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (viewController == self) {
        [self checkCredentials];
    }
}

@end
