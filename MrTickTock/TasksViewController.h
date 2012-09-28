//
//  ViewController.h
//  MrTickTock
//
//  Created by André Neves on 9/26/12.
//  Copyright (c) 2012 André Neves. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TasksViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *logoutButton;

- (IBAction)logout:(id)sender;

@end
