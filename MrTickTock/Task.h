//
//  Task.h
//  MrTickTock
//
//  Created by André Neves on 9/27/12.
//  Copyright (c) 2012 Andr√© Neves. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Task : NSObject

@property (nonatomic) NSUInteger id;

@property (strong, nonatomic) NSString * taskName;
@property (nonatomic) BOOL isClosed;
@property (nonatomic) BOOL isVisible;
@property (nonatomic) BOOL isRunning;

@property (nonatomic) NSUInteger customerId;
@property (strong, nonatomic) NSString * customerName;

@property (nonatomic) NSUInteger projectId;
@property (strong, nonatomic) NSString * projectName;

- (id)initWithAttributes:(NSDictionary *)attributes;

@end
