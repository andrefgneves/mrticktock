//
//  AFMrTickTockAPICliente.h
//  MrTickTock
//
//  Created by André Neves on 9/26/12.
//  Copyright (c) 2012 Andr√© Neves. All rights reserved.
//

#import "AFHTTPClient.h"

@interface AFMrTickTockAPIClient : AFHTTPClient

+ (AFMrTickTockAPIClient *)sharedClient;

- (NSDictionary *)authParams;

@end
