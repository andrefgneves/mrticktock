//
//  Task.h
//  MrTickTock
//
//  Created by André Neves on 10/10/12.
//  Copyright (c) 2012 André Neves. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Task : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * isClosed;
@property (nonatomic, retain) NSNumber * isVisible;
@property (nonatomic, retain) NSNumber * isRunning;
@property (nonatomic, retain) NSNumber * customerId;
@property (nonatomic, retain) NSString * customerName;
@property (nonatomic, retain) NSNumber * projectId;
@property (nonatomic, retain) NSDate * time;
@property (nonatomic, retain) NSDate * totalTime;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * projectName;

@end
