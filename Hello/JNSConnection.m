//
//  JNSConnection.m
//  Hello
//
//  Created by Shuai on 6/15/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import "JNSConnection.h"

@implementation JNSConnection

NSString* kHost = @"http://localhost";
NSString* kSignInURL = @"/signin";
NSString* kPairURL = @"/api/pair";
NSString* kPairConfirmURL = @"/api/pair/confirm";
NSString* kTimelineURL = @"/api/timeline";

id<JNSConnectionDelegate> _delegate;

-(void)initWithMethod:(BOOL)get URL:(NSString*)url_str Params:(NSString*)params Delegate:(id<JNSConnectionDelegate>)delegate {
    _delegate = delegate;
    _path = url_str;
    
    url_str = [NSString stringWithFormat:@"%@?%@", url_str, params];

    NSLog(@"JNSConnection init %@ params:%@", get?@"GET":@"POST", params);

    NSURL* url = [NSURL URLWithString:url_str relativeToURL: [NSURL URLWithString:kHost]];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:get?@"GET":@"POST"];

    [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_data appendData:data];
    NSLog(@"didReceiveData, length:%d", data.length);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSAssert(!_response, @"");
    NSAssert(!_data, @"");
    
    _response = (NSHTTPURLResponse*)response;
    _data = [NSMutableData new];
    
    NSLog(@"didReceiveResponse, relativePath:%@, status:%d", _response.URL.relativePath, [_response statusCode]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSDictionary* json = nil;
    if ([[_response MIMEType] rangeOfString:@"json"].location != NSNotFound) {
        NSError* error;
        json = [NSJSONSerialization JSONObjectWithData:_data options:kNilOptions error:&error];
        NSLog(@"requestComplete:\n %@", [json description]);        
    }
    [_delegate requestComplete:self WithJSON:json];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [_delegate requestComplete:self WithJSON:nil];
}

+(JNSConnection*) connectionWithMethod:(BOOL)get URL:(NSString*)url_str Params:(NSString*)params Delegate:(id<JNSConnectionDelegate>)delegate {
    JNSConnection* connection = [JNSConnection alloc];
    [connection initWithMethod:get URL:url_str Params:params Delegate:delegate];
    return connection;
}

@end
