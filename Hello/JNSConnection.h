//
//  JNSConnection.h
//  Hello
//
//  Created by Shuai on 6/15/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* kHost;
extern NSString* kSignInURL;
extern NSString* kPairURL;
extern NSString* kPairConfirmURL;
extern NSString* kTimelineURL;

@class JNSConnection;

@protocol JNSConnectionDelegate

@optional
-(void)requestComplete:(JNSConnection*)connection WithJSON:(NSDictionary*)json;

@end


@interface JNSConnection : NSObject<NSURLConnectionDataDelegate>

@property NSMutableData* data;
@property NSHTTPURLResponse* response;
@property (readonly) NSString* path;

-(void)initWithMethod:(BOOL)get
                  URL:(NSString*)url_str
                 Params:(NSString*)params
             Delegate:(id<JNSConnectionDelegate>)delegate;

+(JNSConnection*) connectionWithMethod:(BOOL)get
                                     URL:(NSString*)url
                                    Params:(NSString*)params
                                Delegate:(id<JNSConnectionDelegate>)delegate;

@end
