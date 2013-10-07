//
//  JNSWizardViewController.m
//  Hello
//
//  Created by Shuai on 6/15/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import "JNSWizardViewController.h"
#import "JNSPairViewController.h"
#import "JNSPairWaitingViewController.h"
#import "JNSConfig.h"

@interface JNSWizardViewController() {
}
@end

@implementation JNSWizardViewController

-(void)viewDidLoad {
    [self updateViewAnimated:NO];
    
    // Observer active user
    [[JNSConfig config] addObserver:self
                         forKeyPath:@"cachedUser" options:NSKeyValueObservingOptionNew context:nil];
    [self observeUser:[JNSUser activeUser]];   
}

-(void)dealloc {
    [[JNSConfig config] removeObserver:self forKeyPath:@"cachedUser"];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.delegate wizardViewWillDisappear];
}

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context {
    if (object == [JNSConfig config] && [keyPath compare:@"cachedUser"] == NSOrderedSame) {
        JNSUser* new = [change valueForKey:NSKeyValueChangeNewKey];
        if (new) {
            [self observeUser:new];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateViewAnimated:YES];
    });
}

-(void)pushPairViewAnimated:(BOOL)animated {
    UIViewController* pair_view = [[self storyboard] instantiateViewControllerWithIdentifier:@"pair_view"];
    [self pushViewController:pair_view animated:animated];
}

-(void)pushPairWaitingViewAnimated:(BOOL)animated  {
    UIViewController* view = [[self storyboard] instantiateViewControllerWithIdentifier:@"pair_waiting_view"];
    [self pushViewController:view animated:animated];

}

-(void)updateViewAnimated:(BOOL) animated {
    JNSUser* current_user = [JNSUser activeUser];
    
    if (current_user == nil) {
        [self popToRootViewControllerAnimated:YES];
    } else if (current_user.partner) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else if (current_user.request && !current_user.incoming) {
        if ([self.viewControllers count] == 1) {
            [self pushPairViewAnimated:animated];
        }
        
        if ([self.viewControllers count] == 2) {
            [self pushPairWaitingViewAnimated:animated];
        }
    } else {
        if ([self.viewControllers count] == 1) {
            [self pushPairViewAnimated:animated];
        } else if ([self.viewControllers count] == 3) {
            [self popViewControllerAnimated:animated];
        }
    }
}

-(void)observeUser:(JNSUser*)user {
    if (user) {
        [user addObserver:self forKeyPath:@"partner" options:0 context:nil];
        [user addObserver:self forKeyPath:@"request" options:0 context:nil];
        [user addObserver:self forKeyPath:@"incoming" options:0 context:nil];
        
    }
}

@end
