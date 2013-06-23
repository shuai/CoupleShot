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

@interface JNSTimeline : NSManagedObject

// TODO sort by timestamp
@property (nonatomic, retain) NSOrderedSet *entries;

+(id)timelineWithContext:(NSManagedObjectContext*)context;

-(void) addEntryWithImage:(UIImage*)image;
-(void)loadLatestCompletion:(void(^)(unsigned add, NSError* error))completion;

@end

@interface JNSTimeline (CoreDataGeneratedAccessors)

- (void)insertObject:(JNSTimelineEntry *)value inEntriesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromEntriesAtIndex:(NSUInteger)idx;
- (void)insertEntries:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeEntriesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInEntriesAtIndex:(NSUInteger)idx withObject:(JNSTimelineEntry *)value;
- (void)replaceEntriesAtIndexes:(NSIndexSet *)indexes withEntries:(NSArray *)values;
- (void)addEntriesObject:(JNSTimelineEntry *)value;
- (void)removeEntriesObject:(JNSTimelineEntry *)value;
- (void)addEntries:(NSOrderedSet *)values;
- (void)removeEntries:(NSOrderedSet *)values;
@end
