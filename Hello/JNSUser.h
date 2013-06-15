//
//  JNSUser.h
//  Hello
//
//  Created by Shuai on 6/12/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JNSTimeline.h"
#import "JNSConnection.h"

@protocol JNSUserDelegate

-(void)validationComplete;

@end

@class JNSUser;
extern JNSUser* current_user;

@interface JNSUser : NSObject<JNSConnectionDelegate>

@property (weak) id<JNSUserDelegate> delegate;
@property (readonly) bool valid;
@property (readonly) NSString* partner_id;
@property (readonly) NSString* user_id;
@property (readonly) NSString* request;
@property (readonly) bool incoming;
@property JNSTimeline* timeline;

// load from network
+(JNSUser*)userWithID:(NSString*)user_id Password:(NSString*)password Delegate:(id)delegate;
// load from cache
+(JNSUser*)loadUser;

-(void)initWithID:(NSString*)user_id Password:(NSString*)password Delegate:(id)delegate;
-(void)pairWithUser: (NSString*) user Completion:(void (^)(NSString*))completion;
-(void)confirmRequest:(bool)confirm Completion:(void (^)(NSString*))completion;

@end