//
//  MenuViewController.h
//  MrTickTock
//
//  Created by André Neves on 10/27/12.
//  Copyright (c) 2012 André Neves. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STTweetLabel.h"

typedef enum {
    MenuActionMyTasks  = 0,
    MenuActionLogout   = 1,
    MenuActionsCount
} MenuActions;

@interface MenuViewController : UITableViewController <UIActionSheetDelegate, STLinkProtocol>

@end
