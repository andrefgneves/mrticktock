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
#import "NSObject+PerformBlock.h"

typedef enum {
    MenuActionMyTasks,
    MenuActionWebsite,
    MenuActionDivider,
    MenuActionLogout,
    MenuActionsCount
} MenuActions;

@interface MenuViewController()
{
    BOOL _isIOS6;
}

@property (weak, nonatomic) IBOutlet MenuCell * mytTasksCell;
@property (weak, nonatomic) IBOutlet MenuCell * websiteCell;
@property (weak, nonatomic) IBOutlet MenuCell * logoutCell;

@end

@implementation MenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _isIOS6 =  NSClassFromString(@"UIRefreshControl") != nil;

    self.title = @"";

    [self setupCells];
}

- (void)setupCells
{
    UIFont * iconFont = [UIFont fontWithName:@"mrticktock" size:20];
    UIFont * titleFont = [UIFont fontWithName:@"ProximaNova-Bold" size:20];

    UIView * selectedBackground = [[UIView alloc] init];
    selectedBackground.backgroundColor = [UIColor colorWithRed:0.212 green:0.227 blue:0.267 alpha:1.000];

    self.mytTasksCell.iconLabel.font = iconFont;
    self.mytTasksCell.titleLabel.font = titleFont;
    self.mytTasksCell.selectedBackgroundView = selectedBackground;

    self.websiteCell.iconLabel.font = iconFont;
    self.websiteCell.titleLabel.font = titleFont;
    self.websiteCell.selectedBackgroundView = selectedBackground;

    self.logoutCell.iconLabel.font = iconFont;
    self.logoutCell.titleLabel.font = titleFont;
    self.logoutCell.selectedBackgroundView = selectedBackground;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == MenuActionLogout) {
        [self confirmLogout];

        return nil;
    }

    AppDelegate * app = [[UIApplication sharedApplication] delegate];

    if (indexPath.row == MenuActionMyTasks) {
        [app showTasks];

        return nil;
    }

    if (indexPath.row == MenuActionWebsite) {
        [SVProgressHUD dismiss];

        [app showWebsite];

        return nil;
    }

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

        app.deckController.leftSize = 0;

        [self performBlock:^{
            [ACSimpleKeychain.defaultKeychain deleteAllCredentialsForService:@"MrTickTock"];

            app.deckController.centerController = app.tasksController;
            [app.tasksController popViewControllerAnimated:NO];

            [app.deckController closeLeftViewAnimated:YES completion:nil];

            app.deckController.leftSize = 100;
        } afterDelay:0.3];
    }
}

- (void)websiteClicked:(NSString *)link
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:link]];
}

@end
