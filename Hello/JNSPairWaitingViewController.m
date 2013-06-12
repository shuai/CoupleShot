//
//  JNSPairWaitingViewController.m
//  Hello
//
//  Created by Shuai on 6/12/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import "JNSPairWaitingViewController.h"

@interface JNSPairWaitingViewController()
@property (weak, nonatomic) IBOutlet UILabel *label;

@end


@implementation JNSPairWaitingViewController

-(void)viewDidLoad {
    [self.label setText: [NSString stringWithFormat:@"请等待Ta(%@)得回应", self.user.request]];
}

@end
