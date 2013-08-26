//
//  JNSTimelineEntry.h
//  Hello
//
//  Created by Shuai on 6/23/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "JNSTimelineSubEntry.h"


@class JNSTimelineEntry;

@interface JNSTimelineEntry : NSManagedObject

@property (readonly) bool downloading;
@property (readonly) bool uploading;
@property (readonly) bool needUpload;
@property (readonly) bool needDownload;
@property (readonly) bool active;

// Core Data
@property Boolean solo;
@property (nonatomic, retain) NSNumber * timestamp;
@property (nonatomic, retain) NSNumber * expire;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) JNSTimelineSubEntry * subEntry1;
@property (nonatomic, retain) JNSTimelineSubEntry * subEntry2;


+(JNSTimelineEntry*)entryWithImage:(UIImage*)image
                           Context:(NSManagedObjectContext*)context;
+(JNSTimelineEntry*)entryWithJSON:(NSDictionary*)json
                          Context:(NSManagedObjectContext*)context;


// overrides
- (void)awakeFromFetch;

- (void)downloadWithCompletion:(void(^)(NSString* error))completion;
- (void)uploadWithCompletion:(void(^)(NSString* error))completion;
- (void)replyEntryWithImage:(UIImage*)image;

@end
