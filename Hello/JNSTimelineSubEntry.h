//
//  JNSTimelineSubEntry.h
//  Hello
//
//  Created by Shuai on 7/21/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface JNSTimelineSubEntry : NSManagedObject


@property (readonly) bool downloading;
@property (readonly) bool needUpload;
@property (readonly) bool needDownload;

// Core Data
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSString * imageCacheURL;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSNumber * width;

- (JNSTimelineSubEntry*)initWithImage:(UIImage*)image Context:(NSManagedObjectContext*)context;
- (JNSTimelineSubEntry*)initWithJSON:(NSDictionary*)json Context:(NSManagedObjectContext*)context;

- (void)downloadWithCompletion:(void(^)(NSString* error))completion;

@end
