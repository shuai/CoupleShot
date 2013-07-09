//
//  JNSConfig.h
//  Hello
//
//  Created by Shuai on 6/22/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "JNSUser.h"

@interface JNSConfig : NSManagedObject

// Core Data
@property (nonatomic, retain) JNSUser * cachedUser;
@property NSNumber* nextImageID;

+ (NSNumber*)uniqueImageID;
+ (void)setConfig:(JNSConfig*)config;
+ (JNSConfig*)config;

@end
