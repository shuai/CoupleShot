//
//  JNSEntryView.h
//  Hello
//
//  Created by Shuai on 7/20/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JNSTimelineEntry.h"

@interface JNSEntryView : UIView

+ (int)heightForEntry:(JNSTimelineEntry*)entry;
- (JNSEntryView*)initWithEntry:(JNSTimelineEntry*)entry;

@end
