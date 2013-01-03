//
//  WebsiteViewController.m
//  MrTickTock
//
//  Created by André Neves on 12/26/12.
//  Copyright (c) 2012 André Neves. All rights reserved.
//

#import "WebsiteViewController.h"
#import "AFMrTickTockAPIClient.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "SVProgressHUD.h"

#define MRTICKTOCK_LOGIN_URL "https://mrticktock.com/app/auth/log_in"
#define MRTICKTOCK_LOGOUT_URL "https://mrticktock.com/app/auth/log_out"

@interface WebsiteViewController ()
{
    NSString * loggedUser;
    BOOL shouldLogin;
}

@property (weak, nonatomic) IBOutlet UIWebView * webView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem * reloadButton;

@end

@implementation WebsiteViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupNavBar];

    self.webView.scalesPageToFit = YES;
    self.webView.delegate = self;

    NSDictionary * buttonTextAttributes = @{
        UITextAttributeFont: [UIFont fontWithName:@"mrticktock" size:20],
        UITextAttributeTextShadowColor: KNavbarBackgroundColor
    };

    [self.reloadButton setTitleTextAttributes:buttonTextAttributes forState:UIControlStateNormal];

    shouldLogin = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    NSDictionary * credentials = [[AFMrTickTockAPIClient sharedClient] authParams];

    if (![[credentials objectForKey:@"email"] isEqualToString:loggedUser]) {
        if (loggedUser) {
            shouldLogin = YES;
            [self logout];

            return;
        }

        [self login];
    }
}

- (void)setupNavBar
{
    self.titleLabel.text = @"Website";
    self.titleLabel.textColor = UIColor.whiteColor;
    self.titleLabel.font = [UIFont fontWithName:@"ProximaNova-Bold" size:20];
    
    [self.navigationItem.leftBarButtonItem setTitlePositionAdjustment:UIOffsetMake(-3, 3) forBarMetrics:UIBarMetricsDefault];
    [self.navigationItem.rightBarButtonItem setTitlePositionAdjustment:UIOffsetMake(5, 3) forBarMetrics:UIBarMetricsDefault];
}

- (void)showMenu:(id)sender
{
    AppDelegate * app = [[UIApplication sharedApplication] delegate];
    
    [app.deckController toggleLeftViewAnimated:YES];
}

- (void)reload:(id)sender
{
    [self.webView reload];
}

- (void)login
{
    NSDictionary * credentials = [[AFMrTickTockAPIClient sharedClient] authParams];

    NSURL * url = [NSURL URLWithString:@MRTICKTOCK_LOGIN_URL];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    NSString *body = [NSString stringWithFormat:@"user_email=%@&user_password=%@", [credentials objectForKey:@"email"], [credentials objectForKey:@"password"]];

    request.HTTPMethod = @"POST";
    request.HTTPBody = [body dataUsingEncoding: NSUTF8StringEncoding];

    loggedUser = [credentials objectForKey:@"email"];

    [self.webView loadRequest:request];
}

- (void)logout
{
    NSURL * url = [NSURL URLWithString:@MRTICKTOCK_LOGOUT_URL];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];

    [self.webView loadRequest:request];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [SVProgressHUD show];

    self.navigationItem.rightBarButtonItem = nil;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (shouldLogin) {
        shouldLogin = NO;

        [self login];

        return;
    }

    [SVProgressHUD dismiss];

    self.navigationItem.rightBarButtonItem = self.reloadButton;
}

- (void)viewDidUnload {
    [self setWebView:nil];
    [super viewDidUnload];
}

@end
