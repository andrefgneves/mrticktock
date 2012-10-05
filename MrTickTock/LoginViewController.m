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

@interface LoginViewController ()
{
    UIBarButtonItem * loginButton;
    ACSimpleKeychain * keychain;
}
@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    keychain = [ACSimpleKeychain defaultKeychain];

    [self checkCredentials];
}

- (void)viewDidAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textChanged:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
}

- (void)checkCredentials {
    NSDictionary * credentials = [keychain credentialsForIdentifier:@"account" service:@"MrTickTock"];

    if (credentials) {
        [self performSegueWithIdentifier:@"showTasks" sender:self];
    } else {
        loginButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(login)];
        self.navigationItem.rightBarButtonItem = nil;

        [self.emailTextField becomeFirstResponder];
    }
}

- (void)login {
    NSString * email = self.emailTextField.text;
    NSString * password = self.passwordTextField.text;

    if (email.length > 0 && password.length > 0) {
        [keychain storeUsername:self.emailTextField.text password:self.passwordTextField.text identifier:@"account" forService:@"MrTickTock"];

        [self performSegueWithIdentifier:@"showTasks" sender:self];
    }
}

- (void)textChanged:(UITextField *)textField {
    NSString * email = self.emailTextField.text;
    NSString * password = self.passwordTextField.text;

    if (email.length > 0 && password.length > 0) {
        self.navigationItem.rightBarButtonItem = loginButton;
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

@end
