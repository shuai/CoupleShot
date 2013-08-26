//
//  JNSClippedImageView.m
//  Hello
//
//  Created by Shuai on 7/28/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import "JNSClippedImageView.h"

@implementation JNSClippedImageView

+ (int)heightForEntry:(JNSTimelineSubEntry*)entry WithWidth:(int)width
{
    int imageWidth = [entry.width intValue];
    int imageHeight = [entry.height intValue];
    
    if (imageHeight > imageWidth) {
        // Clip to rect
        imageHeight = imageWidth;
    }
    
    return width*imageHeight/imageWidth;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
