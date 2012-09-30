//
//  AppDelegate.m
//  MrTickTock
//
//  Created by André Neves on 9/26/12.
//  Copyright (c) 2012 André Neves. All rights reserved.
//

#import "AppDelegate.h"
#import "KSReachability.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [TestFlight takeOff:@"e9f2e39c8bff04f2885aa45c506b0e3c_MTM3NzgyMjAxMi0wOS0zMCAwODozNzozNS4zNTQ3ODk"];

    [KSReachableOperation operationWithHost:@"google.com"
                                  allowWWAN:NO
                                      block:^ {
                                          [self listNetworks];
                                      }];

    return YES;
}

- (void)listNetworks {
    NSArray * interfaces = (__bridge NSArray *)CNCopySupportedInterfaces();
    if (!interfaces.count) return;

    CFStringRef interface = (__bridge CFStringRef)[interfaces objectAtIndex:0];
    CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(interface);
    NSDictionary * dict = (__bridge NSDictionary *)myDict;

//    BSSID = "94:44:52:b3:d9:6d";
//    SSID = seven;
//    SSIDDATA = <73657665 6e>;

    LOG_EXPR(dict);
}

@end
