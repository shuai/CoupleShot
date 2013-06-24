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
#import "JNSConfig.h"
#import "JNSConnection.h"

@interface CLoginViewController () {
    JNSConnection* _connection;
}
@property (weak, nonatomic) IBOutlet UITextField *userField;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;
@property (weak, nonatomic) IBOutlet UIButton *signinButton;
@end


@implementation CLoginViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = true;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UINavigationController* container = (UINavigationController*)self.parentViewController;
    container.navigationBarHidden = true;
}

-(void)validationCompleteWithConnection:(JNSConnection*)connection
                               Response:(NSHTTPURLResponse*)response
                                   JSON:(NSDictionary*)json
                                  Error:(NSError*)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = false;
    
    if (json) {
        JNSUser* user = [JNSUser userWithID:self.userField.text
                                       JSON:json
                                     Context:[JNSConfig config].managedObjectContext];
        [[JNSConfig config] setCachedUser:user];

        if (user.partner) {
            [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
        } else if (user.request && !user.incoming) {
            JNSPairWaitingViewController* view = [self.storyboard instantiateViewControllerWithIdentifier:@"pair_waiting_view"];
            [self.navigationController pushViewController:view animated:true];
        } else {
            JNSPairViewController* view =
                [self.storyboard instantiateViewControllerWithIdentifier:@"pair_view"];

            [self.navigationController pushViewController:view animated:true];
        }
    } else {
        UIAlertView* view = [[UIAlertView alloc] initWithTitle:@"登录失败"
                                                       message:[error localizedFailureReason]
                                                      delegate:nil
                                             cancelButtonTitle:@"取消"
                                             otherButtonTitles:nil];
        [view show];
        self.view.userInteractionEnabled = true;
    }
}

// 
- (IBAction)buttonLoginTouched:(id)sender {
    if (self.userField.text.length == 0 ||
        self.pwdField.text.length == 0) {
        return;
    }
    
    self.view.userInteractionEnabled = false;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = true;
    
    NSString* body = [NSString stringWithFormat:@"user=%@&pwd=%@", self.userField.text, self.pwdField.text];
    _connection = [JNSConnection connectionWithMethod:false
                                                  URL:kSignInURL
                                               Params:body
                                           Completion:^(JNSConnection* connection, NSHTTPURLResponse *response, NSDictionary *json, NSError *error)
   {
       [self validationCompleteWithConnection:connection
                                     Response:response
                                         JSON:json
                                        Error:error];
   }];
}


@end
