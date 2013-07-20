//
//  JNSTimeline.m
//  Hello
//
//  Created by Shuai on 6/23/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import "JNSTimeline.h"
#import "JNSTimelineEntry.h"
#import "JNSConnection.h"
#import "JNSLoadManager.h"

@interface JNSTimeline() {
    JNSConnection* _connection;
}
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


@implementation JNSTimeline

@synthesize delegate;
@dynamic entries, latestTimestamp;

+(id)timelineWithContext:(NSManagedObjectContext*)context {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"JNSTimeline"
                                              inManagedObjectContext:context];
    
    JNSTimeline* timeline = [[JNSTimeline alloc] initWithEntity:entity
                                 insertIntoManagedObjectContext:context];
    return timeline;
}

-(void) addEntryWithImage:(UIImage*)image {
    JNSTimelineEntry* entry = [JNSTimelineEntry entryWithImage:image
                                                       Context:[self managedObjectContext]];
    [self addEntriesObject:entry];
    [[JNSLoadManager manager] queueEntry:entry];
}

-(void)loadLatest {
    if (_connection) {
        NSLog(@"[JNSTimeline loadLatest] already loading");
        return;
    }
    
    UInt64 timestamp = [self.latestTimestamp longLongValue] + 1;
    NSString* url = [NSString stringWithFormat:@"%@?timestamp=%llu", kTimelineURL, timestamp];
    _connection = [JNSConnection connectionWithMethod:true
                                                  URL:url
                                               Params:nil
                                           Completion:^(JNSConnection* connection, NSHTTPURLResponse *response, NSDictionary *json, NSError *error)
   {
       _connection = nil;
       
       if (!error) {
           NSArray* data = [json objectForKey:@"data"];
           NSMutableArray* indexies = [NSMutableArray new];
           for (NSString* str in data) {
               NSError* error;
               NSDictionary* obj = [NSJSONSerialization JSONObjectWithData:
                                    [str dataUsingEncoding:NSUTF8StringEncoding]
                                                                   options:kNilOptions
                                                                     error:&error];
               JNSTimelineEntry* entry = [JNSTimelineEntry entryWithJSON:obj
                                                                 Context:self.managedObjectContext];
               if ([self.entries count] == 0) {
                   [self addEntriesObject:entry];
                   [indexies addObject:[NSNumber numberWithUnsignedInteger:0]];
               } else {
                   __block NSUInteger index = 0;
                   // Add entry to proper place
                   [self.entries enumerateObjectsWithOptions: NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                                                            
                      JNSTimelineEntry* current = obj;
                      if (current.timestamp != 0 &&
                          [current.timestamp compare:entry.timestamp] == NSOrderedAscending ) {
                          index = idx + 1;// TODO what if idx is the last?
                          *stop = YES;
                      }
                       // TODO
                      if (index == [self.entries count]) {
                          //
                          ;
                      }
                      [self insertObject:entry inEntriesAtIndex:index];
                    }];
                   [indexies addObject: [NSNumber numberWithUnsignedInteger:index]];
               }
               
               if ([entry.timestamp compare:self.latestTimestamp] == NSOrderedDescending) {
                   NSLog(@"Update latest timeline timestamp to %@",entry.timestamp);
                   self.latestTimestamp = entry.timestamp;
               }

           }
           [self.delegate didLoadLatestWithIndexes:indexies Error:error];
       } else {
           [self.delegate didLoadLatestWithIndexes:nil Error:error];
       }
   }];
}

- (void)registerNotificationForEntry:(JNSTimelineEntry*)entry {
    [[NSNotificationCenter defaultCenter] addObserverForName:@"UploadFailed" object:entry queue:nil usingBlock:^(NSNotification *note) {
        JNSTimelineEntry* source = note.object;
        if ([source.timestamp compare:self.latestTimestamp] == NSOrderedDescending) {
            NSLog(@"Update latest timeline timestamp to %@",source.timestamp);
            self.latestTimestamp = source.timestamp;
        }
    }];
}

// overrides
-(void) awakeFromFetch {
    // Check entries that need to upload
    [self.entries enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        JNSTimelineEntry* entry = obj;
        if (entry.needUpload) {
            [[JNSLoadManager manager] queueEntry:entry];
        }
    }];
}

// http://stackoverflow.com/questions/7385439/exception-thrown-in-nsorderedset-generated-accessors
// Core data accessor

- (void)insertObject:(JNSTimelineEntry *)value inEntriesAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"entries"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:@"entries"]];
    [tmpOrderedSet insertObject:value atIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"entries"];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"entries"];
}

@end
