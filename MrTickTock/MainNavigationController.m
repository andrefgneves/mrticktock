//
//  MenuNavigationController.m
//  MrTickTock
//
//  Created by André Neves on 12/9/12.
//  Copyright (c) 2012 André Neves. All rights reserved.
//

#import "MainNavigationController.h"

@implementation MainNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 200, 44)];
    title.text = @"MrTickTock";
    title.backgroundColor = UIColor.clearColor;
    title.textColor = UIColor.whiteColor;
    title.font = [UIFont fontWithName:@"ProximaNova-Bold" size:20];

    [self.navigationBar addSubview:title];
}

@end
