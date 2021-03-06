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
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Utils.h"

typedef enum {
    MenuActionMyTasks,
    MenuActionWebsite,
    MenuActionDivider,
    MenuActionLogout,
    MenuActionsCount
} MenuActions;

@interface MenuViewController()

@property (weak, nonatomic) IBOutlet MenuCell * mytTasksCell;
@property (weak, nonatomic) IBOutlet MenuCell * websiteCell;
@property (weak, nonatomic) IBOutlet MenuCell * dividerCell;
@property (weak, nonatomic) IBOutlet MenuCell * logoutCell;

@end

@implementation MenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"";

    [self setupCells];
}

- (void)setupCells
{
    UIFont * iconFont = [UIFont fontWithName:@"mrticktock" size:20];
    UIFont * titleFont = [UIFont fontWithName:@"ProximaNova-Regular" size:20];

    UIView * selectedBackground = [[UIView alloc] init];
    selectedBackground.backgroundColor = [UIColor colorWithRed:0.212 green:0.227 blue:0.267 alpha:1.000];

    self.mytTasksCell.iconLabel.font = iconFont;
    self.mytTasksCell.titleLabel.font = titleFont;
    self.mytTasksCell.selectedBackgroundView = selectedBackground;
    self.mytTasksCell.arrowLabel.font = iconFont;

    self.websiteCell.iconLabel.font = iconFont;
    self.websiteCell.titleLabel.font = titleFont;
    self.websiteCell.selectedBackgroundView = selectedBackground;
    self.websiteCell.arrowLabel.font = iconFont;

    self.logoutCell.iconLabel.font = iconFont;
    self.logoutCell.titleLabel.font = titleFont;
    self.logoutCell.selectedBackgroundView = selectedBackground;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == MenuActionDivider) {
        return self.tableView.frame.size.height - self.mytTasksCell.frame.size.height - self.websiteCell.frame.size.height - self.logoutCell.frame.size.height;
    }

    return 45;
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

- (void)confirmLogout
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

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    UIImage * background = [UIImage imageWithColor:[UIColor colorWithWhite:0 alpha:.7] andSize:CGSizeMake(1, 1)];
    [[actionSheet layer] setContents:(id)background.CGImage];
}

@end
