//
//  Task.m
//  MrTickTock
//
//  Created by André Neves on 9/27/12.
//  Copyright (c) 2012 Andr√© Neves. All rights reserved.
//

#import "Task.h"

@implementation Task

- (id)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];

    if (!self) {
        return nil;
    }

    self.id = [[attributes valueForKey:@"id"] integerValue];

    self.taskName = [attributes objectForKey:@"task_name"];
    self.isClosed = [[attributes valueForKey:@"closed"] boolValue];

    self.isVisible = [[attributes valueForKey:@"visibility"] isEqualToString:@"visible"];
    self.isRunning = NO;

    self.customerId = [[attributes valueForKey:@"customer_id"] integerValue];
    self.customerName = [attributes objectForKey:@"customer_name"];

    self.projectId = [[attributes valueForKey:@"project_id"] integerValue];
    self.projectName = [attributes objectForKey:@"project_name"];

    return self;
}

@end
