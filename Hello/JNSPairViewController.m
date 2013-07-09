//
//  JNSPairViewController.m
//  Hello
//
//  Created by Shuai on 6/12/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import "JNSPairViewController.h"
#import "JNSPairWaitingViewController.h"
#import "CViewController.h"

@interface JNSPairViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@end

@implementation JNSPairViewController

- (void)viewDidLoad {
    [self.indicator setHidden:true];
    [self alertRequest];
    UIBarButtonItem* right = [[UIBarButtonItem alloc] initWithTitle:@"发送请求"
                                                              style:UIBarButtonItemStyleDone
                                                             target:self
                                                             action:@selector(sendButtonTouched:)];
    self.navigationItem.rightBarButtonItem = right;
}

-(void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:false animated:animated];
}

- (void)sendButtonTouched:(id)sender {
    if (self.userField.hasText) {
        [self.indicator setHidden:false];
        [self.indicator startAnimating];

        JNSUser* current_user = [JNSUser activeUser];
        
        [current_user pairWithUser:self.userField.text Completion:^(NSString* msg){
            if (current_user.partner) {
                [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
            } else if (current_user.request) {
                if (current_user.incoming) {
                    [self alertRequest];
                } else {
                    JNSPairWaitingViewController* view = [self.storyboard instantiateViewControllerWithIdentifier:@"pair_waiting_view"];
                    
                    [self.navigationController pushViewController:view animated:YES];
                }
            } else {
                UIAlertView* view = [[UIAlertView alloc] initWithTitle:@"请求失败"
                                                               message:msg
                                                              delegate:nil
                                                     cancelButtonTitle:@"确定"
                                                     otherButtonTitles:nil];
                [view show];
                [self.indicator setHidden:true];
            }
        }];
    }
}

- (void)alertRequest {
    JNSUser* current_user = [JNSUser activeUser];

    if (current_user.request && current_user.incoming) {
        UIAlertView* view = [[UIAlertView alloc] initWithTitle:@"通知"
                                                       message:[NSString stringWithFormat:@"%@ 请求和您分享", current_user.request]
                                                      delegate:self
                                             cancelButtonTitle:@"取消"
                                             otherButtonTitles:@"接受请求", nil];
        [view show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    bool accept = buttonIndex == 1;
    [[JNSUser activeUser] confirmRequest:accept Completion:^(NSString* msg) {
        if (msg) {
            //
        } else {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

@end