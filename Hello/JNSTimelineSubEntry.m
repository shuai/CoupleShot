//
//  JNSTimelineSubEntry.m
//  Hello
//
//  Created by Shuai on 7/21/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import "JNSTimelineSubEntry.h"
#import "JNSAPIClient.h"
#import "JNSConnection.h"
#import "AFImageRequestOperation.h"
#import "AFJSONRequestOperation.h"
#import "JNSConfig.h"

@interface JNSTimelineSubEntry(){
}

@property (readwrite) bool downloading;
@end


@implementation JNSTimelineSubEntry

@dynamic height;
@dynamic imageCacheURL;
@dynamic imageURL;
@dynamic width;

@synthesize downloading;

- (JNSTimelineSubEntry*)initWithContext:(NSManagedObjectContext*)context {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"JNSTimelineSubEntry"
                                              inManagedObjectContext:context];

    self = [super initWithEntity:entity insertIntoManagedObjectContext:context];
    if (self) {
        //
    }
    
    return self;
}

- (JNSTimelineSubEntry*)initWithImage:(UIImage*)image Context:(NSManagedObjectContext*)context {
    self = [self initWithContext:context];
    if (self) {
        self.width = [NSNumber numberWithFloat:image.size.width];
        self.height = [NSNumber numberWithFloat:image.size.height];
        self.imageCacheURL = [JNSTimelineSubEntry cacheImage:image];
    }
    return self;
}

- (JNSTimelineSubEntry*)initWithJSON:(NSDictionary*)json Context:(NSManagedObjectContext*)context {
    self = [self initWithContext:context];
    if (self) {
        id image = [json objectForKey:@"image"];
        self.width = [NSNumber numberWithInt:[[image objectForKey:@"width"] intValue]];
        self.height = [NSNumber numberWithInt:[[image objectForKey:@"height"] intValue]];
        self.imageURL = [image objectForKey:@"url"];
        
        NSAssert([self.width intValue] != 0, @"");
        NSAssert([self.height intValue] != 0, @"");
        NSAssert([self.imageURL length] != 0, @"");
    }
    return self;
}

- (bool)needDownload {
    return self.imageCacheURL == nil;
}

- (bool)needUpload {
    return self.imageURL == nil;
}

-(void) downloadWithCompletion:(void(^)(NSString* error))completion {
    NSAssert(self.needDownload, @"");
    NSAssert(!self.downloading, @"");
    
    NSURL* url = [NSURL URLWithString:self.imageURL relativeToURL: [NSURL URLWithString:kHost]];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    
    JNSAPIClient* client = [JNSAPIClient sharedClient];
    
    self.downloading = true;
        
    AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:request imageProcessingBlock:^UIImage *(UIImage *image_) {
        return image_;
    } success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image_) {
        self.downloading = false;
        self.imageCacheURL = [JNSTimelineSubEntry cacheImage:image_];
        completion(nil);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        self.downloading = false;
        completion([error localizedDescription]);
    }];
    
    // TODO progress
    
    // TODO handle over to load manager
    [client enqueueHTTPRequestOperation:operation];
}



+ (NSURL*)constructFileURL {
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

+ (NSString*)cacheImage:(UIImage*)image {
    // save file to cache folder TODO asynchronus? Maybe no need to convert to png
    NSURL* url = [self constructFileURL];
    NSFileManager* manager = [NSFileManager defaultManager];
    //NSAssert([manager fileExistsAtPath:[url path]] == false, @"");
    NSData* data = [NSData dataWithData:UIImagePNGRepresentation(image)];
    if ([manager createFileAtPath:[url path] contents:data attributes:nil]) {
        return [url path];
    } else {
        NSLog(@"Failed to save image");
        return nil;
    }
}

@end
