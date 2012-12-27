//
//  AppDelegate.m
//  MrTickTock
//
//  Created by André Neves on 9/26/12.
//  Copyright (c) 2012 André Neves. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "UIImage+Utils.h"
#import "Constants.h"
#import "NSObject+PerformBlock.h"
#import <TestFlightSDK/TestFlight.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setStyle];

    [TestFlight takeOff:@"1aba3921-3680-4b92-b2f8-fd57fad285a8"];

    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];

    self.menuController = [storyboard instantiateViewControllerWithIdentifier:@"MenuNavigationController"];
    self.tasksController = [[UINavigationController alloc] initWithRootViewController:[storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"]];
    self.websiteController = [storyboard instantiateViewControllerWithIdentifier:@"WebsiteNavigationController"];

    self.deckController =  [[IIViewDeckController alloc] initWithCenterViewController:self.tasksController
                                                                   leftViewController:self.menuController];
    self.deckController.leftSize = 100;
    self.deckController.panningMode = IIViewDeckFullViewPanning;
    self.deckController.centerhiddenInteractivity = IIViewDeckCenterHiddenNotUserInteractiveWithTapToCloseBouncing;

    self.window.rootViewController = self.deckController;
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)showTasks
{
    if (self.deckController.centerController == self.tasksController) {
        [self.deckController closeLeftView];

        return;
    }
    
    self.deckController.leftSize = 0;
    
    [self performBlock:^{
        self.deckController.centerController = self.tasksController;
        [self.deckController closeLeftView];

        self.deckController.leftSize = 100;
    } afterDelay:0.3];
}

- (void)showWebsite
{
    if (self.deckController.centerController == self.websiteController) {
        [self.deckController closeLeftView];
        
        return;
    }

    self.deckController.leftSize = 0;

    [self performBlock:^{
        self.deckController.centerController = self.websiteController;
        [self.deckController closeLeftView];

        self.deckController.leftSize = 100;
    } afterDelay:0.3];
}

- (void)setStyle
{
    BOOL _isIOS6 =  NSClassFromString(@"UIRefreshControl") != nil;

    [[UINavigationBar appearance] setBackgroundImage:KNavbarBackgroundImage forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          KNavbarBackgroundColor ,UITextAttributeTextShadowColor,
                                                          [UIFont fontWithName:@"ProximaNova-Bold" size:20], UITextAttributeFont,
                                                          nil]];

    if (_isIOS6) {
        // Remove navigation bars shadow
        [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    }

    // Text attributes for UIBarButtons
    NSDictionary * navBarButtonTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                 [UIFont fontWithName:@"mrticktock" size:35], UITextAttributeFont,
                                                 [UIColor whiteColor], UITextAttributeTextColor,
                                                 KNavbarBackgroundColor, UITextAttributeTextShadowColor,
                                                 nil];

    [[UIBarButtonItem appearance] setTitleTextAttributes:navBarButtonTextAttributes forState:UIControlStateNormal];

    // Use the same image as the navigations bar to have a flat look
    [[UIBarButtonItem appearance] setBackgroundImage:KNavbarBackgroundImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackgroundImage:KNavbarBackgroundImage forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];

    // The UISearchBar cancel button is proxied through UIBarButtonItem so we need to reset it's look
    UIImage * UISearchBarCancelButtonImage = [UIImage imageWithColor:KNavbarBackgroundColor andSize:CGSizeMake(48, 30)];
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setBackgroundImage:UISearchBarCancelButtonImage
                                                                                    forState:UIControlStateNormal
                                                                                  barMetrics:UIBarMetricsDefault];

    UIImage * UISearchBarCancelButtonHighlightedImage = [UIImage imageWithColor:[UIColor blackColor] andSize:CGSizeMake(48, 30)];
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setBackgroundImage:UISearchBarCancelButtonHighlightedImage
                                                                                    forState:UIControlStateHighlighted
                                                                                  barMetrics:UIBarMetricsDefault];

    // Text attributes for UISearchBar cancel button
    NSDictionary * UISearchBarCancelButtonTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                            [UIFont fontWithName:@"ProximaNova-Bold" size:18], UITextAttributeFont,
                                                            [UIColor whiteColor], UITextAttributeTextColor,
                                                            KNavbarBackgroundColor, UITextAttributeTextShadowColor,
                                                            nil];

    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:UISearchBarCancelButtonTextAttributes forState:UIControlStateNormal];

    // Highlighted
    NSMutableDictionary * UISearchBarCancelButtonHighlightedTextAttributes = [NSMutableDictionary dictionaryWithDictionary:UISearchBarCancelButtonTextAttributes];
    [UISearchBarCancelButtonHighlightedTextAttributes setObject:[UIColor blackColor] forKey:UITextAttributeTextShadowColor];

    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:UISearchBarCancelButtonHighlightedTextAttributes
                                                                                        forState:UIControlStateHighlighted];

    // UISearchBar textfield appearance
    [[UISearchBar appearance] setSearchFieldBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor] andSize:CGSizeMake(320, 44)] forState:UIControlStateNormal];
    
    // UIToolbar appearance
    [[UIToolbar appearance] setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:0.278 green:0.565 blue:0.702 alpha:1.000] andSize:CGSizeMake(1, 1)] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];

    if (_isIOS6) {
        [[UIToolbar appearance] setShadowImage:[[UIImage alloc] init] forToolbarPosition:UIToolbarPositionAny];
    }
}

@end
