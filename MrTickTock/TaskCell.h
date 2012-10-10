//
//  TaskCell.h
//  MrTickTock
//
//  Created by André Neves on 9/27/12.
//  Copyright (c) 2012 Andr√© Neves. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TaskCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel * projectName;
@property (strong, nonatomic) IBOutlet UILabel * taskName;

@end
