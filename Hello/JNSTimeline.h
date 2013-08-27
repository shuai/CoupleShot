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

-(void)didLoadLatestWithIndexes:(NSArray*)indexes Error:(NSError*)error;

@end


@interface JNSTimeline : NSManagedObject

@property (weak) id<JNSTimelineDelegate> delegate;
@property (weak, readonly) JNSTimelineEntry* activeEntry;

// Core Data
@property (nonatomic, retain) NSOrderedSet *entries;
@property (nonatomic, retain) NSNumber * latestTimestamp;
@property (nonatomic, retain) NSMutableArray* uploadIDs; // ids of entries not yet uploaded

+(id)timelineWithContext:(NSManagedObjectContext*)context;

- (void)addEntryWithImage:(UIImage*)image;
- (void)loadLatest;
- (JNSTimelineEntry*)entryWithTimestamp:(NSNumber*)timestamp;

@end
