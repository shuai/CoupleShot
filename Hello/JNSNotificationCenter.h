//
//  JNSNotificationCenter.h
//  Hello
//
//  Created by Shuai on 7/20/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JNSNotificationCenter : NSObject

+ (void)postNotificationWithName:(NSString*)name
                          Object:(id)obj
                            Type:(int)type
                        UserInfo:(NSDictionary*)dict;

@end
