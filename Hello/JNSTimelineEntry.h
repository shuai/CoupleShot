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
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSString * image_url;


+(JNSTimelineEntry*)entryWithImage:(UIImage*)image Context:(NSManagedObjectContext*)context;
+(JNSTimelineEntry*)entryWithJSON:(NSDictionary*)json Context:(NSManagedObjectContext*)context;


// overrides
- (void)awakeFromFetch;

-(void) downloadContentCompletion:(void(^)(JNSTimelineEntry*, NSString* error))completion;
-(void) upload;
- (void)trackUploadProgress:(void(^)(unsigned, NSString* error))block;

@end
