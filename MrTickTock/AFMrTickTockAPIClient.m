//
//  AFMrTickTockAPICliente.m
//  MrTickTock
//
//  Created by André Neves on 9/26/12.
//  Copyright (c) 2012 Andr√© Neves. All rights reserved.
//

#import "AFMrTickTockAPIClient.h"
#import "AFJSONRequestOperation.h"

static NSString * const kAFMrTickTockAPIBaseURLString = @"https://mrticktock.com/app/api/";

@implementation AFMrTickTockAPIClient

+ (AFMrTickTockAPIClient *)sharedClient {
    static AFMrTickTockAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        _sharedClient = [[AFMrTickTockAPIClient alloc] initWithBaseURL:[NSURL URLWithString:kAFMrTickTockAPIBaseURLString]];
    });

    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];

    if (!self) {
        return nil;
    }

    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
	[self setDefaultHeader:@"Accept" value:@"application/json"];

    return self;
}

- (NSDictionary *)authParams {
    return [[NSDictionary alloc] initWithObjectsAndKeys:@"afn@seegno.com", @"email", @"65QLJd3a&uvdH", @"password", nil];
}

@end