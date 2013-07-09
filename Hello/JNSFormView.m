//
//  JNSFormView.m
//  Hello
//
//  Created by Shuai on 7/3/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import "JNSFormView.h"

@implementation JNSFormView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initLayer];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self initLayer];
    }
    return self;
}

- (void)initLayer {
    CALayer* layer = self.layer;
    layer.cornerRadius = 5;
    layer.borderColor = [[UIColor colorWithWhite:0.5 alpha:0.5] CGColor];
    layer.borderWidth = 1;
    layer.masksToBounds = true;    
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef contex = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(contex, 1, [self frame].size.height/2);
    CGContextAddLineToPoint(contex, [self frame].size.width-1, [self frame].size.height/2);
    UIColor* color = [UIColor colorWithWhite:0.5 alpha:0.5];
    CGContextSetStrokeColorWithColor(contex, [color CGColor]);
    CGContextStrokePath(contex);
}


@end
