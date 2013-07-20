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

@property (readwrite) UIImage* image;
@property (readwrite) bool downloading;
@property (readwrite) bool uploading;
@end

@implementation JNSTimelineEntry

@dynamic timestamp;
@dynamic width;
@dynamic height;
@dynamic imageURL;
@dynamic imageCacheURL;

@synthesize image, uploading, downloading;

+(JNSTimelineEntry*)entryWithImage:(UIImage*)image
                           Context:(NSManagedObjectContext*)context {
    JNSTimelineEntry* entry = [JNSTimelineEntry entryWithContext:context];
    entry.image = image;
    entry.width = [NSNumber numberWithFloat: image.size.width];
    entry.height = [NSNumber numberWithFloat: image.size.height];
    [entry cacheImage];
    // TODO timestamp?
    return entry;
}

+(JNSTimelineEntry*)entryWithJSON:(NSDictionary*)json
                          Context:(NSManagedObjectContext*)context {
    JNSTimelineEntry* entry = [JNSTimelineEntry entryWithContext:context];    
    [entry updateMeta:json];
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
    // TODO load image from disk cache
    if (self.imageCacheURL) {
        self.image = [UIImage imageWithContentsOfFile:self.imageCacheURL];
    }
}

-(NSURL*) constructFileURL {
    NSFileManager* manager = [NSFileManager defaultManager];
    NSURL* directory = [[manager URLsForDirectory:NSCachesDirectory
                                        inDomains:NSUserDomainMask] lastObject];
    NSURL* image_dir = [directory URLByAppendingPathComponent:@"images"
                                                  isDirectory:YES];
    if (![manager fileExistsAtPath:[image_dir path]]) {
        [manager createDirectoryAtURL:image_dir
          withIntermediateDirectories:NO
                           attributes:nil
                                error:nil];
    }
    
    return [image_dir URLByAppendingPathComponent:
            [NSString stringWithFormat:@"%@", [JNSConfig uniqueImageID]]];
}

-(bool) needUpload {
    return self.imageURL == nil;
}

-(bool) needDownload {
    return self.imageCacheURL == nil;
}

// Downloading

-(void) downloadWithCompletion:(void(^)(NSString* error))completion {
    NSAssert(self.needDownload, @"");
    NSAssert(!self.downloading, @"");
    
    NSURL* url = [NSURL URLWithString:self.imageURL relativeToURL: [NSURL URLWithString:kHost]];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    
    JNSAPIClient* client = [JNSAPIClient sharedClient];

    self.downloading = true;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DownloadStarted"
                                                        object:self
                                                      userInfo:nil];

    AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:request imageProcessingBlock:^UIImage *(UIImage *image_) {
        return image_;
    } success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image_) {
        self.downloading = false;
        self.image = image_;
        [self cacheImage];
        completion(nil);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DownloadSucceeded"
                                                            object:self
                                                          userInfo:nil];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DownloadFailed"
                                                            object:self
                                                          userInfo:@{@"error": error}];
    }];
    
    // TODO progress
    
    // TODO handle over to load manager
    [client enqueueHTTPRequestOperation:operation];
}

-(void) uploadWithCompletion:(void(^)(NSString* error))completion {
    NSAssert(!self.uploading, @"");
    NSAssert(self.needUpload, @"");

    self.uploading = YES;

    NSDictionary* params = @{@"width": [NSNumber numberWithInt:(int)self.image.size.width],
                             @"height":[NSNumber numberWithInt:(int)self.image.size.height]};
    
    JNSAPIClient* client = [JNSAPIClient sharedClient];
    // TODO read file
    NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(self.image)];
    NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST"
                                                                  path:kPostURL
                                                            parameters:params
                                             constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"image" fileName:@"image.png" mimeType:@"image/png"];
    }];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadStarted"
                                                        object:self
                                                      userInfo:nil];

    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        self.uploading = NO;
        
        [self updateMeta:[JSON objectForKey:@"content"]];
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
}

- (void)cacheImage {
    NSAssert(!self.imageCacheURL, @"");
    NSAssert(self.image, @"");
    
    // save file to cache folder TODO asynchronus? Maybe no need to convert to png
    NSURL* url = [self constructFileURL];
    NSFileManager* manager = [NSFileManager defaultManager];
    //NSAssert([manager fileExistsAtPath:[url path]] == false, @"");
    NSData* data = [NSData dataWithData:UIImagePNGRepresentation(self.image)];
    if ([manager createFileAtPath:[url path] contents:data attributes:nil]) {
        self.imageCacheURL = [url path];
    } else {
        NSLog(@"Failed to save image");
    }
}

- (void)updateMeta:(NSDictionary*)json {
    self.timestamp = [NSNumber numberWithLongLong:[[json objectForKey:@"time"] longLongValue]];
    self.width = [NSNumber numberWithInt:[[json objectForKey:@"width"] intValue]];
    self.height = [NSNumber numberWithInt:[[json objectForKey:@"height"] intValue]];
    self.imageURL = [json objectForKey:@"url"];    
}

@end
