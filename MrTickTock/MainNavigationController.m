//
//  MenuNavigationController.m
//  MrTickTock
//
//  Created by André Neves on 12/9/12.
//  Copyright (c) 2012 André Neves. All rights reserved.
//

#import "MainNavigationController.h"
#import <GetGravatar/GetGravatar.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "AFMrTickTockAPIClient.h"

@interface MainNavigationController()
{
    UIImageView * gravatarView;
}

@end

@implementation MainNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake(42, 0, 200, 44)];
    title.text = @"MrTickTock";
    title.backgroundColor = UIColor.clearColor;
    title.textColor = UIColor.whiteColor;
    title.font = [UIFont fontWithName:@"ProximaNova-Bold" size:20];

    [self.navigationBar addSubview:title];

    gravatarView = [[UIImageView alloc] initWithFrame:CGRectMake(7, 9, 26, 26)];

    [self.navigationBar addSubview:gravatarView];

    [self showAvatar];
}

- (void)showAvatar
{
    NSString * email;
    NSDictionary * credentials = [[AFMrTickTockAPIClient sharedClient] authParams];

    if (credentials) {
        email = [credentials objectForKey:@"email"];
    }

    NSURL * gravatarURL = [GetGravatar gravatarURL:email:@"52":@"blank"];

    [gravatarView setImageWithURL:gravatarURL];
}

@end
