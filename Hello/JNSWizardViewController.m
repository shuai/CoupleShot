//
//  JNSWizardViewController.m
//  Hello
//
//  Created by Shuai on 6/15/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import "JNSWizardViewController.h"

@implementation JNSWizardViewController

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.delegate wizardViewWillDisappear];
}

@end
