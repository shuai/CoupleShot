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
#import "JNSPairConfirmViewController.h"

@interface CLoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userField;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;
@property (weak, nonatomic) IBOutlet UIButton *signinButton;
@end


@implementation CLoginViewController

JNSUser* user;

-(void)viewDidLoad {
    self.navigationItem.hidesBackButton = true;
}

-(void)viewWillAppear:(BOOL)animated {
    UINavigationController* container = (UINavigationController*)self.parentViewController;
    container.navigationBarHidden = true;
}

-(void)validationComplete {

    if (user.valid) {
        NSAssert(!current_user, @"");
        current_user = user;

        if (user.partner_id) {
            [self dismissViewControllerAnimated:true completion:nil];
        } else if (user.request) {
            if (user.incoming) {
                JNSPairConfirmViewController* view = [self.storyboard instantiateViewControllerWithIdentifier:@"pair_confirm_view"];
                view.user = user;
                [self presentViewController:view animated:true completion:nil];
            } else {
                JNSPairWaitingViewController* view = [self.storyboard instantiateViewControllerWithIdentifier:@"pair_waiting_view"];
                
                view.user = user;
                [self presentViewController:view animated:true completion:nil];
            }
        } else {
            JNSPairViewController* view = [self.storyboard instantiateViewControllerWithIdentifier:@"pair_view"];

            [self.navigationController pushViewController:view animated:true];
            
            //[self presentViewController:view animated:true completion:nil];
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
