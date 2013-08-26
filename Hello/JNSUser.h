//
//  JNSUser.h
//  Hello
//
//  Created by Shuai on 6/12/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "JNSTimeline.h"
#import "JNSConnection.h"

@interface JNSUser : NSManagedObject


// Core Data
@property NSString* partner;
@property NSString* email;
@property NSString* request;
@property Boolean incoming;
@property JNSTimeline* timeline;

// to load from network
+(JNSUser*)userWithID:(NSString*)email JSON:(NSDictionary*)json Context:(NSManagedObjectContext*)context;
+(JNSUser*)activeUser;

-(void)pairWithUser: (NSString*) user Completion:(void (^)(NSString*))completion;
-(void)confirmRequest:(bool)confirm Completion:(void (^)(NSString*))completion;
-(void)syncDeviceToken:(NSData*)deviceToken;
-(void)updateJSON:(NSDictionary*)json;

@end