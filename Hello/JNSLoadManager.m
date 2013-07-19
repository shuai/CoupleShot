//
//  JNSLoadManager.m
//  Hello
//
//  Created by Shuai on 7/19/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import "JNSLoadManager.h"

JNSLoadManager* _manager;

const int MAX_DOWNLOAD = 2;
const int MAX_UPLOAD = 2;

@interface JNSLoadManager() {
    int _downloading;
    int _uploading;
}
@end


@implementation JNSLoadManager


+ (JNSLoadManager*)manager {
    if (!_manager) {
        _manager = [JNSLoadManager new];
    }
    return _manager;
}

- (void)queueEntry:(JNSTimelineEntry*)entry {
    
}

@end
