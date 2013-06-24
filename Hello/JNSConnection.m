//
//  JNSConnection.m
//  Hello
//
//  Created by Shuai on 6/15/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import "JNSConnection.h"

NSString* kHost = @"http://192.168.1.100";
NSString* kSignInURL = @"/signin";
NSString* kPairURL = @"/api/pair";
NSString* kPairConfirmURL = @"/api/pair";
NSString* kTimelineURL = @"/api/timeline";
NSString* kPostURL = @"/api/image";

@interface JNSConnection() {
    NSHTTPURLResponse* _response;
    NSMutableData* _data;
    void (^_completion)(JNSConnection*, NSHTTPURLResponse*, NSDictionary* json, NSError*);
}

@end

@implementation JNSConnection

-(id) initWithMethod:(BOOL)get
                 URL:(NSString*)url_str
              Params:(NSString*)params
          Completion:(void (^)(JNSConnection*, NSHTTPURLResponse*, NSDictionary*, NSError*))completion {
    
    url_str = [NSString stringWithFormat:@"%@?%@", url_str, params];

    NSLog(@"JNSConnection init %@ params:%@", get?@"GET":@"POST", params);

    NSURL* url = [NSURL URLWithString:url_str relativeToURL: [NSURL URLWithString:kHost]];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:get?@"GET":@"POST"];

    return [self initWithRequest:request Completion:completion];
}

-(id) initWithRequest:(NSURLRequest*)request
           Completion:(void (^)(JNSConnection*, NSHTTPURLResponse*, NSDictionary*, NSError*))completion {
    self = [super init];
    if (!self) {
        return nil;
    }

    _completion = completion;    
    [NSURLConnection connectionWithRequest:request delegate:self];
    return self;
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
    NSError* error;
    
    NSLog(@"requestComplete:\n %@\n", [_response description]);

    if ([[_response MIMEType] rangeOfString:@"json"].location != NSNotFound) {
        if (_response.statusCode == 200) {
            json = [NSJSONSerialization JSONObjectWithData:_data options:kNilOptions error:&error];
            NSLog(@"JSON:\n %@", [json description]);            
        } else {
            NSDictionary* obj = [NSJSONSerialization JSONObjectWithData:_data options:kNilOptions error:&error];
            error = [NSError errorWithDomain:[obj objectForKey:@"msg"]
                                        code:_response.statusCode
                                    userInfo:nil];
        }
    }
    _completion(self, _response, json, error);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    _completion(self, nil, nil, error);
}

+(JNSConnection*) connectionWithRequest:(NSURLRequest*)request
                             Completion:(void (^)(JNSConnection*, NSHTTPURLResponse*, NSDictionary*, NSError*))completion {
    return [[JNSConnection alloc] initWithRequest:request
                                       Completion:completion];
}

+(JNSConnection*) connectionWithMethod:(BOOL)get
                                   URL:(NSString*)url
                                Params:(NSString*)params
                            Completion:(void (^)(JNSConnection*, NSHTTPURLResponse*, NSDictionary*, NSError*))completion {
    JNSConnection* connection = [[JNSConnection alloc] initWithMethod:get
                                                                  URL:url
                                                               Params:params
                                                           Completion:completion];
    return connection;
}



@end
