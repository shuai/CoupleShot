//
//  JNSUser.m
//  Hello
//
//  Created by Shuai on 6/12/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import "JNSUser.h"
#import "JNSConfig.h"
#import <CoreData/CoreData.h>

JNSUser* activeUser;

@interface JNSUser() {
    JNSConnection* _connection;
    JNSConnection* _syncToken;
}

@end

@implementation JNSUser

@dynamic partner, email, request, incoming, timeline;

+(JNSUser*)userWithID:(NSString*)email JSON:(NSDictionary*)json Context:(NSManagedObjectContext*)context {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"JNSUser"
                                              inManagedObjectContext:context];
    JNSUser* user = [[JNSUser alloc] initWithEntity:entity
                     insertIntoManagedObjectContext:context];
    [user updateJSON:json];
    user.timeline = [JNSTimeline timelineWithContext:context];
    return user;
}

+(JNSUser*)activeUser {
    return [JNSConfig config].cachedUser;
}

-(void)pairWithUser: (NSString*) user Completion:(void (^)(NSString*))completion {
    NSAssert(!_connection, @"pairWithUser called when _connection exists");
  
    NSString* url = [NSString stringWithFormat:@"%@?user=%@", kPairURL, user];
    _connection = [JNSConnection connectionWithMethod:false
                                                  URL:url
                                               Params:nil
                                           Completion:^(JNSConnection* connection, NSHTTPURLResponse *response, NSDictionary *json, NSError *error)
   {
       if (json) {
           [self updateJSON:json];
       }
       
       _connection = nil;
       completion([error localizedDescription]);
   }];
}

// utility
-(void)updateJSON:(NSDictionary*)json {
    self.partner = [json objectForKey:@"partner"];
    self.request = [json objectForKey:@"request"];
    id obj = [json objectForKey:@"incoming"];
    self.incoming = [obj boolValue];
}

-(void)confirmRequest:(bool)confirm Completion:(void (^)(NSString*))completion {
    NSAssert(!_connection, @"");
    NSAssert(self.request && self.request.length, @"");

    NSString* url = [NSString stringWithFormat:@"%@?user=%@", kPairConfirmURL, self.request];
    _connection = [JNSConnection connectionWithMethod:false
                                                  URL:url
                                               Params:nil
                                           Completion:^(JNSConnection* connection, NSHTTPURLResponse *response, NSDictionary *json, NSError *error)
   {
       if (json) {
           [self updateJSON:json];
       }
       completion([error description]);
   }];
}

-(void)syncDeviceToken:(NSData*)deviceToken {
    if (!_syncToken) {
        NSDictionary* params = [NSDictionary dictionaryWithObject:[deviceToken base64Encoding] forKey:@"token"];
        _syncToken = [JNSConnection connectionWithMethod:false
                                                     URL:kSyncTokenURL
                                                  Params:params
                                              Completion:^(JNSConnection* connection, NSHTTPURLResponse *response, NSDictionary *json, NSError *error)
                      {
                          
                      }];
    }
}

@end
