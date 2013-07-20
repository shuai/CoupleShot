//
//  JNSLoadManager.h
//  Hello
//
//  Created by Shuai on 7/19/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JNSTimelineEntry.h"

// Queue and retry policy
@interface JNSLoadManager : NSObject

+ (JNSLoadManager*)manager;

- (void)queueEntry:(JNSTimelineEntry*)entry;

@end
