//
//  NSObject+PerformBlock.h
//  MrTickTock
//
//  Created by André Neves on 12/26/12.
//  Copyright (c) 2012 André Neves. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (PerformBlock)

- (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay;

@end
