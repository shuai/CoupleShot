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
#import "AFJSONRequestOperation.h"
#import "JNSAPIClient.h"

@interface JNSTimeline() {
    BOOL isLoading;
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
@dynamic entries, uploadIDs, latestTimestamp;

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
    entry.uniqueID = [JNSTimeline GetUUID];
    
    if (self.uploadIDs == nil) {
        self.uploadIDs = [NSMutableArray new];
    }
    [self.uploadIDs addObject:entry.uniqueID];

    [self addEntriesObject:entry];
    [[JNSLoadManager manager] queueEntry:entry];
    
    // TODO listen to entry and update position when timestamp is known
}

-(void)loadLatest {
    if (isLoading) {
        NSLog(@"[JNSTimeline loadLatest] already loading");
        return;
    }
    
    UInt64 timestamp = [self.latestTimestamp longLongValue] + 1;


    NSURLRequest* request = [[JNSAPIClient sharedClient] requestWithMethod:@"GET"
                                                                      path:kTimelineURL
                                                                parameters:@{@"timestamp": [NSNumber numberWithLongLong: timestamp]}];
    
    AFJSONRequestOperation* opertion = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        isLoading = NO;
        
        NSArray* data = [JSON objectForKey:@"data"];
        NSMutableArray* indexies = [NSMutableArray new];
        for (NSString* str in data) {
            NSError* error;
            NSDictionary* obj = [NSJSONSerialization JSONObjectWithData:
                                 [str dataUsingEncoding:NSUTF8StringEncoding]
                                                                options:kNilOptions
                                                                  error:&error];
            // check unique id
            if (self.uploadIDs && [self.uploadIDs indexOfObject:[obj objectForKey:@"id"]] != NSNotFound) {
                NSLog(@"Ignoring local entry");
                continue; // local entry, ignore
            }
            
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
                    
                    [self insertObject:entry inEntriesAtIndex:index];
                }];
                [indexies addObject: [NSNumber numberWithUnsignedInteger:index]];
            }
            
            if ([entry.timestamp compare:self.latestTimestamp] == NSOrderedDescending) {
                NSLog(@"Update latest timeline timestamp to %@",entry.timestamp);
                self.latestTimestamp = entry.timestamp;
            }
        }
        [self.delegate didLoadLatestWithIndexes:indexies Error:nil];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        isLoading = NO;
        [self.delegate didLoadLatestWithIndexes:nil Error:error];        
    }];
    
    [[JNSAPIClient sharedClient] enqueueHTTPRequestOperation:opertion];
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

- (JNSTimelineEntry*)entryWithTimestamp:(NSNumber*)timestamp {
    // Enumerate reversely because it's most likely the last entry
    __block JNSTimelineEntry* result;
    [self.entries enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        JNSTimelineEntry* entry = obj;
        if ([entry.timestamp longLongValue] == [timestamp longLongValue]) {
            result = entry;
            *stop = YES;
        }
    }];
    return result;
}

// properties
- (JNSTimelineEntry*)activeEntry {
    // TODO change event
    JNSTimelineEntry* last = self.entries.lastObject;
    if (last && last.active) {
        return last;
    }
    return nil;
}

// overrides
-(void) awakeFromFetch {
    [super awakeFromFetch];
    
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

+ (NSString *)GetUUID
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString *)string;
}

@end
