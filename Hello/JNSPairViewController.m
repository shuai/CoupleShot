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
                CViewController* main = [self.storyboard instantiateViewControllerWithIdentifier:@"main_view"];
                [self presentViewController:main animated:true completion:nil];
            } else if (current_user.request) {
                if (current_user.incoming) {
                    
                } else {
                    JNSPairWaitingViewController* view = [self.storyboard instantiateViewControllerWithIdentifier:@"pair_waiting_view"];
                    
                    [self presentViewController:view animated:true completion:nil];
                }
            } else {
                [self.errorLabel setText:msg];
                [self.button setHidden:false];
                [self.indicator setHidden:true];
            }
        }];
    }
}

@end