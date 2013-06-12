//
//  CLoginViewController.m
//  Hello
//
//  Created by Shuai on 6/11/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import "CLoginViewController.h"
#import "CViewController.h"
#import "JNSPairViewController.h"
#import "JNSPairWaitingViewController.h"

@interface CLoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userField;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;
@property (weak, nonatomic) IBOutlet UIButton *signinButton;
@end


@implementation CLoginViewController

JNSUser* user;

-(void)validationComplete {

    if (user.valid) {
        if (user.partner_id) {
            CViewController* main = [self.storyboard instantiateViewControllerWithIdentifier:@"main_view"];
            [self presentViewController:main animated:true completion:nil];
        } else if (user.request) {
            if (user.incoming) {
                
            } else {
                JNSPairWaitingViewController* view = [self.storyboard instantiateViewControllerWithIdentifier:@"pair_waiting_view"];
                
                view.user = user;
                [self presentViewController:view animated:true completion:nil];
            }
        } else {
            JNSPairViewController* view = [self.storyboard instantiateViewControllerWithIdentifier:@"pair_view"];
            view.user = user;
            [self presentViewController:view animated:true completion:nil];
        }
        // TODO how to delete current one?
    } else {
        [self.userField setEnabled:true];
        [self.pwdField setEnabled:true];
        [self.signinButton setEnabled:true];
        [self.signinButton setTitle:@"登录" forState:UIControlStateNormal];
    }
}

// 
- (IBAction)buttonLoginTouched:(id)sender {
    if (self.userField.text.length == 0 ||
        self.pwdField.text.length == 0) {
        return;
    }
    
    [self.userField setEnabled:false];
    [self.pwdField setEnabled:false];
    [self.signinButton setEnabled:false];

    user = [JNSUser userWithID:self.userField.text Password:self.pwdField.text Delegate:self];
}


@end
