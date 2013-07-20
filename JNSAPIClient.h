//
//  JNSAPIClient.h
//  Hello
//
//  Created by Shuai on 7/20/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import "AFHTTPClient.h"

@interface JNSAPIClient : AFHTTPClient

+ (JNSAPIClient*)sharedClient;

@end
