//
//  Task.m
//  MrTickTock
//
//  Created by André Neves on 10/10/12.
//  Copyright (c) 2012 André Neves. All rights reserved.
//

#import "Task.h"

@implementation Task

- (id)initWithAttributes:(NSDictionary *)attributes
{
    self = [super init];
    
    if (!self) {
        return nil;
    }

    self.id = [[attributes valueForKey:@"id"] integerValue];

    self.name = [attributes objectForKey:@"task_name"];
    self.isClosed = [[attributes valueForKey:@"closed"] boolValue];

    self.isVisible = [[attributes valueForKey:@"visibility"] isEqualToString:@"visible"];
    self.isRunning = NO;

    self.customerId = [[attributes valueForKey:@"customer_id"] integerValue];
    self.customerName = [attributes objectForKey:@"customer_name"];

    self.projectId = [[attributes valueForKey:@"project_id"] integerValue];
    self.projectName = [attributes objectForKey:@"project_name"];

    self.time = @"";
    self.totalTime = @"";

    return self;
}

- (NSTimeInterval)timeInterval
{
    NSArray * parts = [self.totalTime componentsSeparatedByString:@":"];

    NSUInteger hours = [[parts objectAtIndex:0] integerValue] * 60 * 60;
    NSUInteger minutes = [[parts objectAtIndex:1] integerValue] * 60;

    return hours + minutes;
}

@end
