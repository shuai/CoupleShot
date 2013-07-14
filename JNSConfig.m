//
//  JNSConfig.m
//  Hello
//
//  Created by Shuai on 6/22/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import "JNSConfig.h"

JNSConfig* _config;

@implementation JNSConfig

@dynamic cachedUser;
@dynamic nextImageID;
@dynamic tokenSent;

@synthesize deviceToken = _deviceToken;


- (id)initWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context {
    self = [super initWithEntity:entity insertIntoManagedObjectContext:context];
    if (self) {
        [self addObserver:self forKeyPath:@"cachedUser" options:(NSKeyValueObservingOptionNew) context:nil];
    }
    return self;
}

- (void)awakeFromFetch {
    [self addObserver:self forKeyPath:@"cachedUser" options:(NSKeyValueObservingOptionNew) context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath compare:@"cachedUser"] == NSOrderedSame) {
        if (self.deviceToken) {
            JNSUser* user = [change valueForKey:NSKeyValueChangeNewKey];
            [user syncDeviceToken:self.deviceToken];
        }
    }
}

- (void)setDeviceToken:(NSData *)deviceToken {
    NSAssert(_deviceToken == nil && deviceToken, @"");
    _deviceToken = deviceToken;
    if (self.cachedUser) {
        [self.cachedUser syncDeviceToken:deviceToken];
    }
}

+ (NSNumber*)uniqueImageID {
    NSNumber* number = [NSNumber numberWithInt:[JNSConfig config].nextImageID.intValue + 1];
    [JNSConfig config].nextImageID = number;
    return number;
}

+(void)setConfig:(JNSConfig*)config {
    NSAssert(!_config, @"");
    _config = config;
}

+(JNSConfig*)config {
    return _config;
}


@end
