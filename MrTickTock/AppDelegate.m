//
//  AppDelegate.m
//  MrTickTock
//
//  Created by André Neves on 9/26/12.
//  Copyright (c) 2012 André Neves. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setStyle];
    
    [TestFlight takeOff:@"e9f2e39c8bff04f2885aa45c506b0e3c_MTM3NzgyMjAxMi0wOS0zMCAwODozNzozNS4zNTQ3ODk"];

    return YES;
}

- (void)setStyle {
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"bar.png"] forBarMetrics:UIBarMetricsDefault];

    UIImage * buttonImage = [[UIImage imageNamed:@"nav-button.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    UIImage * buttonImageSelected = [[UIImage imageNamed:@"nav-button-selected.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];

    [[UIBarButtonItem appearance] setBackgroundImage:buttonImage
                                  forState:UIControlStateNormal
                                          barMetrics:UIBarMetricsDefault];

    [[UIBarButtonItem appearance] setBackgroundImage:buttonImageSelected
                                            forState:UIControlStateSelected
                                          barMetrics:UIBarMetricsDefault];
}

@end
