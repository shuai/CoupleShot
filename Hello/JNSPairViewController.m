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
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@end

@implementation JNSPairViewController

- (void)viewDidLoad {
    [self.indicator setHidden:true];
    self.navigationItem.title = @"找到Ta";

    [self alertRequest];    
}

-(void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = false;
}

- (IBAction)buttonTouched:(id)sender {
    if (self.userField.hasText) {
        [self.button setHidden:true];
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
                [self.errorLabel setText:msg];
                [self.button setHidden:false];
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