//
//  MenuViewController.m
//  MrTickTock
//
//  Created by André Neves on 10/27/12.
//  Copyright (c) 2012 André Neves. All rights reserved.
//

#import "MenuViewController.h"
#import "AppDelegate.h"
#import "ACSimpleKeychain.h"
#import "TasksViewController.h"
#import "MenuCell.h"

@interface MenuViewController()
{
    BOOL _isIOS6;
}

@end

@implementation MenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _isIOS6 =  NSClassFromString(@"UIRefreshControl") != nil;

    self.title = @"";

    STTweetLabel * urlLabel = [[STTweetLabel alloc] init];

    urlLabel.delegate = self;
    urlLabel.font = [UIFont fontWithName:@"ProximaNova-Bold" size:10];
    urlLabel.text = @"http://mrticktock.com";
    urlLabel.textColor = UIColor.whiteColor;
    urlLabel.backgroundColor = UIColor.clearColor;
    urlLabel.frame = CGRectMake(10, self.view.frame.size.height - 70, self.view.frame.size.width, 30);

    [self.view addSubview:urlLabel];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return MenuActionsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MenuCell * cell;

    if (_isIOS6) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"MENU_CELL" forIndexPath:indexPath];
    } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"MENU_CELL"];
    }

    cell.iconLabel.text = indexPath.row ? @"e" : @"f";
    cell.titleLabel.text = indexPath.row ? @"Logout" : @"My Tasks";

    cell.iconLabel.font = [UIFont fontWithName:@"mrticktock" size:20];
    cell.titleLabel.font = [UIFont fontWithName:@"ProximaNova-Bold" size:20];

    UIView * selectedBackground = [[UIView alloc] init];
    selectedBackground.backgroundColor = [UIColor colorWithRed:0.213 green:0.231 blue:0.270 alpha:1.000];

    cell.selectedBackgroundView = selectedBackground;

    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == MenuActionLogout) {
        [self confirmLogout];

        return nil;
    }

    AppDelegate * app = [[UIApplication sharedApplication] delegate];

    [app.deckController closeLeftView];

    return nil;
}

- (IBAction)confirmLogout
{
    [[[UIActionSheet alloc] initWithTitle:@"Really logout?"
                                 delegate:self
                        cancelButtonTitle:@"Cancel"
                   destructiveButtonTitle:@"Logout"
                        otherButtonTitles: nil] showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        AppDelegate * app = [[UIApplication sharedApplication] delegate];

        [app.deckController closeLeftViewAnimated:YES completion:^(IIViewDeckController *controller, BOOL success) {
            [ACSimpleKeychain.defaultKeychain deleteAllCredentialsForService:@"MrTickTock"];

            [app.centerController popViewControllerAnimated:YES];
        }];
    }
}

- (void)websiteClicked:(NSString *)link
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:link]];
}

@end
