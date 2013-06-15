//
//  JNSTimeline.h
//  Hello
//
//  Created by Shuai on 6/15/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JNSConnection.h"

@interface JNSTimeline : NSObject<JNSConnectionDelegate>

-(void) loadLatest;

@end
