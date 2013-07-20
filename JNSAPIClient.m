//
//  JNSAPIClient.m
//  Hello
//
//  Created by Shuai on 7/20/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import "JNSAPIClient.h"
#import "AFJSONRequestOperation.h"
#import "AFImageRequestOperation.h"
#import "JNSConnection.h"

@implementation JNSAPIClient

+ (JNSAPIClient*)sharedClient {
    static JNSAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[JNSAPIClient alloc] initWithBaseURL:[NSURL URLWithString:kHost]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self registerHTTPOperationClass:[AFImageRequestOperation class]];

    return self;
}


@end
