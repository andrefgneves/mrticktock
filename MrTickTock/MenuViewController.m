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

@implementation MenuViewController

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
