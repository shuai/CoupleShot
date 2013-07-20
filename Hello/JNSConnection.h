//
//  JNSConnection.h
//  Hello
//
//  Created by Shuai on 6/15/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"

extern NSString* kHost;
extern NSString* kSignUpURL;
extern NSString* kSignInURL;
extern NSString* kPairURL;
extern NSString* kPairConfirmURL;
extern NSString* kTimelineURL;
extern NSString* kPostURL;
extern NSString* kSyncTokenURL;


@interface JNSConnection : NSObject<NSURLConnectionDataDelegate>

+(JNSConnection*) connectionWithRequest:(NSURLRequest*)request
                             Completion:(void (^)(JNSConnection*, NSHTTPURLResponse*, NSDictionary*, NSError*))completion;
+(JNSConnection*) connectionWithMethod:(BOOL)get
                                   URL:(NSString*)url
                                Params:(NSDictionary*)params
                            Completion:(void (^)(JNSConnection*, NSHTTPURLResponse*, NSDictionary*, NSError*))completion;
@end
