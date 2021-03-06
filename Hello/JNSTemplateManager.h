//
//  JNSTemplateManager.h
//  Hello
//
//  Created by Shuai on 7/28/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JNSTimelineEntry.h"


struct JNSTemplateInfo
{
    CGRect rect1;
    CGRect rect2;
    CGRect frame;
};

@protocol JNSTemplate <NSObject>

@required
- (struct JNSTemplateInfo)infoWithEntry:(JNSTimelineEntry*)entry Width:(int)width;
@property (readonly) UIImage* image;

@end

@interface JNSTemplateManager : NSObject

@property (readonly) NSArray* templates;

+ (JNSTemplateManager*)manager;

- (id<JNSTemplate>)templateForEntry:(JNSTimelineEntry*)entry;

@end
