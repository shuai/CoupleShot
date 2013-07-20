//
//  JNSEntryView.m
//  Hello
//
//  Created by Shuai on 7/20/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import "JNSEntryView.h"

const int kContentMargin = 5;

@interface JNSEntryView() {
    UILabel* _label;
    UIActivityIndicatorView* _spinner;
    UIImageView* _image;
}

@property JNSTimelineEntry* entry;

@end


@implementation JNSEntryView


+ (int)heightForEntry:(JNSTimelineEntry*)entry {
    int height = 0;
    
    if ([entry.width intValue] != 0) {
        int width = 320-kContentMargin*2;
        height = [entry.height intValue]*width/[entry.width intValue] + kContentMargin - 2; // border
    } else {
        // TODO arbitraty default height
        height = 240;
    }
    
    return height;
}

- (JNSEntryView*)initWithEntry:(JNSTimelineEntry*)entry {
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, 320, [JNSEntryView heightForEntry:entry]);
        _entry = entry;
        
        int width = 320-kContentMargin*2;
        int height = 240;
        
        if (entry.height) {
            height = [entry.height intValue] * width / [entry.width intValue];
        }

        CGRect frame = CGRectMake(kContentMargin, 0, width, height);
        _image = [[UIImageView alloc] initWithFrame:frame];
        _image.image = entry.image;
        // TODO slow
        CALayer* layer = _image.layer;
        layer.cornerRadius = 5;
        layer.borderColor = [[UIColor colorWithWhite:0.5 alpha:0.2] CGColor];
        layer.borderWidth = 1;
        layer.masksToBounds = true;
        
        //        layer.shadowColor = [UIColor blackColor].CGColor;
        //        layer.shadowOpacity = 0.5;
        //        layer.shadowRadius = 10;
        //        layer.shadowOffset = CGSizeMake(3, 3);
        
        [self addSubview:_image];
        
        _label = [self createLabel];
        [self addSubview:_label];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observeNotification:) name:nil object:entry];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)observeNotification:(NSNotification*)notification {
    if (_entry.uploading || _entry.downloading) {
        if (!_spinner) {
            int size = 10;
            _spinner = [[UIActivityIndicatorView alloc] initWithFrame:[self frameForViewSize:CGSizeMake(size, size)]];
            _spinner.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.5];
            _spinner.layer.cornerRadius = 5;
            _spinner.layer.masksToBounds = YES;

            _spinner.alpha = 0;
            [self addSubview:_spinner];
            [_spinner startAnimating];
            
            [UIView animateWithDuration:0.2 animations:^{
                _spinner.alpha = 1;
                if (_label) {
                    _label.alpha = 0;
                }
            }];
        }
        
    } else {
        UIView* oldLabel = _label;
        UIView* oldSpinner = _spinner;
        
        _label = [self createLabel];
        _label.alpha = 0;
        [self addSubview:_label];
        
        [UIView animateWithDuration:0.4 animations:^{
            if (oldSpinner) {
                oldSpinner.alpha = 0;
            }
            _label.alpha = 1;
            oldLabel.alpha = 0;
        } completion:^(BOOL finished) {
            [oldLabel removeFromSuperview];
            [oldSpinner removeFromSuperview];
        }];
    }
    
    if (_entry.image && _image.image == nil) {
        _image.image = _entry.image;
    }
}

- (UILabel*)createLabel {
    // Add time label
    UILabel* label = [[UILabel alloc] init];
    NSDate* date = [NSDate dateWithTimeIntervalSince1970: [_entry.timestamp doubleValue]/1000];
    int interval = -[date timeIntervalSinceNow];
    if (interval < 0) {
        interval = 0;
    }
    
    NSString* text;
    if (_entry.needUpload) {
        text = @"等待上传";
    } else if (_entry.needDownload) {
        text = @"等待下载";
    } else if (interval < 5*60) {
        text = @"刚刚";
    } else if (interval < 60*60) {
        text = [NSString stringWithFormat:@"%d分钟前", (int)interval/60];
    } else if (interval < 24*60*60) {
        text = [NSString stringWithFormat:@"%d小时前", (int)interval/3600];
    } else {
        text = [NSString stringWithFormat:@"%d天前", (int)interval/(24*3600)];
    }
    
    [label setText:text];
    label.font = [UIFont systemFontOfSize:9];
    CGRect rect = [self frameForViewSize:[label intrinsicContentSize]];
    label.frame = rect;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithWhite:0.8 alpha:1];
    label.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.5];
    label.layer.cornerRadius = 5;
    label.layer.masksToBounds = YES;
    
    return label;
}

- (CGRect)frameForViewSize:(CGSize)size {
    CGRect rect = CGRectMake(300 - size.width - 10,
                             10,
                             size.width+10,
                             size.height+10);
    return rect;
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
