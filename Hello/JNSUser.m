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
}

@end

@implementation JNSUser

@synthesize delegate, valid;
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
  
    NSString* body = [NSString stringWithFormat:@"user=%@", user];
    _connection = [JNSConnection connectionWithMethod:false
                                                  URL:kPairURL
                                               Params:body
                                           Completion:^(JNSConnection* connection, NSHTTPURLResponse *response, NSDictionary *json, NSError *error)
   {
       if (json) {
           [self updateJSON:json];
       }
       
       _connection = nil;
       completion([error localizedFailureReason]);
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

    NSString* body = [NSString stringWithFormat:@"user=%@", self.request];
    _connection = [JNSConnection connectionWithMethod:false
                                                  URL:kPairConfirmURL
                                               Params:body
                                           Completion:^(JNSConnection* connection, NSHTTPURLResponse *response, NSDictionary *json, NSError *error)
   {
       if (json) {
           [self updateJSON:json];
       }
       completion([error description]);
   }];
}

@end
