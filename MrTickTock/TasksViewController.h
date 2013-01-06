//
//  ViewController.h
//  MrTickTock
//
//  Created by André Neves on 9/26/12.
//  Copyright (c) 2012 André Neves. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TasksManager.h"
#import "TaskActionsCell.h"

@interface TasksViewController : UITableViewController <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIActionSheetDelegate, TaskManagerDelegate, TaskActionsCellDelegate>

@property (strong, nonatomic) IBOutlet UITableView * table;
@property (strong, nonatomic) IBOutlet UIBarButtonItem * showMenuButton;
@property (strong, nonatomic) IBOutlet UILabel * titleLabel;


- (IBAction)showMenu:(id)sender;
- (IBAction)toggleButtonTouched:(UIButton *)button;

@end
