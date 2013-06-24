//
//  JNSTimelineEntry.m
//  Hello
//
//  Created by Shuai on 6/23/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import "JNSTimelineEntry.h"
#import "JNSConnection.h"

@interface JNSTimelineEntry(){
    NSHTTPURLResponse* _response;
    NSURLConnection* _upload_connection;
    NSURLConnection* _download_connection;
    void(^_download_completion)(JNSTimelineEntry*, NSString* error);
    void(^_upload_progress)(unsigned, NSString* error);
    NSData* _download_cache;
}
@end

@implementation JNSTimelineEntry

@dynamic timestamp;
@dynamic width;
@dynamic height;
@dynamic image_url;
@synthesize image = _image;

+(JNSTimelineEntry*)entryWithImage:(UIImage*)image Context:(NSManagedObjectContext*)context {
    JNSTimelineEntry* entry = [JNSTimelineEntry entryWithContext:context];
    entry.image = image;
    entry.width = [NSNumber numberWithFloat: image.size.width];
    entry.height = [NSNumber numberWithFloat: image.size.height];
    // TODO timestamp?
    return entry;
}

+(JNSTimelineEntry*)entryWithJSON:(NSDictionary*)json Context:(NSManagedObjectContext*)context {
    JNSTimelineEntry* entry = [JNSTimelineEntry entryWithContext:context];
    entry.timestamp = [NSDate dateWithTimeIntervalSince1970:[[json objectForKey:@"time"] doubleValue]/1000];
    entry.width = [NSNumber numberWithInt:[[json objectForKey:@"width"] intValue]];
    entry.height = [NSNumber numberWithInt:[[json objectForKey:@"height"] intValue]];
    entry.image_url = [json objectForKey:@"url"];
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
    NSURL* url = [self constructFileURL];
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:[url path]]) {
        _image = [UIImage imageWithContentsOfFile:[url path]];
    }
}

-(NSURL*) constructFileURL {
    NSFileManager* manager = [NSFileManager defaultManager];
    NSURL* directory = [[manager URLsForDirectory:NSCachesDirectory
                                                               inDomains:NSUserDomainMask] lastObject];
    NSURL* image_dir = [directory URLByAppendingPathComponent:@"images" isDirectory:YES];
    if (![manager fileExistsAtPath:[image_dir path]]) {
        [manager createDirectoryAtURL:image_dir
          withIntermediateDirectories:NO
                           attributes:nil
                                error:nil];
    }
    
    return [image_dir URLByAppendingPathComponent:
            [NSString stringWithFormat:@"%ld", (long)[self.timestamp timeIntervalSince1970]]];
}

-(bool) downloading {
    return _download_connection != nil;
}

-(bool) uploading {
    return _upload_connection != nil;
}

// Downloading

-(void) downloadContentCompletion:(void(^)(JNSTimelineEntry*, NSString* error))completion {
    NSAssert(!_download_connection, @"");
    NSAssert(!_download_completion, @"");
    
    _download_completion = completion;
    
    NSURL* url = [NSURL URLWithString:self.image_url relativeToURL: [NSURL URLWithString:kHost]];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    _download_connection = [NSURLConnection connectionWithRequest:request delegate:self];
}

-(void) upload {
    NSAssert(!_upload_connection, @"");
    NSAssert(!_download_connection, @"");

    NSString* url_str = [NSString stringWithFormat:@"%@?width=%d&height=%d",
                         kPostURL, (int)_image.size.width, (int)_image.size.height];
    NSURL* url = [NSURL URLWithString:url_str
                        relativeToURL:[NSURL URLWithString:kHost]];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    NSMutableData *postbody = [NSMutableData data];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[@"Content-Disposition: form-data; name=\"image\"; filename=\"1.png\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[NSData dataWithData:UIImagePNGRepresentation(_image)]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:postbody];
    
    _upload_connection = [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)trackUploadProgress:(void(^)(unsigned, NSString* error))block {
    _upload_progress = block;
}

// NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [(NSMutableData*)_download_cache appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSAssert(!_response, @"");
    NSAssert(!_download_cache, @"");

    _response = (NSHTTPURLResponse*)response;
    _download_cache = [NSMutableData new];
    
    //NSLog(@"didReceiveResponse, relativePath:%@, status:%d", _response.URL.relativePath, [_response statusCode]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"requestComplete:\n %d\n", _response.statusCode);

    // TODO better error handling
    if (_download_connection == connection) {
        if (_response.statusCode == 200) {
            NSAssert(!_image, @"");
            _image = [UIImage imageWithData:_download_cache];
            NSLog(@"Image downloaded. Width:%f Height%f",_image.size.width, _image.size.height);
            _download_completion(self, nil);
            
            // save file to cache folder TODO asynchronus? Maybe no need to convert to png
            NSURL* url = [self constructFileURL];
            NSFileManager* manager = [NSFileManager defaultManager];
            //NSAssert([manager fileExistsAtPath:[url path]] == false, @"");
            NSData* data = [NSData dataWithData:UIImagePNGRepresentation(_image)];
            if (![manager createFileAtPath:[url path] contents:data attributes:nil]) {
                NSLog(@"Failed to save image");
            }
        } else {
            _download_completion(self, @"下载失败");
        }
    } else if (_upload_connection == connection) {
        _upload_progress(100, nil);
    }
    [self clear];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (_download_connection == connection) {
        NSAssert(!_image, @"");
        _download_completion(self, [error localizedFailureReason]);
    } else if (_upload_connection == connection) {
        _upload_progress(0, [error localizedFailureReason]);
    }
    [self clear];
}

- (void)clear {
    _download_connection = nil;
    _upload_connection = nil;
    _response = nil;
    _download_cache = nil;
    _download_completion = nil;
    _upload_progress = nil;
}

@end
