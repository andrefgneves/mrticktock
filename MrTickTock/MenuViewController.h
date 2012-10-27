//
//  MenuViewController.h
//  MrTickTock
//
//  Created by André Neves on 10/27/12.
//  Copyright (c) 2012 André Neves. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    MenuActionMyTasks  = 0,
    MenuActionAllTasks = 1,
    MenuActionSettings = 2,
    MenuActionLogout   = 3
} MenuActions;

@interface MenuViewController : UITableViewController

@end
