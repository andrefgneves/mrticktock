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
    deckController.rightLedge = 200;
    self.window.rootViewController = deckController;

    [self.window makeKeyAndVisible];

    return YES;
}

- (void)setStyle
{
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
