//
//  JNSLoadManager.m
//  Hello
//
//  Created by Shuai on 7/19/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import "JNSLoadManager.h"

JNSLoadManager* _manager;

const int MAX_SESSION = 2;

@interface JNSLoadManager() {
    NSMutableOrderedSet* _uploadQueue;
    NSMutableOrderedSet* _downloadQueue;
    int _sessions;
}
@end


@implementation JNSLoadManager


+ (JNSLoadManager*)manager {
    if (!_manager) {
        _manager = [JNSLoadManager new];
    }
    return _manager;
}

- (JNSLoadManager*)init {
    self = [super init];
    if (self) {
        _uploadQueue = [NSMutableOrderedSet new];
        _downloadQueue = [NSMutableOrderedSet new];
    }
    return self;
}

- (void)queueEntry:(JNSTimelineEntry*)entry {
    if([_uploadQueue indexOfObject:entry] != NSNotFound ||
       [_downloadQueue indexOfObject:entry] != NSNotFound) {
        return;
    }
        
    if (entry.needUpload) {
        [self uploadEntry:entry];
    }
    
    if (entry.needDownload) {
        [_downloadQueue addObject:entry];
        [self schedule];
    }
}

- (void)schedule {
    // TODO reentrance
    
    for (JNSTimelineEntry* entry in _uploadQueue) {
        [self uploadEntry:entry];
    }
    [_uploadQueue removeAllObjects];
 
    int download = MAX_SESSION - _sessions;
    while (download-- > 0) {
        if ([_downloadQueue count]) {
            JNSTimelineEntry* entry = [_downloadQueue firstObject];
            [_downloadQueue removeObject:entry];
            [self downloadEntry:entry];
        }
    }
}

- (void)uploadEntry:(JNSTimelineEntry*)entry {
    _sessions ++;
    [entry uploadWithCompletion:^(NSString *error) {
        _sessions --;
        if (error) {
            //[_uploadQueue insertObject:entry atIndex:[_uploadQueue count]];
        }
        [self schedule];
    }];
}

- (void)downloadEntry:(JNSTimelineEntry*)entry {
    _sessions ++;
    [entry downloadWithCompletion:^(NSString *error) {
        _sessions --;
//        if (error) {
//            [_downloadQueue insertObject:entry atIndex:[_downloadQueue count]];
//        }
        [self schedule];
    }];
}

@end
