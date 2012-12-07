//
//  AppDelegate.m
//  MrTickTock
//
//  Created by André Neves on 9/26/12.
//  Copyright (c) 2012 André Neves. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "Task.h"
#import "UIImage+Utils.h"
#import "Constants.h"

@implementation AppDelegate

@synthesize window           = _window;
@synthesize centerController = _viewController;
@synthesize leftController   = _leftController;
@synthesize deckController   = _deckController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setStyle];

    [TestFlight takeOff:@"e9f2e39c8bff04f2885aa45c506b0e3c_MTM3NzgyMjAxMi0wOS0zMCAwODozNzozNS4zNTQ3ODk"];

    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];

    self.leftController = [storyboard instantiateViewControllerWithIdentifier:@"MenuViewController"];

    LoginViewController * centerController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];

    self.centerController = [[UINavigationController alloc] initWithRootViewController:centerController];

    _deckController =  [[IIViewDeckController alloc] initWithCenterViewController:self.centerController leftViewController:self.leftController];
    _deckController.leftLedge = 100;

    self.window.rootViewController = _deckController;
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)setStyle
{
    BOOL _isIOS6 =  NSClassFromString(@"UIRefreshControl") != nil;

    [[UINavigationBar appearance] setBackgroundImage:KNavbarBackgroundImage forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObject:KNavbarBackgroundColor forKey:UITextAttributeTextShadowColor]];

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
