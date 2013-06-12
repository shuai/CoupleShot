//
//  JNSUser.m
//  Hello
//
//  Created by Shuai on 6/12/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import "JNSUser.h"

@implementation JNSUser

NSString* kHost = @"http://localhost";
NSString* kSignInURL = @"/signin";
NSString* kPairURL = @"/api/pair";
NSString* kPairConfirmURL = @"/api/pair/confirm";

void (^pairCompletion)(NSString*);

NSURLConnection* _connection;
NSHTTPURLResponse* _response;
NSMutableData* _data;

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSAssert(connection == _connection, @"");

    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:_data options:kNilOptions error:&error];
    NSString* msg = [json objectForKey:@"msg"];

    NSLog(@"connectionDidFinishLoading:\n %@", [json description]);

    if ([_response.URL.relativePath compare:kSignInURL] == NSOrderedSame) {
        if (200 == [_response statusCode]) {
            _valid = true;
            [self updateJSON:json];
        } else {
            _valid = false;
        }
        [self.delegate validationComplete];
    } else if ([_response.URL.relativePath compare:kPairURL] == NSOrderedSame) {
        if (200 == [_response statusCode]) {
            [self updateJSON:json];
        }
        
        pairCompletion(msg);
        pairCompletion = nil;
    } else if ([_response.URL.relativePath compare:kPairConfirmURL] == NSOrderedSame) {
        if (200 == [_response statusCode]) {
            [self updateJSON:json];
        }
        pairCompletion(msg);
        pairCompletion = nil;
    }
    
    _connection = nil;
    _response = nil;
    _data = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSAssert(connection == _connection, @"");
    [_data appendData:data];
    NSLog(@"didReceiveData, length:%d", data.length);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSAssert(connection == _connection, @"");
    NSAssert(!_response, @"");
    NSAssert(!_data, @"");
    
    _response = (NSHTTPURLResponse*)response;
    _data = [NSMutableData new];

    NSLog(@"didReceiveResponse, relativePath:%@, status:%d", _response.URL.relativePath, [_response statusCode]);
}

+(JNSUser*)userWithID:(NSString*)user_id Password:(NSString*)password Delegate:(id)delegate {
    JNSUser* user = [JNSUser new];
    [user initWithID:user_id Password:password Delegate:delegate];
    return user;
}

-(void)initWithID:(NSString*)user_id Password:(NSString*)password Delegate:(id)delegate {
    _delegate = delegate;
    _user_id = user_id;
    
    NSURL* url = [NSURL URLWithString:kSignInURL relativeToURL: [NSURL URLWithString:kHost]];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    NSString* body = [NSString stringWithFormat:@"user=%@&pwd=%@", user_id, password];
    NSData* data = [body dataUsingEncoding:(NSUTF8StringEncoding)];
    [request setHTTPBody:data];
    
    _connection = [NSURLConnection connectionWithRequest:request delegate:self];
}

-(void)pairWithUser: (NSString*) user Completion:(void (^)(NSString*))completion {
    NSAssert(!_connection, @"");
    NSAssert(!pairCompletion, @"Pending pair request");
    pairCompletion = completion;

    NSURL* url = [NSURL URLWithString:kPairURL relativeToURL: [NSURL URLWithString:kHost]];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    NSString* body = [NSString stringWithFormat:@"user=%@", user];
    NSData* data = [body dataUsingEncoding:(NSUTF8StringEncoding)];
    [request setHTTPBody:data];

    _connection = [NSURLConnection connectionWithRequest:request delegate:self];
}


// utility
-(void)updateJSON:(NSDictionary*)json {
    _partner_id = [json objectForKey:@"partner"];
    _request = [json objectForKey:@"request"];
    id obj = [json objectForKey:@"incoming"];
    _incoming = [obj boolValue];
}

-(void)confirmRequest:(bool)confirm Completion:(void (^)(NSString*))completion {
    NSAssert(!_connection, @"");
    NSAssert(_request && _request.length, @"");
    NSAssert(!pairCompletion, @"Pending pair request");

    pairCompletion = completion;

    NSURL* url = [NSURL URLWithString:kPairURL relativeToURL: [NSURL URLWithString:kHost]];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    NSString* body = [NSString stringWithFormat:@"user=%@&confirm=%@", _request, confirm?@"1":@"0"];
    NSData* data = [body dataUsingEncoding:(NSUTF8StringEncoding)];
    [request setHTTPBody:data];
    
    _connection = [NSURLConnection connectionWithRequest:request delegate:self];
}

@end
