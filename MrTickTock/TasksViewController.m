//
//  ViewController.m
//  MrTickTock
//
//  Created by André Neves on 9/26/12.
//  Copyright (c) 2012 André Neves. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TasksViewController.h"
#import "Task.h"
#import "TaskCell.h"
#import "ACSimpleKeychain.h"
#import "IIViewDeckController.h"
#import "Task.h"
#import "AppDelegate.h"
#import "Constants.h"

@interface TasksViewController ()
{
    ACSimpleKeychain * _keychain;

    TasksManager * tasksManager;

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

    tasksManager = [TasksManager sharedTasksManager];
    tasksManager.delegate = self;

    _isSearching = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    self.tableView.contentOffset = CGPointMake(0, self.searchDisplayController.searchBar.frame.size.height);
}

- (void)setupToolbar
{
    _totalTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    _totalTimeLabel.text = @"00:00";
    _totalTimeLabel.font = [UIFont fontWithName:@"ProximaNova-Bold" size:20];
    _totalTimeLabel.textColor = UIColor.whiteColor;
    _totalTimeLabel.textAlignment = UITextAlignmentRight;
    _totalTimeLabel.backgroundColor = KNavbarBackgroundColor;

    UIBarButtonItem * space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem * totalTime = [[UIBarButtonItem alloc] initWithCustomView:_totalTimeLabel];

    self.navigationController.toolbarHidden = NO;
    self.toolbarItems = @[space, totalTime];
}

-(void)refreshInvoked:(id)sender forState:(UIControlState)state
{
    if (_isIOS6) {
        [self.refreshControl endRefreshing];
    }

    [self reload];
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

- (void)logout
{
    [_keychain deleteAllCredentialsForService:@"MrTickTock"];

    [tasksManager cleanup:YES];

    [_table reloadData];

    [self showLogin];
}

- (void)reload
{
    [SVProgressHUD show];
    [tasksManager sync];
}

#pragma mark -
#pragma mark TableView
#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return tasksManager.customers.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString * customer = [tasksManager.customers objectAtIndex:section];

    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 15)];
    headerView.backgroundColor = [UIColor colorWithRed:0.655 green:0.760 blue:0.875 alpha:1.000];

    UILabel * customerLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 0, self.tableView.bounds.size.width, 22)];
    customerLabel.backgroundColor = UIColor.clearColor;
    customerLabel.text = customer;
    customerLabel.textColor = UIColor.whiteColor;
    customerLabel.font = [UIFont fontWithName:@"ProximaNova-Bold" size:14];

    [headerView addSubview:customerLabel];

    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString * customer = [tasksManager.customers objectAtIndex:section];

    return [tasksManager tasksForCustomer:customer].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 67;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Task * task = [tasksManager taskAtIndexPath:indexPath];
    TaskCell * cell;

    if (_isIOS6) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"TASK_CELL" forIndexPath:indexPath];
    } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"TASK_CELL"];
    }

    cell.contentView.backgroundColor = task.isRunning ? [UIColor colorWithRed:0.553 green:0.902 blue:0.180 alpha:1.000] : [UIColor colorWithRed:0.804 green:0.890 blue:0.969 alpha:1.000];

    UIColor * textColor = task.isRunning ? [UIColor whiteColor] : [UIColor colorWithRed:0.267 green:0.561 blue:0.710 alpha:1.000];

    cell.projectName.text = task.projectName;
    cell.projectName.textColor = textColor;

    cell.taskName.text = task.name;
    cell.taskName.textColor = textColor;

    cell.taskTime.text = [self timeString:task.totalTime != @"" ? task.totalTime : @"00:00"];
    cell.taskTime.textColor = textColor;

    cell.toggleButton.tag = task.id;
    cell.toggleButton.titleLabel.text = task.customerName;
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
    NSInteger taskId = button.tag;

    Task * task = [tasksManager taskById:taskId];

    if (task) {
        [tasksManager toggleTask:task sync:YES];
    }
}

#pragma mark -
#pragma mark UINavigation
#pragma mark -

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    BOOL isLoggedIn = [ACSimpleKeychain.defaultKeychain credentialsForIdentifier:@"account" service:@"MrTickTock"] != nil;

    if (isLoggedIn && viewController == self) {
        [self reload];
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
    [tasksManager prepareSearch];

    _table.allowsSelection = NO;
    _table.scrollEnabled = NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";

    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];

    [tasksManager clearSearch];

    _table.allowsSelection = YES;
    _table.scrollEnabled = YES;

    [_table reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [tasksManager search:searchText];

    [_table reloadData];
}

#pragma mark -
#pragma mark tasksManagerDelegate methods
#pragma mark -

- (void)taskManagerDidFinishSyncing:(TasksManager *)aTasksManager
{
    [_table reloadData];

    _totalTimeLabel.text = [NSDate stringFromDate:tasksManager.totalTimeDate withFormat:@"HH:mm"];
}

@end
