//
//  MenuNavigationController.m
//  MrTickTock
//
//  Created by André Neves on 12/9/12.
//  Copyright (c) 2012 André Neves. All rights reserved.
//

#import "MenuNavigationController.h"

@implementation MenuNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 200, 44)];
    title.text = @"MrTickTock";
    title.backgroundColor = UIColor.clearColor;
    title.textColor = UIColor.whiteColor;
    title.font = [UIFont boldSystemFontOfSize:20];

    [self.navigationBar addSubview:title];
}

@end
