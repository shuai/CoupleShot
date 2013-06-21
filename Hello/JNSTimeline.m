//
//  JNSTimeline.m
//  Hello
//
//  Created by Shuai on 6/15/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import "JNSTimeline.h"
#import "JNSConnection.h"

@implementation JNSTimeline

- (id)init {
    self = [super init];
    if (self) {
        _array = [NSMutableArray new];
    }
    return self;
}

-(void) loadLatest {
    if (_connection) {
        NSLog(@"[JNSTimeline loadLatest] already loading");
        return;
    }
    
    long timestamp = 0;
    if ([_array count]) {
        timestamp = ((JNSTimelineEntry*)[_array lastObject]).timestamp;
    }
    
    // TODO read the latest timestamp
    NSString* params = [NSString stringWithFormat:@"timestamp=%ld", timestamp];
    _connection = [JNSConnection connectionWithMethod:true URL:kTimelineURL Params:params Delegate:self];
}

-(int)count {
    return [self.array count];
}

-(void)addEntry:(JNSTimelineEntry*)entry {
    [self.array addObject:entry];
    entry.delegate = self;
    [entry upload];
}


// delegates

-(void)requestComplete:(JNSConnection*)connection WithJSON:(NSDictionary*)json {
    // assume appending
    if (connection.response.statusCode == 200) {
        NSArray* data = [json objectForKey:@"data"];
        for (NSString* str in data) {
            NSError* error;
            NSDictionary* obj = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding]
                                                                options:kNilOptions
                                                                  error:&error];
            JNSTimelineEntry* entry = [[JNSTimelineEntry alloc] initWithURL:[obj objectForKey:@"url"]
                                                                   Delegate:self];
            
//            entry.width = [[obj objectForKey:@"width"] intValue];
//            entry.height = [[obj objectForKey:@"height"] intValue];
            entry.timestamp = [[obj objectForKey:@"time"] intValue];
            
            [entry downloadContent];
            [_array addObject:entry];
        }
        [_delegate pullComplte:[data count] WithError:nil];
    } else {
        NSString* err = [json objectForKey:@"msg"];
        [_delegate pullComplte:0 WithError:err];
    }
}

// JNSTimelineEntryDelegate

-(void)downloadComplete:(JNSTimelineEntry*)entry {
    int index = [_array indexOfObject:entry];
    NSAssert(index != NSNotFound, @"");
    // TODO error msg?
    [_delegate entryWithIndex:index LoadedWithError:nil];
}

-(void)uploadEntry:(JNSTimelineEntry*)entry Progress:(int)progress {
    
}


@end
