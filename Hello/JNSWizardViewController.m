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
    JNSPairViewController* _pair_view;
    JNSPairWaitingViewController* _waiting_view;
}
@end

@implementation JNSWizardViewController

-(void)viewDidLoad {
    _pair_view = [[self storyboard] instantiateViewControllerWithIdentifier:@"pair_view"];
    _waiting_view = [[self storyboard] instantiateViewControllerWithIdentifier:@"pair_waiting_view"];
    [self updateViewAnimated:NO];
    
    
    // Observer active user
    [[JNSConfig config] addObserver:self forKeyPath:@"cachedUser" options:0 context:nil];
    [self observeUser:[JNSUser activeUser]];   
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.delegate wizardViewWillDisappear];
}

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context {
    if (object == [JNSConfig config]) {
        [self observeUser:[JNSUser activeUser]];
    }
    [self updateViewAnimated:YES];
}

-(void)updateViewAnimated:(BOOL) animated {
    JNSUser* current_user = [JNSUser activeUser];
    
    if (current_user == nil) {
        NSLog(@"1");
        [self popToRootViewControllerAnimated:YES];
    } else if (current_user.partner) {
        NSLog(@"1");
        [self dismissViewControllerAnimated:YES completion:nil];
    } else if (current_user.request && !current_user.incoming) {
        if ([self.viewControllers count] == 1) {
            [self pushViewController:_pair_view animated:animated];
        }
        
        if ([self.viewControllers count] == 2) {
            [self pushViewController:_waiting_view animated:animated];
        }
    } else {
        if ([self.viewControllers count] == 1) {
            [self pushViewController:_pair_view animated:animated];
        } else if ([self.viewControllers count] == 3) {
            [self popViewControllerAnimated:animated];
        }
    }
}

-(void)observeUser:(JNSUser*)user {
    [user addObserver:self forKeyPath:@"partner" options:0 context:nil];
    [user addObserver:self forKeyPath:@"request" options:0 context:nil];
    [user addObserver:self forKeyPath:@"incoming" options:0 context:nil];
}

@end
