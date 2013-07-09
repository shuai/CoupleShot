//
//  JNSConnection.h
//  Hello
//
//  Created by Shuai on 6/15/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* kHost;
extern NSString* kSignUpURL;
extern NSString* kSignInURL;
extern NSString* kPairURL;
extern NSString* kPairConfirmURL;
extern NSString* kTimelineURL;
extern NSString* kPostURL;


@interface JNSConnection : NSObject<NSURLConnectionDataDelegate>

-(id) initWithMethod:(BOOL)get
                 URL:(NSString*)url_str
              Params:(NSString*)params
          Completion:(void (^)(JNSConnection*, NSHTTPURLResponse*, NSDictionary*, NSError*))completion;

+(JNSConnection*) connectionWithRequest:(NSURLRequest*)request
                             Completion:(void (^)(JNSConnection*, NSHTTPURLResponse*, NSDictionary*, NSError*))completion;
+(JNSConnection*) connectionWithMethod:(BOOL)get
                                   URL:(NSString*)url
                                Params:(NSString*)params
                            Completion:(void (^)(JNSConnection*, NSHTTPURLResponse*, NSDictionary*, NSError*))completion;

@end
