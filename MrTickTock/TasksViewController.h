//
//  ViewController.h
//  MrTickTock
//
//  Created by André Neves on 9/26/12.
//  Copyright (c) 2012 André Neves. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TasksManager.h"

@interface TasksViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIActionSheetDelegate, UISearchBarDelegate, TaskManagerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *showMenuButton;

- (IBAction)showMenu:(id)sender;
- (IBAction)toggleButtonTouched:(UIButton *)button;

@end
