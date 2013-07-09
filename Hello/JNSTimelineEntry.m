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

@interface JNSTimelineEntry(){
    NSHTTPURLResponse* _response;
    NSInteger _content_length;
    NSURLConnection* _upload_connection;
    NSURLConnection* _download_connection;
    NSData* _download_cache;    
    void(^_download_progress)(unsigned progress, NSString* error);
    void(^_upload_progress)(unsigned, NSString* error);
}
@end

@implementation JNSTimelineEntry

@dynamic timestamp;
@dynamic width;
@dynamic height;
@dynamic image_url;
@dynamic imageCacheURL;

@synthesize image = _image;

+(JNSTimelineEntry*)entryWithImage:(UIImage*)image Context:(NSManagedObjectContext*)context {
    JNSTimelineEntry* entry = [JNSTimelineEntry entryWithContext:context];
    entry.image = image;
    entry.width = [NSNumber numberWithFloat: image.size.width];
    entry.height = [NSNumber numberWithFloat: image.size.height];
    [entry cacheImage];
    
    // TODO timestamp?
    return entry;
}

+(JNSTimelineEntry*)entryWithJSON:(NSDictionary*)json Context:(NSManagedObjectContext*)context {
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
        _image = [UIImage imageWithContentsOfFile:self.imageCacheURL];
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

-(bool) downloading {
    return _download_connection != nil;
}

-(bool) uploading {
    return _upload_connection != nil;
}

// Downloading

-(void) downloadContentProgress:(void(^)(unsigned progress, NSString* error))block {
    NSAssert(!_download_connection, @"");
    NSAssert(!_download_progress, @"");
    
    _download_progress = block;
    
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
    
    NSData* data = [NSData dataWithData:UIImagePNGRepresentation(_image)];
    [postbody appendData:data];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:postbody];
    
    _upload_connection = [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)trackUploadProgress:(void(^)(unsigned, NSString* error))block {
    _upload_progress = block;
}

- (void)cacheImage {
    NSAssert(!self.imageCacheURL, @"");
    NSAssert(self.image, @"");
    
    // save file to cache folder TODO asynchronus? Maybe no need to convert to png
    NSURL* url = [self constructFileURL];
    NSFileManager* manager = [NSFileManager defaultManager];
    //NSAssert([manager fileExistsAtPath:[url path]] == false, @"");
    NSData* data = [NSData dataWithData:UIImagePNGRepresentation(_image)];
    if ([manager createFileAtPath:[url path] contents:data attributes:nil]) {
        self.imageCacheURL = [url path];
    } else {
        NSLog(@"Failed to save image");
    }
}

// NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [(NSMutableData*)_download_cache appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSAssert(!_response, @"");
    NSAssert(!_download_cache, @"");

    _response = (NSHTTPURLResponse*)response;
    _content_length = [[_response.allHeaderFields valueForKey:@"Content-Length"] integerValue];
    _download_cache = [NSMutableData new];
    
    //NSLog(@"didReceiveResponse, relativePath:%@, status:%d", _response.URL.relativePath, [_response statusCode]);
}

- (void)connection:(NSURLConnection *)connection
   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    // Remember this function is called for every connection
    
    if (_upload_progress) {
        unsigned ratio = totalBytesWritten*100/totalBytesExpectedToWrite;
        if (ratio > 99) {
            ratio = 99;
        }
        _upload_progress(ratio, nil);
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"requestComplete:\n %d\n", _response.statusCode);

    // TODO better error handling
    if (_download_connection == connection) {
        if (_response.statusCode == 200) {
            NSAssert(!_image, @"");
            _image = [UIImage imageWithData:_download_cache];
            NSLog(@"Image downloaded. Width:%f Height%f",_image.size.width, _image.size.height);
            
            [self updateProgress];
            [self cacheImage];
        } else {
            _download_progress(0, @"下载失败");
        }
    } else if (_upload_connection == connection) {
        // Update meta info
        NSError* error;
        NSDictionary* obj = [NSJSONSerialization JSONObjectWithData:_download_cache
                                                            options:kNilOptions
                                                              error:&error];
        if (error) {
            if (_upload_progress) {
                _upload_progress(0, [error localizedFailureReason]);
            }
        } else {
            NSDictionary* json = [obj objectForKey:@"content"];
            [self updateMeta:json];
            if (_upload_progress) {
                _upload_progress(100, nil);
            }
        }
    }
    [self clear];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (_download_connection == connection) {
        NSAssert(!_image, @"");
        _download_progress(0, [error localizedFailureReason]);
    } else if (_upload_connection == connection) {
        if (_upload_progress) {
            _upload_progress(0, [error localizedFailureReason]);
        }
    }
    [self clear];
}

- (void)clear {
    _download_connection = nil;
    _upload_connection = nil;
    _response = nil;
    _download_cache = nil;
    _download_progress = nil;
    _upload_progress = nil;
    _content_length = 0;
}

- (void)updateProgress {
    if (_content_length != 0) {
        if (_download_progress) {
            unsigned ratio = [_download_cache length]*100/_content_length;
            _download_progress(ratio, nil);
        }
    }
}

- (void)updateMeta:(NSDictionary*)json {
    self.timestamp = [NSNumber numberWithLongLong:[[json objectForKey:@"time"] longLongValue]];
    self.width = [NSNumber numberWithInt:[[json objectForKey:@"width"] intValue]];
    self.height = [NSNumber numberWithInt:[[json objectForKey:@"height"] intValue]];
    self.image_url = [json objectForKey:@"url"];    
}

@end
