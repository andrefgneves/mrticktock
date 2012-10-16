//
//  AppDelegate.m
//  MrTickTock
//
//  Created by André Neves on 9/26/12.
//  Copyright (c) 2012 André Neves. All rights reserved.
//

#import "AppDelegate.h"
#import "IIViewDeckController.h"
#import "LoginViewController.h"
#import "Task.h"
#import "UIImage+Utils.h"

@implementation AppDelegate

@synthesize window           = _window;
@synthesize centerController = _viewController;
@synthesize leftController   = _leftController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setStyle];

    [TestFlight takeOff:@"e9f2e39c8bff04f2885aa45c506b0e3c_MTM3NzgyMjAxMi0wOS0zMCAwODozNzozNS4zNTQ3ODk"];

    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];

    self.leftController = [storyboard instantiateViewControllerWithIdentifier:@"MenuViewController"];

    LoginViewController * centerController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];

    self.centerController = [[UINavigationController alloc] initWithRootViewController:centerController];

    IIViewDeckController * deckController =  [[IIViewDeckController alloc] initWithCenterViewController:self.centerController
                                                                                    leftViewController:self.leftController];
    deckController.leftLedge = 100;
    self.window.rootViewController = deckController;

    [self.window makeKeyAndVisible];

    return YES;
}

- (void)setStyle
{
    UIColor * barColor = [UIColor colorWithRed:0.475 green:0.725 blue:0.929 alpha:1.000];
    UIImage * nav = [UIImage imageWithColor:barColor andSize:CGSizeMake(1, 1)];

    [[UINavigationBar appearance] setBackgroundImage:nav forBarMetrics:UIBarMetricsDefault];

    NSDictionary * textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIFont fontWithName:@"mrticktock" size:25],
                                     UITextAttributeFont,
                                     [UIColor whiteColor],
                                     UITextAttributeTextColor,
                                     barColor,
                                     UITextAttributeTextShadowColor,
                                     nil];

    [[UIBarButtonItem appearance] setTitleTextAttributes:textAttributes forState:UIBarMetricsDefault];

    [[UIBarButtonItem appearance] setBackgroundImage:nav
                                  forState:UIControlStateNormal
                                          barMetrics:UIBarMetricsDefault];

    [[UIBarButtonItem appearance] setBackgroundImage:nav
                                            forState:UIControlStateSelected
                                          barMetrics:UIBarMetricsDefault];

    [[UISearchBar appearance] setSearchFieldBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor] andSize:CGSizeMake(200, 44)] forState:UIControlStateNormal];
}

@end
