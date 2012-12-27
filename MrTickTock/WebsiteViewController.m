//
//  WebsiteViewController.m
//  MrTickTock
//
//  Created by André Neves on 12/26/12.
//  Copyright (c) 2012 André Neves. All rights reserved.
//

#import "WebsiteViewController.h"
#import "AFMrTickTockAPIClient.h"
#import "DDURLParser.h"

#define MRTICKTOCK_LOGIN_URL "https://mrticktock.com/app/auth/log_in"
#define MRTICKTOCK_LOGOUT_URL "https://mrticktock.com/app/auth/log_out"

@interface WebsiteViewController ()
{
    BOOL isLoggingIn;
    BOOL isLoggingOut;
    NSDictionary * authParams;
}

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation WebsiteViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"MrTickTock";

    self.webView.scalesPageToFit = YES;
    self.webView.delegate = self;

    isLoggingIn = NO;
    isLoggingOut = NO;

    [self login];
}

- (void)login
{
    NSDictionary * credentials = [[AFMrTickTockAPIClient sharedClient] authParams];

    NSURL * url = [NSURL URLWithString:@MRTICKTOCK_LOGIN_URL];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    NSString *body = [NSString stringWithFormat:@"user_email=%@&user_password=%@", [credentials objectForKey:@"email"], [credentials objectForKey:@"password"]];

    request.HTTPMethod = @"POST";
    request.HTTPBody = [body dataUsingEncoding: NSUTF8StringEncoding];

    [self.webView loadRequest:request];
}

- (void)logout
{
    NSURL * url = [NSURL URLWithString:@MRTICKTOCK_LOGOUT_URL];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];

    [self.webView loadRequest:request];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (([request.URL.absoluteString isEqualToString:@MRTICKTOCK_LOGIN_URL]) && ([request.HTTPMethod isEqualToString:@"POST"])) {
        isLoggingIn = YES;
        isLoggingOut = NO;

        NSString * dataString = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
        DDURLParser * urlParser = [[DDURLParser alloc] initWithURLString:[@"?" stringByAppendingString:dataString]];

        LOG_EXPR(dataString);

        LOG_EXPR([urlParser valueForVariable:@"user_email"]);
    } else if (request.URL.absoluteString == @MRTICKTOCK_LOGOUT_URL) {
        isLoggingIn = NO;
        isLoggingOut = YES;
    }

    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    isLoggingOut = (webView.request.URL.absoluteString == @MRTICKTOCK_LOGOUT_URL);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (isLoggingOut) {
        
    }
}

- (void)viewDidUnload {
    [self setWebView:nil];
    [super viewDidUnload];
}

@end
