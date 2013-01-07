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

    UILabel * _totalLabel;
    UILabel * _totalTimeLabel;
    UIView * _toolbar;

    NSIndexPath * tappedCellIndexPath;
    NSIndexPath * actionsCellIndexPath;
}

@end

@implementation TasksViewController

@synthesize table = _table;

- (void)viewDidLoad
{
    [super viewDidLoad];

    _isIOS6 =  NSClassFromString(@"UIRefreshControl") != nil;

    tappedCellIndexPath = nil;
    actionsCellIndexPath = nil;

    self.navigationController.delegate = self;
    self.navigationItem.hidesBackButton = YES;

    CKRefreshControl * refreshControl = [CKRefreshControl new];

    self.refreshControl = (id)refreshControl;

    if (_isIOS6) {
        self.refreshControl.tintColor = [UIColor colorWithWhite:0.555 alpha:1.000];
    }

    [self.refreshControl addTarget:self action:@selector(refreshInvoked:forState:) forControlEvents:UIControlEventValueChanged];

    [self setupNavBar];
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

- (void)setupNavBar
{
    self.titleLabel.text = @"My Tasks";
    self.titleLabel.textColor = UIColor.whiteColor;
    self.titleLabel.font = [UIFont fontWithName:@"ProximaNova-Bold" size:20];

    [self.navigationItem.leftBarButtonItem setTitlePositionAdjustment:UIOffsetMake(-3, 3) forBarMetrics:UIBarMetricsDefault];

    NSDictionary * textAttributes = @{
        [UIFont fontWithName:@"ProximaNova-Bold" size:20]: UITextAttributeFont,
        UITextAttributeTextShadowColor: KNavbarBackgroundColor
    };

    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
    [self.navigationItem.rightBarButtonItem setTitlePositionAdjustment:UIOffsetMake(8, 3) forBarMetrics:UIBarMetricsDefault];

    // Hide for now
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)setupToolbar
{
    _toolbar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 44)];
    _toolbar.backgroundColor = KToolbarBackgroundColor;
    _toolbar.tag = KToolbarTag;

    [self.navigationController.navigationBar addSubview:_toolbar];

    _totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 12, 150, 20)];
    _totalLabel.text = @"";
    _totalLabel.font = [UIFont fontWithName:@"ProximaNova-Regular" size:12];
    _totalLabel.textColor = [UIColor colorWithWhite:0.555 alpha:1.000];
    _totalLabel.backgroundColor = UIColor.clearColor;

    _totalTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(_toolbar.frame.size.width - 82, 12, 70, 20)];
    _totalTimeLabel.text = @"";
    _totalTimeLabel.font = [UIFont fontWithName:@"ProximaNova-Regular" size:18];
    _totalTimeLabel.textColor = [UIColor colorWithWhite:0.555 alpha:1.000];
    _totalTimeLabel.textAlignment = UITextAlignmentRight;
    _totalTimeLabel.backgroundColor = UIColor.clearColor;

    [_toolbar addSubview:_totalLabel];
    [_toolbar addSubview:_totalTimeLabel];
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
    [self hideToolbar:YES];

    [tasksManager sync];

    [_table reloadData];
}

- (void)hideToolbar:(BOOL)animated
{
    CGRect toolbarFrame = _toolbar.frame;

    if (animated) {
        [UIView transitionWithView:self.navigationController.toolbar duration:(animated ? .3 : 0)
                           options:UIViewAnimationOptionTransitionNone
                        animations:^{
                            _toolbar.frame = CGRectMake(toolbarFrame.origin.x, self.view.frame.size.height + 44, toolbarFrame.size.width, toolbarFrame.size.height);
                        }
                        completion:^(BOOL finished) {
                            _totalLabel.text = @"";
                            _totalTimeLabel.text = @"";
                        }];
    } else {
        _toolbar.frame = CGRectMake(toolbarFrame.origin.x, self.view.frame.size.height + 44, toolbarFrame.size.width, toolbarFrame.size.height);

        _totalLabel.text = @"";
        _totalTimeLabel.text = @"";
    }
}

- (void)showToolbar:(BOOL)animated
{
    CGRect toolbarFrame = _toolbar.frame;

    if (animated) {
        [UIView transitionWithView:self.navigationController.toolbar duration:(animated ? .3 : 0)
                           options:UIViewAnimationOptionTransitionNone
                        animations:^{
                            _toolbar.frame = CGRectMake(toolbarFrame.origin.x, self.view.frame.size.height, toolbarFrame.size.width, toolbarFrame.size.height);
                        }
                        completion:nil];
    } else {
        _toolbar.frame = CGRectMake(toolbarFrame.origin.x, self.view.frame.size.height, toolbarFrame.size.width, toolbarFrame.size.height);
    }
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
    headerView.opaque = YES;

    UILabel * customerLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, self.tableView.bounds.size.width, 22)];
    customerLabel.backgroundColor = headerView.backgroundColor;
    customerLabel.text = customer;
    customerLabel.textColor = [UIColor colorWithWhite:0.555 alpha:1.000];
    customerLabel.font = [UIFont fontWithName:@"ProximaNova-Regular" size:12];
    customerLabel.opaque = YES;

    [headerView addSubview:customerLabel];

    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView * footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 43)];
    footerView.backgroundColor = UIColor.clearColor;

    return footerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tasksManager.syncing) {
        return 0;
    }

    NSString * customer = [tasksManager.customers objectAtIndex:section];

    if (actionsCellIndexPath && actionsCellIndexPath.section == section) {
        return [tasksManager tasksForCustomer:customer].count + 1;
    }

    return [tasksManager tasksForCustomer:customer].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == tasksManager.customers.count - 1) {
        return 43;
    }

    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath isEqual:actionsCellIndexPath]){
        return 50;
    }

    return 67;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Task * task;

    if ([indexPath isEqual:actionsCellIndexPath]) {
        TaskActionsCell * cell;

        if (_isIOS6) {
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"TASK_ACTIONS_CELL" forIndexPath:indexPath];
        } else {
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"TASK_ACTIONS_CELL"];
        }

        task = [tasksManager taskAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section]];

        cell.task = task;
        cell.delegate = self;

        [cell didMoveToSuperview];

        return cell;
    }

    TaskCell * cell;

    if (actionsCellIndexPath && indexPath.section == actionsCellIndexPath.section && indexPath.row >= actionsCellIndexPath.row) {
        indexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
    }

    task = [tasksManager taskAtIndexPath:indexPath];

    if (_isIOS6) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"TASK_CELL" forIndexPath:indexPath];
    } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"TASK_CELL"];
    }

    cell.shoudDrawSeparator = indexPath.row > 0;

    cell.contentView.backgroundColor = task.isRunning ? KTaskCellRunningBackgroundColor : [UIColor whiteColor];

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

    cell.projectName.backgroundColor = cell.contentView.backgroundColor;
    cell.taskName.backgroundColor = cell.contentView.backgroundColor;
    cell.taskTime.backgroundColor = cell.contentView.backgroundColor;
    cell.toggleButton.backgroundColor = cell.contentView.backgroundColor;

    cell.projectName.font = [UIFont fontWithName:@"ProximaNova-Regular" size:18];
    cell.taskName.font = [UIFont fontWithName:@"ProximaNova-Regular" size:12];
    cell.taskTime.font = [UIFont fontWithName:@"ProximaNova-Regular" size:18];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (actionsCellIndexPath && [indexPath isEqual:actionsCellIndexPath]) {
        return;
    }

    if (actionsCellIndexPath != nil && actionsCellIndexPath.section == indexPath.section && indexPath.row > actionsCellIndexPath.row) {
        indexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
    }

    NSIndexPath * indexPathToDelete = actionsCellIndexPath;

    if ([indexPath isEqual:tappedCellIndexPath]) {
        tappedCellIndexPath = nil;
        actionsCellIndexPath = nil;
    } else {
        tappedCellIndexPath = indexPath;
        actionsCellIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
    }

    [tableView beginUpdates];

    if (indexPathToDelete) {
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPathToDelete] withRowAnimation:UITableViewRowAnimationTop];
    }

    if (actionsCellIndexPath) {
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:actionsCellIndexPath] withRowAnimation:UITableViewRowAnimationTop];
    }

    [tableView endUpdates];

    if (actionsCellIndexPath) {
        NSInteger totalSections = [self numberOfSectionsInTableView:tableView];
        NSInteger totalRows = [self tableView:tableView numberOfRowsInSection:totalSections - 1];

        if ([actionsCellIndexPath isEqual:[NSIndexPath indexPathForRow:totalRows - 1 inSection:totalSections - 1]]) {
            [tableView scrollToRowAtIndexPath:actionsCellIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }
}

- (IBAction)toggleButtonTouched:(UIButton *)button
{
    NSInteger taskId = button.tag;

    Task * task = [tasksManager taskById:taskId];

    if (task) {
        [tasksManager toggleTask:task sync:YES];
    }
}

- (NSString *)timeString:(NSString *)time
{
    NSDate * date = [NSDate dateFromString:[NSString stringWithFormat:@"2012-01-01 %@:00", time]];
    
    return [date stringWithFormat:@"HH:mm"];
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

    _totalLabel.text = @"Total today";
    _totalTimeLabel.text = [NSDate stringFromDate:tasksManager.totalTimeDate withFormat:@"HH:mm"];

    [self showToolbar:YES];
}

#pragma mark -
#pragma mark TaskActionsCellDelegate methods
#pragma mark -

- (void)setTaskTime:(Task *)task time:(NSString *)time
{
    [tasksManager setTaskTime:task time:time];
}

@end
