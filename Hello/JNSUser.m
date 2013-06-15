//
//  JNSUser.m
//  Hello
//
//  Created by Shuai on 6/12/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import "JNSUser.h"

@implementation JNSUser

JNSUser* current_user;

void (^pairCompletion)(NSString*);

JNSConnection* _connection;

-(void)requestComplete:(JNSConnection*)connection WithJSON:(NSDictionary *)json {
    NSAssert(connection == _connection, @"");
    NSString* msg = [json objectForKey:@"msg"];
    if (!msg) {
        msg = @"Connection problem";
    }

    bool ok = connection.response && connection.response.statusCode == 200;
        
    if ([connection.path compare:kSignInURL] == NSOrderedSame) {
        if (ok) {
            _valid = true;
            [self updateJSON:json];
            _timeline = [JNSTimeline new];
        } else {
            _valid = false;
        }
        [self.delegate validationComplete];
    } else if ([connection.path compare:kPairURL] == NSOrderedSame) {
        if (ok) {
            [self updateJSON:json];
        }
        
        pairCompletion(msg);
        pairCompletion = nil;
    } else if ([connection.path compare:kPairConfirmURL] == NSOrderedSame) {
        if (ok) {
            [self updateJSON:json];
        }
        pairCompletion(msg);
        pairCompletion = nil;
    }
    
    _connection = nil;
}

+(JNSUser*)userWithID:(NSString*)user_id Password:(NSString*)password Delegate:(id)delegate {
    JNSUser* user = [JNSUser new];
    [user initWithID:user_id Password:password Delegate:delegate];
    return user;
}

+(JNSUser*)loadUser {
    return nil;
}

-(void)initWithID:(NSString*)user_id Password:(NSString*)password Delegate:(id)delegate {
    _delegate = delegate;
    _user_id = user_id;

    NSString* body = [NSString stringWithFormat:@"user=%@&pwd=%@", user_id, password];
    _connection = [JNSConnection connectionWithMethod:false URL:kSignInURL Params:body Delegate:self];
}

-(void)pairWithUser: (NSString*) user Completion:(void (^)(NSString*))completion {
    NSAssert(!_connection, @"");
    NSAssert(!pairCompletion, @"Pending pair request");
    pairCompletion = completion;
    
    NSString* body = [NSString stringWithFormat:@"user=%@", user];
    _connection = [JNSConnection connectionWithMethod:false URL:kPairURL Params:body Delegate:self];
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
    
    NSString* body = [NSString stringWithFormat:@"user=%@&confirm=%@", _request, confirm?@"1":@"0"];
    _connection = [JNSConnection connectionWithMethod:false URL:kPairURL Params:body Delegate:self];
}

@end
