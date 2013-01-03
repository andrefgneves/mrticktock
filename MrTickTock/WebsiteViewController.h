//
//  WebsiteViewController.h
//  MrTickTock
//
//  Created by André Neves on 12/26/12.
//  Copyright (c) 2012 André Neves. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebsiteViewController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel * titleLabel;

- (IBAction)showMenu:(id)sender;
- (IBAction)reload:(id)sender;
- (void)login;
- (void)logout;

@end
