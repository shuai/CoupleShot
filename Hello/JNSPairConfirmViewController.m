//
//  JNSPairConfirmViewController.m
//  Hello
//
//  Created by Shuai on 6/12/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import "JNSPairConfirmViewController.h"
#import "CViewController.h"
#import "JNSPairViewController.h"
#import "JNSPairWaitingViewController.h"

@interface JNSPairConfirmViewController()
@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation JNSPairConfirmViewController

-(void)viewDidLoad {
    [self.label setText:[NSString stringWithFormat:@"%@ 希望和你分享", self.user.email]];
}

- (IBAction)ignoreButtonTouched:(id)sender {
    [self confirmRequest:true];
}

- (IBAction)confirmButtonTouched:(id)sender {
    [self confirmRequest:false];
}


-(void)confirmRequest:(bool)confirm {
    [self.user confirmRequest:confirm Completion:^(NSString* msg){
        // TODO show error msg somewhere
        
        if (self.user.partner) {
            CViewController* main = [self.storyboard instantiateViewControllerWithIdentifier:@"main_view"];
            [self presentViewController:main animated:true completion:nil];
        } else if (self.user.request) {
            if (self.user.incoming) {
                [self.label setText:[NSString stringWithFormat:@"%@ 希望和你分享", self.user.email]];
            } else {
                JNSPairWaitingViewController* view =
                    [self.storyboard instantiateViewControllerWithIdentifier:@"pair_waiting_view"];
                view.user = self.user;
                [self presentViewController:view animated:true completion:nil];
            }
        } else {
            JNSPairViewController* view = [self.storyboard instantiateViewControllerWithIdentifier:@"pair_view"];
            [self presentViewController:view animated:true completion:nil];
        }
        
        if (msg) {
            UIAlertView* view = [[UIAlertView alloc] initWithTitle:@"错误" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [view show];
        }
    }];
}
@end
