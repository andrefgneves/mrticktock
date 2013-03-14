//
//  KiwiUnitTest.m
//  KiwiUnitTest
//
//  Created by André Neves on 1/27/13.
//  Copyright (c) 2013 André Neves. All rights reserved.
//


#import "Kiwi.h"
#import "TasksManager.h"
#import "VTPG_LogExpr.h"
#import <AFNetworking/AFNetworking.h>

SPEC_BEGIN(MrTickTockTests)

describe(@"MrTickTock", ^{
    NSDictionary * testCredentials = @{
        @"email":    @"foo@bar.com",
        @"password": @"foobar"
    };

    context(@"Authentication", ^{
        it(@"should fail to authenticate with bogus credentials", ^{
            __block NSArray * errors;

            NSDictionary * bogusCredentials = @{
                @"email":    @"boguscredentials@fortesting.com",
                @"password": @"boguscredentials_fortesting"
            };

            [[AFMrTickTockAPIClient sharedClient] postPath:@"is_timer_active" parameters:bogusCredentials success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                errors = [JSON objectForKey:@"errors"];
            } failure:nil];

            [[expectFutureValue(@(errors.count)) shouldEventuallyBeforeTimingOutAfter(5.0)] beGreaterThan:@0];
        });

        it(@"should authenticate with test credentials", ^{
            __block NSArray * errors = @[@""];

            [[AFMrTickTockAPIClient sharedClient] postPath:@"is_timer_active" parameters:testCredentials success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                errors = [JSON objectForKey:@"errors"];
            } failure:nil];

            [[expectFutureValue(@(errors.count)) shouldEventuallyBeforeTimingOutAfter(5.0)] equal:@0];
        });
    });

    context(@"Fetching tasks", ^{
        __block NSDictionary * response;

        beforeEach(^{
            [[AFMrTickTockAPIClient sharedClient] postPath:@"is_timer_active" parameters:testCredentials success:^(AFHTTPRequestOperation *operation, NSDictionary * JSON) {
                response = [[JSON objectForKey:@"content"] objectAtIndex:0];
            } failure:nil];
        });

        it(@"should receive a list of tasks", ^{
            [[expectFutureValue(response) shouldEventually] beNonNil];
        });

    });
});

SPEC_END