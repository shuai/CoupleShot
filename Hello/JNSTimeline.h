//
//  JNSTimeline.h
//  Hello
//
//  Created by Shuai on 6/15/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JNSConnection.h"
#import "JNSTimelineEntry.h"

@protocol JNSTimelineDelegate <NSObject>

-(void) loadFromCacheComplte;
-(void) pullComplte:(int)count WithError:(NSString*)error;
-(void) entryWithIndex:(int)index LoadedWithError:(NSString*)err;
-(void) entryWithIndex:(int)index UploadProgress:(int)progress WithError:(NSString*)err;
@end

@interface JNSTimeline : NSObject<JNSConnectionDelegate, JNSTimelineEntryDelegate>

@property NSMutableArray* array;
@property JNSConnection* connection;
@property id<JNSTimelineDelegate> delegate;

-(int)count;
-(void)loadLatest;
-(void)addEntry:(JNSTimelineEntry*)entry;

@end
