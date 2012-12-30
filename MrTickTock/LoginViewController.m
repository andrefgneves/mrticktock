//
//  LoginViewController.m
//  MrTickTock
//
//  Created by André Neves on 9/28/12.
//  Copyright (c) 2012 Andr√© Neves. All rights reserved.
//

#import "LoginViewController.h"
#import "ACSimpleKeychain.h"
#import "TasksViewController.h"
#import "IIViewDeckController.h"

@interface LoginViewController ()
{
    ACSimpleKeychain * keychain;
}
@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.emailTextField.delegate = self;
    self.passwordTextField.delegate = self;

    keychain = [ACSimpleKeychain defaultKeychain];

    [self checkCredentials];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[self.navigationController.navigationBar viewWithTag:1000] removeFromSuperview];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.emailTextField becomeFirstResponder];

    self.viewDeckController.panningMode = IIViewDeckNoPanning;
}

- (void)checkCredentials
{
    NSDictionary * credentials = [keychain credentialsForIdentifier:@"account" service:@"MrTickTock"];

    if (credentials) {
        [self performSegueWithIdentifier:@"showTasks" sender:self];
    } else {
        self.navigationItem.rightBarButtonItem = nil;

        [self.emailTextField becomeFirstResponder];
    }
}

- (void)login
{
    NSString * email = self.emailTextField.text;
    NSString * password = self.passwordTextField.text;

    if (email.length > 0 && password.length > 0) {
        [keychain storeUsername:self.emailTextField.text password:self.passwordTextField.text identifier:@"account" forService:@"MrTickTock"];

        [self performSegueWithIdentifier:@"showTasks" sender:self];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.emailTextField) {
        [self.passwordTextField becomeFirstResponder];
    } else {
        [self login];
    }

    return YES;
}

@end
