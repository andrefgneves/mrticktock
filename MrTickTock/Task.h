//
//  Task.h
//  MrTickTock
//
//  Created by André Neves on 10/10/12.
//  Copyright (c) 2012 André Neves. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Task : NSObject

@property (nonatomic) NSUInteger id;

@property (strong, nonatomic) NSString * name;
@property (nonatomic) BOOL isClosed;
@property (nonatomic) BOOL isVisible;
@property (nonatomic) BOOL isRunning;

@property (nonatomic) NSUInteger customerId;
@property (strong, nonatomic) NSString * customerName;

@property (nonatomic) NSUInteger projectId;
@property (strong, nonatomic) NSString * projectName;

@property (strong, nonatomic) NSString * time;
@property (strong, nonatomic) NSString * totalTime;

@property (nonatomic) NSTimeInterval timeInterval;

- (id)initWithAttributes:(NSDictionary *)attributes;

@end
