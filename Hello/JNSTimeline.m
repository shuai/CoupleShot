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

@interface JNSTimeline() {
    JNSConnection* _connection;
}
@end


@implementation JNSTimeline

@dynamic entries;

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
    [entry upload];
}

-(void)loadLatestCompletion:(void(^)(unsigned add, NSError* error))completion {
    if (_connection) {
        NSLog(@"[JNSTimeline loadLatest] already loading");
        return;
    }

    // TODO read the latest timestamp    
    UInt64 timestamp = 0;
    if ([self.entries count]) {
        timestamp = [((JNSTimelineEntry*)[self.entries lastObject]).timestamp longLongValue] + 1;
    }
    
    NSString* params = [NSString stringWithFormat:@"timestamp=%llu", timestamp];
    _connection = [JNSConnection connectionWithMethod:true
                                                  URL:kTimelineURL
                                               Params:params
                                           Completion:^(JNSConnection* connection, NSHTTPURLResponse *response, NSDictionary *json, NSError *error)
   {
       if (response.statusCode == 200 && json && error == nil) {
           NSArray* data = [json objectForKey:@"data"];
           for (NSString* str in data) {
               NSError* error;
               NSDictionary* obj = [NSJSONSerialization JSONObjectWithData:
                                    [str dataUsingEncoding:NSUTF8StringEncoding]
                                                                   options:kNilOptions
                                                                     error:&error];
               JNSTimelineEntry* entry = [JNSTimelineEntry entryWithJSON:obj
                                                                 Context:self.managedObjectContext];
               [self addEntriesObject:entry];
           }
           completion([data count], nil);
       } else {
           if (!error) {
               if (json) {
                   error = [NSError errorWithDomain:[json objectForKey:@"msg"] code:0 userInfo:nil];
               } else {
                   // TODO
               }
           }
           completion(0, error);
       }
   }];
}

@end
