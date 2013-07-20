//
//  JNSTimelineEntry.h
//  Hello
//
//  Created by Shuai on 6/23/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>



@class JNSTimelineEntry;

@interface JNSTimelineEntry : NSManagedObject

@property (readonly) UIImage* image;
@property (readonly) bool downloading;
@property (readonly) bool uploading;
@property (readonly) bool needUpload;
@property (readonly) bool needDownload;

// Core Data
@property (nonatomic, retain) NSNumber * timestamp;
@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * imageCacheURL; // local cache


+(JNSTimelineEntry*)entryWithImage:(UIImage*)image
                           Context:(NSManagedObjectContext*)context;
+(JNSTimelineEntry*)entryWithJSON:(NSDictionary*)json
                          Context:(NSManagedObjectContext*)context;


// overrides
- (void)awakeFromFetch;

-(void) downloadWithCompletion:(void(^)(NSString* error))completion;
-(void) uploadWithCompletion:(void(^)(NSString* error))completion;

@end
