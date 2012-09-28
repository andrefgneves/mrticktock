//
//  LoginViewController.m
//  MrTickTock
//
//  Created by André Neves on 9/28/12.
//  Copyright (c) 2012 Andr√© Neves. All rights reserved.
//

#import "LoginViewController.h"
#import "ACSimpleKeychain.h"

@interface LoginViewController ()
{
    UIBarButtonItem * loginButton;
}
@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textChanged:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];

    loginButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonItemStylePlain
                                                                                  target:self
                                                                                  action:@selector(login)];
    self.navigationItem.rightBarButtonItem = nil;

    [self.emailTextField becomeFirstResponder];
}

- (void)login {
    NSString * email = self.emailTextField.text;
    NSString * password = self.passwordTextField.text;

    if (email.length > 0 && password.length > 0) {
        ACSimpleKeychain * keychain = [ACSimpleKeychain defaultKeychain];
        [keychain storeUsername:self.emailTextField.text password:self.passwordTextField.text identifier:@"account" forService:@"MrTickTock"];
    }

    [self.navigationController popViewControllerAnimated:YES];
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
