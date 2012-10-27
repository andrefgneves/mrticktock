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
@property (retain, nonatomic) IIViewDeckController * deckController;
@property (retain, nonatomic) UINavigationController * centerController;
@property (retain, nonatomic) UIViewController * leftController;

@end
