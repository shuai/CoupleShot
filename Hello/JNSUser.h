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

@protocol JNSUserDelegate
@optional
-(void)validationComplete;
@end


@interface JNSUser : NSManagedObject

@property (weak) id<JNSUserDelegate> delegate;
@property (readonly) bool valid;

// Core Data
@property NSString* partner;
@property NSString* email;
@property NSString* request;
@property bool incoming;
@property JNSTimeline* timeline;

// to load from network
+(JNSUser*)userWithID:(NSString*)email JSON:(NSDictionary*)json Context:(NSManagedObjectContext*)context;
+(JNSUser*)activeUser;

-(void)pairWithUser: (NSString*) user Completion:(void (^)(NSString*))completion;
-(void)confirmRequest:(bool)confirm Completion:(void (^)(NSString*))completion;

@end