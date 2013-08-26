//
//  JNSTimelineEntry.m
//  Hello
//
//  Created by Shuai on 6/23/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import "JNSTimelineEntry.h"
#import "JNSConnection.h"
#import "JNSConfig.h"
#import "JNSAPIClient.h"
#import "AFImageRequestOperation.h"
#import "AFJSONRequestOperation.h"

@interface JNSTimelineEntry(){
}

@property (readwrite) bool uploading;

@end

@implementation JNSTimelineEntry

@dynamic solo, timestamp, expire, uniqueID, subEntry1, subEntry2;
@synthesize uploading;

+(JNSTimelineEntry*)entryWithImage:(UIImage*)image
                           Context:(NSManagedObjectContext*)context {
    JNSTimelineEntry* entry = [JNSTimelineEntry entryWithContext:context];
    entry.subEntry1 = [[JNSTimelineSubEntry alloc] initWithImage:image Context:context];
    return entry;
}

+(JNSTimelineEntry*)entryWithJSON:(NSDictionary*)json
                          Context:(NSManagedObjectContext*)context {
    JNSTimelineEntry* entry = [JNSTimelineEntry entryWithContext:context];    
    [entry updateFromJSON:json];
    return entry;
}

+(JNSTimelineEntry*)entryWithContext:(NSManagedObjectContext*)context {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"JNSTimelineEntry"
                                              inManagedObjectContext:context];
    
    JNSTimelineEntry* entry = [[JNSTimelineEntry alloc] initWithEntity:entity
                                        insertIntoManagedObjectContext:context];
    return entry;
}

// overrides
-(void) awakeFromFetch {
}

- (bool)downloading {
    return self.subEntry1.downloading || self.subEntry2.downloading;
}

-(bool) needUpload {
    NSAssert(self.subEntry1, @"");
    return self.subEntry1.needUpload || self.subEntry2.needUpload;
}

-(bool) needDownload {
    return self.subEntry1.needDownload || self.subEntry2.needDownload;
}

-(bool) active {
    NSDate* expire = [NSDate dateWithTimeIntervalSince1970:[self.expire longLongValue]/1000];
    return [expire compare:[NSDate date]] == NSOrderedDescending && self.subEntry2 == nil;
}

//
- (void)replyEntryWithImage:(UIImage*)image {
    // set image
    NSAssert(self.subEntry1, @"");
    NSAssert(!self.subEntry2, @"");
    
    self.subEntry2 = [[JNSTimelineSubEntry alloc] initWithImage:image Context:self.managedObjectContext];
    [self uploadWithCompletion:^(NSString *error) {
        // TODO contentChanged??
    }];
}
-(void) uploadWithCompletion:(void(^)(NSString* error))completion {
    NSAssert(!self.uploading, @"");
    NSAssert(self.needUpload, @"");
    NSAssert(self.subEntry1, @"");
    NSAssert(self.subEntry1.needUpload || (self.subEntry2 && self.subEntry2.needUpload), @"");
    
    self.uploading = YES;

    JNSAPIClient* client = [JNSAPIClient sharedClient];

    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadStarted"
                                                        object:self
                                                      userInfo:nil];
    
    if (self.subEntry1.needUpload) {
        JNSTimelineSubEntry* entry = self.subEntry1;
        
        NSAssert(entry.width != 0, @"");
        NSAssert(entry.height != 0, @"");
        NSAssert(self.uniqueID, @"");
        
        NSDictionary* params = @{@"width": entry.width,
                                 @"height":entry.height,
                                 @"id":self.uniqueID};
        
        
        NSData *imageData = [NSData dataWithContentsOfFile:entry.imageCacheURL];
        NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST"
                                                                         path:kNewEntryURL
                                                                   parameters:params
                                                    constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                        [formData appendPartWithFileData:imageData name:@"image" fileName:@"image.png" mimeType:@"image/png"];
                                                    }];
        
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            self.uploading = NO;
            entry.imageURL = JSON[@"subentry1"][@"image"][@"url"];
            completion(nil);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadSucceeded" object:self userInfo:nil];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            self.uploading = NO;
            
            completion([error localizedDescription]);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadFailed" object:self userInfo:@{@"error": error}];
        }];
        
        // TODO progress
        
        // TODO handle over to load manager
        [[JNSAPIClient sharedClient] enqueueHTTPRequestOperation:operation];
    } else {
        // replying
        JNSTimelineSubEntry* entry = self.subEntry2;

        NSDictionary* params = @{@"timestamp":self.timestamp,
                                 @"width": entry.width,
                                 @"height":entry.height};
        
        NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:kReplyEntryURL parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:[NSData dataWithContentsOfFile:entry.imageCacheURL]
                                        name:@"image"
                                    fileName:@"image.png"
                                    mimeType:@"image/png"];
        }];
        
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            self.uploading = NO;
            entry.imageURL = JSON[@"subentry2"][@"image"][@"url"];
            NSAssert(entry.imageURL, @"");
            completion(nil);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadSucceeded" object:self userInfo:nil];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            self.uploading = NO;
            
            completion([error localizedDescription]);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadFailed" object:self userInfo:@{@"error": error}];
        }];

        [[JNSAPIClient sharedClient] enqueueHTTPRequestOperation:operation];
    }
}

-(void) downloadWithCompletion:(void(^)(NSString* error))completion {
    NSAssert(self.subEntry1, @"");

    [[NSNotificationCenter defaultCenter] postNotificationName:@"DownloadStarted"
                                                        object:self
                                                      userInfo:nil];
    
    [self.subEntry1 downloadWithCompletion:^(NSString *error) {
        if (error) {
            completion(error);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DownloadFailed"
                                                                object:self
                                                              userInfo:@{@"error": error}];
            return;
        }
        
        if (self.subEntry2) {
            [self.subEntry2 downloadWithCompletion:^(NSString *error) {
                if (error) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"DownloadFailed"
                                                                        object:self
                                                                      userInfo:@{@"error": error}];
                    return;
                }

                [[NSNotificationCenter defaultCenter] postNotificationName:@"DownloadSucceeded"
                                                                    object:self
                                                                  userInfo:nil];
            }];
            return;
        }
    
        completion(nil);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DownloadSucceeded"
                                                            object:self
                                                          userInfo:nil];            
    }];
}


- (void)watchSubEntry:(JNSTimelineSubEntry*)entry {
    // register notifications
}

- (void)updateFromJSON:(NSDictionary*)json {
    self.timestamp = [NSNumber numberWithLongLong:[[json objectForKey:@"time"] longLongValue]];
    self.expire = [NSNumber numberWithLongLong:[[json objectForKey:@"expire"] longLongValue]];
    self.solo = [[json objectForKey:@"solo"] boolValue];
    
    id entry1 = json[@"subentry1"];
    if (entry1) {
        NSAssert(!self.subEntry1,@"");
        self.subEntry1 = [[JNSTimelineSubEntry alloc] initWithJSON:entry1 Context:self.managedObjectContext];
    }
    
    id entry2 = json[@"subentry2"];
    if (entry2) {
        NSAssert(!self.subEntry2,@"");
        self.subEntry2 = [[JNSTimelineSubEntry alloc] initWithJSON:entry2 Context:self.managedObjectContext];
    }
}

@end
