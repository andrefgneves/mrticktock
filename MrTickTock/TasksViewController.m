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
#import <CKRefreshControl/CKRefreshControl.h>

@interface TasksViewController ()
{
    ACSimpleKeychain * _keychain;

    TasksManager * tasksManager;

    BOOL _isIOS6;

    UILabel * _totalTimeLabel;
}

@end

@implementation TasksViewController

@synthesize table = _table;

- (void)viewDidLoad
{
    [super viewDidLoad];

    _isIOS6 =  NSClassFromString(@"UIRefreshControl") != nil;

    self.navigationController.delegate = self;
    self.navigationItem.hidesBackButton = YES;

    CKRefreshControl * refreshControl = [CKRefreshControl new];

    self.refreshControl = (id)refreshControl;

    if (_isIOS6) {
        self.refreshControl.tintColor = [UIColor colorWithWhite:0.555 alpha:1.000];
    }

    [self.refreshControl addTarget:self action:@selector(refreshInvoked:forState:) forControlEvents:UIControlEventValueChanged];

    [self setupToolbar];

    _keychain = [ACSimpleKeychain defaultKeychain];

    tasksManager = [TasksManager sharedTasksManager];
    tasksManager.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    AppDelegate * app = [[UIApplication sharedApplication] delegate];

    app.deckController.panningMode = IIViewDeckFullViewPanning;
}

- (void)setupToolbar
{
    _totalTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.navigationController.navigationBar.frame.size.width - 85, 13, 70, 20)];
    _totalTimeLabel.text = @"";
    _totalTimeLabel.font = [UIFont fontWithName:@"ProximaNova-Regular" size:18];
    _totalTimeLabel.textColor = UIColor.whiteColor;
    _totalTimeLabel.textAlignment = UITextAlignmentRight;
    _totalTimeLabel.backgroundColor = KNavbarBackgroundColor;
    _totalTimeLabel.tag = 1000;

    [self.navigationController.navigationBar addSubview:_totalTimeLabel];
}

-(void)refreshInvoked:(id)sender forState:(UIControlState)state
{
    [self.refreshControl endRefreshing];

    [self reload];
}

- (void)showMenu:(id)sender
{
    AppDelegate * app = [[UIApplication sharedApplication] delegate];

    [app.deckController toggleLeftViewAnimated:YES];
}

- (void)reload
{
    _totalTimeLabel.text = @"";

    [tasksManager sync];

    [_table reloadData];
}

#pragma mark -
#pragma mark TableView
#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return tasksManager.syncing ? 0 : tasksManager.customers.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString * customer = [tasksManager.customers objectAtIndex:section];

    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 15)];
    headerView.backgroundColor = [UIColor colorWithWhite:0.933 alpha:1.000];

    UILabel * customerLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, self.tableView.bounds.size.width, 22)];
    customerLabel.backgroundColor = UIColor.clearColor;
    customerLabel.text = customer;
    customerLabel.textColor = [UIColor colorWithWhite:0.555 alpha:1.000];
    customerLabel.font = [UIFont fontWithName:@"ProximaNova-Regular" size:12];

    [headerView addSubview:customerLabel];

    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tasksManager.syncing) {
        return 0;
    }

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

    cell.contentView.backgroundColor = task.isRunning ? [UIColor colorWithRed:0.537 green:0.805 blue:0.184 alpha:1.000] : [UIColor whiteColor];

    UIColor * textColor = task.isRunning ? [UIColor whiteColor] : [UIColor colorWithWhite:0.555 alpha:1.000];

    cell.projectName.text = task.projectName;
    cell.projectName.textColor = textColor;

    cell.taskName.text = task.name;
    cell.taskName.textColor = textColor;

    cell.taskTime.text = [self timeString:task.totalTime != @"" ? task.totalTime : @"00:00"];
    cell.taskTime.textColor = textColor;

    cell.toggleButton.tag = task.id;
    cell.toggleButton.titleLabel.text = task.customerName;
    cell.toggleButton.running = task.isRunning;

    cell.projectName.font = [UIFont fontWithName:@"ProximaNova-Regular" size:18];
    cell.taskName.font = [UIFont fontWithName:@"ProximaNova-Regular" size:12];
    cell.taskTime.font = [UIFont fontWithName:@"ProximaNova-Regular" size:18];

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
#pragma mark tasksManagerDelegate methods
#pragma mark -

- (void)taskManagerDidFinishSyncing:(TasksManager *)aTasksManager
{
    [_table reloadData];

    _totalTimeLabel.text = [NSDate stringFromDate:tasksManager.totalTimeDate withFormat:@"HH:mm"];
}

@end
