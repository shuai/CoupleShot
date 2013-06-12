//
//  JNSUser.h
//  Hello
//
//  Created by Shuai on 6/12/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol JNSUserDelegate

-(void)validationComplete;

@end



@interface JNSUser : NSObject<NSURLConnectionDataDelegate>

@property (weak) id<JNSUserDelegate> delegate;
@property (readonly) bool valid;
@property (readonly) NSString* partner_id;
@property (readonly) NSString* user_id;
@property (readonly) NSString* request;
@property (readonly) bool incoming;

+(JNSUser*)userWithID:(NSString*)user_id Password:(NSString*)password Delegate:(id)delegate;


-(void)initWithID:(NSString*)user_id Password:(NSString*)password Delegate:(id)delegate;
-(void)pairWithUser: (NSString*) user Completion:(void (^)(NSString*))completion;

@end