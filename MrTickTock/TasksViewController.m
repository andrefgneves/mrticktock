//
//  ViewController.m
//  MrTickTock
//
//  Created by André Neves on 9/26/12.
//  Copyright (c) 2012 André Neves. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TasksViewController.h"
#import "AFMrTickTockAPIClient.h"
#import "Task.h"
#import "TaskCell.h"
#import "ACSimpleKeychain.h"
#import "SVProgressHUD.h"
#import "IIViewDeckController.h"
#import "Task.h"
#import "TasksManager.h"
#import "NSDate+Helper.h"
#import "AppDelegate.h"
#import "Constants.h"

@interface TasksViewController ()
{
    NSMutableArray * _tasks;
    NSMutableArray * _searchResults;
    NSMutableArray * _taskNames;
    ACSimpleKeychain * _keychain;
    TasksManager * _taskManager;
    BOOL _isIOS6;
    BOOL _isSearching;
    UILabel * _totalTimeLabel;
}

@end

@implementation TasksViewController

@synthesize table = _table;
@synthesize searchBar = _searchBar;

- (void)viewDidLoad
{
    [super viewDidLoad];

    _isIOS6 =  NSClassFromString(@"UIRefreshControl") != nil;

    self.navigationController.delegate = self;
    self.navigationItem.hidesBackButton = YES;

    if (_isIOS6) {
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl addTarget:self action:@selector(refreshInvoked:forState:) forControlEvents:UIControlEventValueChanged];
        self.refreshControl.tintColor = KNavbarBackgroundColor;
    } else {
        UIBarButtonItem * refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                        target:self
                                                                                        action:@selector(refreshInvoked:forState:)];
        self.navigationItem.rightBarButtonItem = refreshButton;
    }

    [self setupToolbar];

    _keychain = [ACSimpleKeychain defaultKeychain];
    _taskManager = [TasksManager sharedTasksManager];
    _tasks = [NSMutableArray array];
    _searchResults = [NSMutableArray array];
    _isSearching = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    self.viewDeckController.panningMode = IIViewDeckNavigationControllerIntegrated;
}

- (void)setupToolbar
{
    _totalTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    _totalTimeLabel.text = @"00:00";
    _totalTimeLabel.font = [UIFont fontWithName:@"ProximaNova-Bold" size:20];
    _totalTimeLabel.textColor = UIColor.whiteColor;
    _totalTimeLabel.backgroundColor = KNavbarBackgroundColor;

    UIBarButtonItem * totalTime = [[UIBarButtonItem alloc] initWithCustomView:_totalTimeLabel];

    self.navigationController.toolbarHidden = NO;
    self.toolbarItems = @[totalTime];
}

-(void) refreshInvoked:(id)sender forState:(UIControlState)state
{
    if (_isIOS6) {
        [self.refreshControl endRefreshing];
    }

    [self getActiveTimer];
}

- (void)showMenu:(id)sender
{
    AppDelegate * app = [[UIApplication sharedApplication] delegate];

    [app.deckController toggleLeftViewAnimated:YES];
}

- (void)showLogin
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)confirmLogout:(id)sender
{
    [[[UIActionSheet alloc] initWithTitle:@"Really logout?"
                                 delegate:self
                        cancelButtonTitle:@"Cancel"
                   destructiveButtonTitle:@"Logout"
                        otherButtonTitles: nil] showInView:self.view];
}

- (void)logout
{
    [_keychain deleteAllCredentialsForService:@"MrTickTock"];

    _tasks = nil;
    [_table reloadData];

    [self showLogin];
}

- (void)getActiveTimer
{
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
            _taskManager.runningTaskId = [[response objectForKey:@"task_id"] integerValue];
        } else {
            _taskManager.hasRunningTask = NO;
            _taskManager.runningTaskId = -1;
            _taskManager.runningTaskIndex = -1;
        }

        [TestFlight passCheckpoint:@"USER_LOGGED_IN"];

        [self refreshTasks];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showError:error.description];
    }];
}

- (void)refreshTasks
{
    [_tasks removeAllObjects];
    [_table reloadData];

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

        LOG_EXPR([JSON objectForKey:@"content"]);

        int i = 0;
        for (NSDictionary * attributes in [JSON objectForKey:@"content"]) {
            Task * task = [[Task alloc] initWithAttributes:attributes];

            if (task.id == _taskManager.runningTaskId) {
                _taskManager.runningTaskIndex = i;
                _taskManager.hasRunningTask = YES;
                task.isRunning = YES;
            }

            [_tasks addObject:task];

            i++;
        }

        [SVProgressHUD dismiss];

        [_table reloadData];

        [self getTasksTime];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showError:error.description];
    }];
}

- (void)getTasksTime
{
    __block NSDate * totalTimeDate = [NSDate dateFromString:@"2012-01-01 00:00:00"];

    for (NSUInteger i = 0; i < _tasks.count; i++) {
        Task * task = [_tasks objectAtIndex:i];

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

            totalTimeDate = [totalTimeDate dateByAddingTimeInterval:taskTotalTimeInterval];
            _totalTimeLabel.text = [NSDate stringFromDate:totalTimeDate withFormat:@"HH:mm"];

            [_tasks replaceObjectAtIndex:i withObject:task];

            [_table reloadData];

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {}];
    }
}

- (void)setRunningTask:(NSInteger)index
{
    Task * task = [_tasks objectAtIndex:index];

    [SVProgressHUD show];

    NSMutableDictionary * params = [[NSMutableDictionary alloc] initWithDictionary:[[AFMrTickTockAPIClient sharedClient] authParams]];
    [params setObject:[NSString stringWithFormat:@"%d", task.id] forKey:@"task_id"];

    [[AFMrTickTockAPIClient sharedClient] postPath:@"start_timer" parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary * JSON) {
        NSArray * errors = [JSON objectForKey:@"errors"];
        if (errors.count) {
            [self showError:[errors objectAtIndex:0]];
            
            return;
        }

        if (_taskManager.runningTaskIndex != -1) {
            Task * runningTask = [_tasks objectAtIndex:_taskManager.runningTaskIndex];
            runningTask.isRunning = NO;
        }

        task.isRunning = YES;

        _taskManager.hasRunningTask = YES;
        _taskManager.runningTaskIndex = index;
        _taskManager.runningTaskId = task.id;

        [SVProgressHUD dismiss];
        [_table reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showError:error.description];
    }];
}

- (void)stopRunningTask
{
    if (_taskManager.runningTaskIndex == -1) {
        return;
    }

    [SVProgressHUD show];

    Task * task = [_tasks objectAtIndex:_taskManager.runningTaskIndex];

    NSMutableDictionary * params = [[NSMutableDictionary alloc] initWithDictionary:[[AFMrTickTockAPIClient sharedClient] authParams]];
    [params setObject:[NSString stringWithFormat:@"%d", task.id] forKey:@"task_id"];

    [[AFMrTickTockAPIClient sharedClient] postPath:@"stop_timer" parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary * JSON) {
        NSArray * errors = [JSON objectForKey:@"errors"];
        if (errors.count) {
            [self showError:[errors objectAtIndex:0]];

            return;
        }

        task.isRunning = NO;

        _taskManager.hasRunningTask = NO;
        _taskManager.runningTaskIndex = -1;
        _taskManager.runningTaskId = -1;

        [SVProgressHUD dismiss];
        [_table reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showError:error.description];
    }];
}

- (void)showError:(NSString *)error
{
    [SVProgressHUD dismiss];

    [[[UIAlertView alloc] initWithTitle:@"Error"
                               message:error
                              delegate:self
                     cancelButtonTitle: @"OK"
                     otherButtonTitles: nil] show];
}

#pragma mark -
#pragma mark TableView
#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _isSearching ? _searchResults.count : _tasks.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TaskCell * cell;

    if (_isIOS6) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"TASK_CELL" forIndexPath:indexPath];
    } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"TASK_CELL"];
    }

    Task * task = [_isSearching ? _searchResults : _tasks objectAtIndex:indexPath.row];

    cell.contentView.backgroundColor = task.isRunning ? [UIColor colorWithRed:0.553 green:0.902 blue:0.180 alpha:1.000] : [UIColor colorWithRed:0.804 green:0.890 blue:0.969 alpha:1.000];

    UIColor * textColor = task.isRunning ? [UIColor whiteColor] : [UIColor colorWithRed:0.267 green:0.561 blue:0.710 alpha:1.000];

    cell.projectName.text = task.projectName;
    cell.projectName.textColor = textColor;

    cell.taskName.text = task.name;
    cell.taskName.textColor = textColor;

    cell.taskTime.text = [self timeString:task.totalTime != @"" ? task.totalTime : @"00:00"];
    cell.taskTime.textColor = textColor;

    cell.toggleButton.tag = indexPath.row;
    cell.toggleButton.running = task.isRunning;

    cell.projectName.font = [UIFont fontWithName:@"ProximaNova-Bold" size:20];
    cell.taskName.font = [UIFont fontWithName:@"ProximaNova-Bold" size:11];
    cell.taskTime.font = [UIFont fontWithName:@"ProximaNova-Bold" size:20];

    return cell;
}

- (NSString *)timeString:(NSString *)time
{
    NSDate * date = [NSDate dateFromString:[NSString stringWithFormat:@"2012-01-01 %@:00", time]];

    return [date stringWithFormat:@"HH:mm"];
}

- (IBAction)toggleButtonTouched:(UIButton *)button
{
    NSInteger index = button.tag;

    if (index == _taskManager.runningTaskIndex) {
        [self stopRunningTask];
    } else {
        [self setRunningTask:index];
    }
}

#pragma mark -
#pragma mark UINavigation
#pragma mark -

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (viewController == self) {
        [self getActiveTimer];
    }
}

#pragma mark -
#pragma mark UIActionSheet
#pragma mark -

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self logout];
    }
}

#pragma mark -
#pragma mark UISearchBar
#pragma mark -

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    _searchResults = [NSMutableArray arrayWithArray:_tasks];
    _isSearching = YES;

    _taskNames = [NSMutableArray array];

    for (Task * task in _tasks) {
        [_taskNames addObject:[NSString stringWithFormat:@"%@ %@", [task.projectName lowercaseString], [task.name lowercaseString]]];
    }

    _table.allowsSelection = NO;
    _table.scrollEnabled = NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";

    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];

    _isSearching = NO;

    _table.allowsSelection = YES;
    _table.scrollEnabled = YES;

    [_table reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSMutableArray * results = [NSMutableArray array];
    searchText = [searchText lowercaseString];

    int i = 0;
    for (NSString * name in _taskNames) {
        if (([searchText isEqualToString:@""]) ||[name rangeOfString:searchText].length > 0) {
            [results addObject:[_tasks objectAtIndex:i]];
        }

        i++;
    }

    _searchResults = results;
    [_table reloadData];
}

@end
