//
//  JNSTimeline.h
//  Hello
//
//  Created by Shuai on 6/23/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "JNSTimelineEntry.h"

@protocol JNSTimelineDelegate
@optional
-(void)didLoadLatestWithIndexes:(NSArray*)indexes Error:(NSError*)error;
-(void)entry:(JNSTimelineEntry*)entry UploadProgressUpdatedWithError:(NSString*)error;
-(void)entry:(JNSTimelineEntry*)entry DownloadProgressUpdatedWithError:(NSString*)error;
@end


@interface JNSTimeline : NSManagedObject

@property (weak) id<JNSTimelineDelegate> delegate;

// Core Data
@property (nonatomic, retain) NSOrderedSet *entries;
@property (nonatomic, retain) NSNumber * latestTimestamp;

+(id)timelineWithContext:(NSManagedObjectContext*)context;

- (void)addEntryWithImage:(UIImage*)image;
- (void)loadLatest;

@end
