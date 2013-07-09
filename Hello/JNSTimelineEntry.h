//
//  JNSTimelineEntry.h
//  Hello
//
//  Created by Shuai on 6/23/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface JNSTimelineEntry : NSManagedObject<NSURLConnectionDataDelegate>

@property UIImage* image;
@property (readonly) bool downloading;
@property (readonly) bool uploading;

// Core Data
@property (nonatomic, retain) NSNumber * timestamp;
@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSString * image_url;
@property (nonatomic, retain) NSString * imageCacheURL; // local cache


+(JNSTimelineEntry*)entryWithImage:(UIImage*)image Context:(NSManagedObjectContext*)context;
+(JNSTimelineEntry*)entryWithJSON:(NSDictionary*)json Context:(NSManagedObjectContext*)context;


// overrides
- (void)awakeFromFetch;

-(void) downloadContentProgress:(void(^)(unsigned progress, NSString* error))block;
-(void) upload;
- (void)trackUploadProgress:(void(^)(unsigned progress, NSString* error))block;

@end
