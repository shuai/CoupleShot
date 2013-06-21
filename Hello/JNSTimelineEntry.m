//
//  JNSTimelineEntry.m
//  Hello
//
//  Created by Shuai on 6/15/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import "JNSTimelineEntry.h"
#import "JNSConnection.h"

@interface JNSTimelineEntry(){
    NSString* _image_url;
    NSHTTPURLResponse* _response;
    NSURLConnection* _upload_connection;
    NSURLConnection* _download_connection;
    NSData* _download_cache;
}
@end

@implementation JNSTimelineEntry

-(JNSTimelineEntry*) initWithURL:(NSString*) url Delegate:(id<JNSTimelineEntryDelegate>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
        _image_url = url;
    }
    return self;
}

-(JNSTimelineEntry*) initWithImage:(UIImage*)image {
    self = [super init];
    if (self) {
//        _width = image.size.width;
//        _height = image.size.height;
        _image = image;
        _timestamp = 0; //TODO [NSDate date] ;
    }
    return self;
}

-(void) downloadContent {
    NSAssert(!_download_connection, @"");
    
    NSURL* url = [NSURL URLWithString:_image_url relativeToURL: [NSURL URLWithString:kHost]];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    _download_connection = [NSURLConnection connectionWithRequest:request delegate:self];
}

-(void) upload {
    NSAssert(!_upload_connection, @"");
    NSAssert(!_download_connection, @"");
            
    NSURL* url = [NSURL URLWithString:kPostURL
                        relativeToURL: [NSURL URLWithString:kHost]];
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

// NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [(NSMutableData*)_download_cache appendData:data];
    //NSLog(@"didReceiveData, length:%d", data.length);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSAssert(!_response, @"");
    NSAssert(!_download_cache, @"");
    
    if (connection == _download_connection) {
        
    } else if (connection == _upload_connection) {
    }
    
    _response = (NSHTTPURLResponse*)response;
    _download_cache = [NSMutableData new];
    
    //NSLog(@"didReceiveResponse, relativePath:%@, status:%d", _response.URL.relativePath, [_response statusCode]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"requestComplete:\n %d\n", _response.statusCode);
    
    if (_download_connection == connection) {
        NSAssert(!_image, @"");
        _image = [UIImage imageWithData:_download_cache];
        NSLog(@"Image downloaded. Width:%f Height%f",_image.size.width, _image.size.height);
        [_delegate downloadComplete:self];        
    } else {
        [_delegate uploadEntry:self Progress:100];
    }
    _download_connection = nil;
    _upload_connection = nil;
    _response = nil;
    _download_cache = nil;
}

@end
