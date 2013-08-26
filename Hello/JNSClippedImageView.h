//
//  JNSClippedImageView.h
//  Hello
//
//  Created by Shuai on 7/28/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JNSTimelineSubEntry.h"

@interface JNSClippedImageView : UIImageView

+ (int)heightForEntry:(JNSTimelineSubEntry*)entry WithWidth:(int)width;

@end
