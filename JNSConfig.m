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
@dynamic nextImageID;

+ (NSNumber*)uniqueImageID {
    NSNumber* number = [NSNumber numberWithInt:[JNSConfig config].nextImageID.intValue + 1];
    [JNSConfig config].nextImageID = number;
    return number;
}

+(void)setConfig:(JNSConfig*)config {
    NSAssert(!_config, @"");
    _config = config;
}

+(JNSConfig*)config {
    return _config;
}

@end
