//
//  JNSConfig.m
//  Hello
//
//  Created by Shuai on 6/22/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import "JNSConfig.h"

JNSConfig* _config;

@implementation JNSConfig

@dynamic cachedUser;


+(void)setConfig:(JNSConfig*)config {
    NSAssert(!_config, @"");
    _config = config;
}

+(JNSConfig*)config {
    return _config;
}

@end
