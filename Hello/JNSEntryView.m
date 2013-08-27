//
//  JNSEntryView.m
//  Hello
//
//  Created by Shuai on 7/20/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import "JNSEntryView.h"
#import "JNSClippedImageView.h"
#import "JNSTemplateManager.h"

const int kContentWidth = 310;
const int kContentHMargin = (320 - kContentWidth)/2;
const int kContentTopMargin = 5;
const int kPhotoBottomPadding = 60;

@interface JNSEntryView() {
    UILabel* _label;
    UIActivityIndicatorView* _spinner;
    UIImageView* _image1;
    UIImageView* _image2;
}

@property JNSTimelineEntry* entry;

@end


@implementation JNSEntryView

+ (int)heightForEntry:(JNSTimelineEntry*)entry {    
    return [self heightForContentOfEntry:entry] + kContentTopMargin;
}

+ (int)heightForContentOfEntry:(JNSTimelineEntry*)entry {
    id<JNSTemplate> template = [[JNSTemplateManager manager] templateForEntry:entry];
    
    struct JNSTemplateInfo info = [template infoWithEntry:entry Width:kContentWidth];
    
    return info.frame.size.height;
}

- (JNSEntryView*)initWithEntry:(JNSTimelineEntry*)entry {
    _entry = entry;

    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
        self.frame = CGRectMake(kContentHMargin, kContentTopMargin, kContentWidth, [JNSEntryView heightForContentOfEntry:entry]);
        
        // TODO slow
        CALayer* layer = self.layer;
        layer.cornerRadius = 5;
        layer.borderColor = [[UIColor colorWithWhite:0.5 alpha:0.2] CGColor];
        layer.borderWidth = 1;
        layer.masksToBounds = true;
        
        [self updateContent];
        
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
    if ([notification.name compare:@"ContentChanged"] == NSOrderedSame) {
        // update template
        [self updateContent];
    } else {
        // statue update
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
    }
}

- (void)updateContent {    
    id<JNSTemplate> template = [[JNSTemplateManager manager] templateForEntry:_entry];
    struct JNSTemplateInfo info = [template infoWithEntry:_entry Width:kContentWidth];
    
    if (_entry.subEntry1) {
        if (!_image1) {
            _image1 = [[UIImageView alloc] initWithFrame:info.rect1];
            _image1.image = [UIImage imageWithContentsOfFile:_entry.subEntry1.imageCacheURL];
            _image1.contentMode = UIViewContentModeScaleAspectFill;
            _image1.clipsToBounds = YES;
            _image1.frame = info.rect1;
            [self addSubview:_image1];
        } else {
            _image1.image = [UIImage imageWithContentsOfFile:_entry.subEntry1.imageCacheURL];
            [UIView animateWithDuration:0.2 animations:^{
                _image1.frame = info.rect1;
            }];
        }
    }
    
    if (_entry.subEntry2) {
        if (!_image2) {
            _image2 = [[UIImageView alloc] initWithFrame:info.rect2];
            _image2.image = [UIImage imageWithContentsOfFile:_entry.subEntry2.imageCacheURL];
            _image2.contentMode = UIViewContentModeScaleAspectFill;
            _image2.clipsToBounds = YES;
            _image2.frame = info.rect2;            
            [self addSubview:_image2];
        } else {
            _image2.image = [UIImage imageWithContentsOfFile:_entry.subEntry2.imageCacheURL];
            [UIView animateWithDuration:0.2 animations:^{
                _image2.frame = info.rect2;
            }];
        }
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
        text = @"";
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
