//
//  JNSConnection.m
//  Hello
//
//  Created by Shuai on 6/15/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import "JNSConnection.h"
#import "JNSConfig.h"

NSString* kHost = @"http://192.168.1.102";
NSString* kSignUpURL = @"/signup";
NSString* kSignInURL = @"/signin";
NSString* kPairURL = @"/api/pair";
NSString* kPairConfirmURL = @"/api/pair";
NSString* kTimelineURL = @"/api/timeline";
NSString* kPostURL = @"/api/image";
NSString* kSyncTokenURL = @"/api/synctoken";


@interface JNSConnection() {
    NSHTTPURLResponse* _response;
    NSMutableData* _data;
    void (^_completion)(JNSConnection*, NSHTTPURLResponse*, NSDictionary* json, NSError*);
}

@end

@implementation JNSConnection

-(id) initWithMethod:(BOOL)get
                 URL:(NSString*)url_str
              Params:(NSDictionary*)params
          Completion:(void (^)(JNSConnection*, NSHTTPURLResponse*, NSDictionary*, NSError*))completion {
    
    NSLog(@"JNSConnection init %@ params:%@", get?@"GET":@"POST", params);

    NSURL* url = [NSURL URLWithString:url_str relativeToURL: [NSURL URLWithString:kHost]];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:get?@"GET":@"POST"];

    // body params
    if (!get && [params count]) {
        NSString *boundary = @"---------------------------14737809831466499882746641449";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
        [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
        
        NSMutableData *postbody = [NSMutableData data];
        
        for (NSString* key in params) {
            [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary]
                                  dataUsingEncoding:NSUTF8StringEncoding]];
            NSString* disposition = [NSString stringWithFormat:
                                     @"Content-Disposition: form-data; name=\"%@\";\r\n\r\n", key];
            [postbody appendData:[disposition dataUsingEncoding:NSUTF8StringEncoding]];
            [postbody appendData:[((NSString*)[params objectForKey:key]) dataUsingEncoding:NSUTF8StringEncoding]];
        }

        
        [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary]
                              dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:postbody];
    }
    
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
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSAssert(!_response, @"");
    NSAssert(!_data, @"");
    
    _response = (NSHTTPURLResponse*)response;
    _data = [NSMutableData new];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSDictionary* json = nil;
    NSError* error;

    NSString* body = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
    NSLog(@"requestComplete:\n %@\n-------------\n%@\n", [_response description], body);
    

    if ([[_response MIMEType] rangeOfString:@"json"].location != NSNotFound) {
        if (_response.statusCode == 200) {
            json = [NSJSONSerialization JSONObjectWithData:_data options:kNilOptions error:&error];
        } else {
            // Reset user
            if (_response.statusCode == 401) {
                [JNSConfig config].cachedUser = nil;
            }
            
            NSDictionary* obj = [NSJSONSerialization JSONObjectWithData:_data options:kNilOptions error:&error];
            error = [NSError errorWithDomain:@"Network"
                                        code:_response.statusCode
                                    userInfo:[NSDictionary dictionaryWithObject:[obj objectForKey:@"msg"]
                                                                         forKey: NSLocalizedDescriptionKey]];
            
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
                                Params:(NSDictionary*)params
                            Completion:(void (^)(JNSConnection*, NSHTTPURLResponse*, NSDictionary*, NSError*))completion {
    JNSConnection* connection = [[JNSConnection alloc] initWithMethod:get
                                                                  URL:url
                                                               Params:params
                                                           Completion:completion];
    return connection;
}


@end
