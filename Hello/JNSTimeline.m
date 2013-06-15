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

JNSConnection* _connection;

-(void) loadLatest {
    if (_connection) {
        NSLog(@"[JNSTimeline loadLatest] already loading");
        return;
    }

    // TODO read the latest timestamp
    NSString* params = [NSString stringWithFormat:@"timestamp=0"];
    _connection = [JNSConnection connectionWithMethod:false URL:kTimelineURL Params:params Delegate:self];
}

-(void)requestComplete:(JNSConnection*)connection WithJSON:(NSDictionary*)json {
    
}

@end
