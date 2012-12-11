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

//    UITextView * urlLabel = [[UITextView alloc] initWithFrame:CGRectZero];
//    urlLabel.editable = NO;
//    urlLabel.dataDetectorTypes = UIDataDetectorTypeLink;
//    urlLabel.text = @"http://mrticktock.com";
//    urlLabel.textColor = UIColor.whiteColor;
//    urlLabel.backgroundColor = UIColor.clearColor;
//    urlLabel.frame = CGRectMake(0, self.view.frame.size.height - 75, self.view.frame.size.width, 30);
//
//    [self.view addSubview:urlLabel];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
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
    cell.titleLabel.font = [UIFont boldSystemFontOfSize:20];

    UIView * selectedBackground = [[UIView alloc] init];
    selectedBackground.backgroundColor = [UIColor colorWithRed:0.213 green:0.231 blue:0.270 alpha:1.000];

    cell.selectedBackgroundView = selectedBackground;

    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate * app = [[UIApplication sharedApplication] delegate];

    if (indexPath.row == MenuActionLogout) {
        [app.deckController showCenterView:YES completion:^(IIViewDeckController *controller) {
            [ACSimpleKeychain.defaultKeychain deleteAllCredentialsForService:@"MrTickTock"];
            
            [app.centerController popViewControllerAnimated:YES];
        }];

        return nil;
    }

    [app.deckController showCenterView:YES];

    return nil;
}

@end
