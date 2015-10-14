//
//  JNSTemplateManager.m
//  Hello
//
//  Created by Shuai on 7/28/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import "JNSTemplateManager.h"
#import "JNSUser.h"

const int kActivePhotoBottomPadding = 60;

@interface JNSSingleTemplate : NSObject<JNSTemplate>

@end

@interface JNSSingleActiveTemplate : JNSSingleTemplate
@end

@interface JNSHSplitTemplate : NSObject<JNSTemplate>

@end

@interface JNSVSplitTemplate : NSObject<JNSTemplate>

@end


@interface JNSTemplateManager() {
    id<JNSTemplate> _singleTemplate;
    id<JNSTemplate> _singleActiveTemplate;
    id<JNSTemplate> _hSplitTemplate;
    id<JNSTemplate> _vSplitTemplate;
    
    NSMutableArray* _array;
//    id<JNSTemplate> singleTemplate;
//    id<JNSTemplate> singleTemplate;
}

@end



@implementation JNSSingleTemplate

- (UIImage*)image {
    return nil;
}

- (struct JNSTemplateInfo)infoWithEntry:(JNSTimelineEntry*)entry Width:(int)width
{
    int imageWidth = [entry.subEntry1.width intValue];
    int imageHeight = [entry.subEntry1.height intValue];
    
    if (imageHeight > imageWidth) {
        // Clip to square
        imageHeight = imageWidth;
    }
    
    int height = width*imageHeight/imageWidth;
    
    struct JNSTemplateInfo info;
    info.rect1 = CGRectMake(0, 0, width, height);
    info.frame = CGRectMake(0, 0, width, height);
    return info;
}

@end

@implementation JNSSingleActiveTemplate

- (UIImage*)image {
    return nil;
}

- (struct JNSTemplateInfo)infoWithEntry:(JNSTimelineEntry*)entry Width:(int)width
{
    struct JNSTemplateInfo info = [super infoWithEntry:entry Width:width];
    info.frame.size.height += kActivePhotoBottomPadding;
    return info;
}

@end

@implementation JNSHSplitTemplate

- (UIImage*)image {
    return nil;
}

- (struct JNSTemplateInfo)infoWithEntry:(JNSTimelineEntry*)entry Width:(int)width
{
    NSAssert(entry.subEntry1, @"");
    NSAssert(entry.subEntry2, @"");
    
    int gap = 5;
    int photoWidth = (width - gap)/2;
    int height = width;
    
    struct JNSTemplateInfo info;
    info.rect1 = CGRectMake(0, 0, photoWidth, height);
    info.rect2 = CGRectMake(photoWidth+gap, 0, photoWidth, height);
    info.frame = CGRectMake(0, 0, width, height);
    return info;
}

@end

@implementation JNSVSplitTemplate

- (UIImage*)image {
    return nil;
}

@end


@implementation JNSTemplateManager

//@property (readonly) NSArray* templates;

+ (JNSTemplateManager*)manager
{
    static JNSTemplateManager* _manager;
    if (_manager == nil) {
        _manager = [JNSTemplateManager new];
    }
    return _manager;
}

- (JNSTemplateManager*)init
{
    self = [super init];
    if (self) {
        _singleTemplate = [JNSSingleTemplate new];
        _singleActiveTemplate = [JNSSingleActiveTemplate new];
        _hSplitTemplate = [JNSHSplitTemplate new];
        _vSplitTemplate = [JNSVSplitTemplate new];
        
        _array = [NSMutableArray new];
        
        [_array addObject:_singleActiveTemplate];
        [_array addObject:_hSplitTemplate];
        [_array addObject:_vSplitTemplate];
    }
    return self;
}

- (id<JNSTemplate>)templateForEntry:(JNSTimelineEntry*)entry
{
    NSAssert(entry.subEntry1,@"");
    
    if (!entry.subEntry2) {
        if (entry == [[JNSUser activeUser] timeline].activeEntry) {
            return _singleActiveTemplate;
        } else {
            return _singleTemplate;            
        }
    } else {
        return _hSplitTemplate;
    }
}

- (NSArray*)templates {
    return _array;
}

@end
