//
//  JNSTimelineEntry.h
//  Hello
//
//  Created by Shuai on 6/15/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JNSTimelineEntry;

@protocol JNSTimelineEntryDelegate <NSObject>

@required
-(void)downloadComplete:(JNSTimelineEntry*)entry;
-(void)uploadEntry:(JNSTimelineEntry*)entry Progress:(int)progress;
@end

@interface JNSTimelineEntry : NSObject<NSURLConnectionDataDelegate>

//@property NSString* image_file;
@property long timestamp;
//@property int height;
//@property int width;
@property UIImage* image;
@property id<JNSTimelineEntryDelegate> delegate;

// For uploading soon
-(JNSTimelineEntry*) initWithImage:(UIImage*)image;
-(JNSTimelineEntry*) initWithURL:(NSString*) url Delegate:(id<JNSTimelineEntryDelegate>)delegate;

-(void) downloadContent;
-(void) upload;

@end
