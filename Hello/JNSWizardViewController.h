//
//  JNSWizardViewController.h
//  Hello
//
//  Created by Shuai on 6/15/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JNSUser.h"

@protocol JNSWizardViewDelegate <UINavigationControllerDelegate>

- (void)wizardViewWillDisappear;

@end

@interface JNSWizardViewController : UINavigationController

@property (nonatomic, weak) id<JNSWizardViewDelegate> delegate;

@end
