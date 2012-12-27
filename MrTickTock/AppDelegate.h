//
//  AppDelegate.h
//  MrTickTock
//
//  Created by André Neves on 9/26/12.
//  Copyright (c) 2012 André Neves. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IIViewDeckController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow * window;
@property (strong, nonatomic) IIViewDeckController * deckController;

@property (strong, nonatomic) UIViewController * menuController;
@property (strong, nonatomic) UINavigationController * tasksController;
@property (strong, nonatomic) UINavigationController * websiteController;

- (void)showTasks;
- (void)showWebsite;

@end
