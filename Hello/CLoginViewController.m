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
@property (weak, nonatomic) IBOutlet UIBarButtonItem *startButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UIView *formView;

@end


@implementation CLoginViewController

- (IBAction)segmentsChanged:(id)sender {
    UISegmentedControl* control = sender;
    if (0 == [control selectedSegmentIndex]) {
        self.startButton.title = @"Start";
    } else {
        self.startButton.title = @"Sign in";
    }
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = true;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:true animated:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:false animated:animated];
}

// 
- (IBAction)start:(id)sender {
    if (self.userField.text.length == 0 ||
        self.pwdField.text.length == 0) {
        return;
    }
    
    self.view.userInteractionEnabled = false;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = true;
    
    if ([self.segmentControl selectedSegmentIndex] == 0) {
        [self signup];
    } else {
        [self signin];
    }
}

- (void)signin {
    NSString* url = [NSString stringWithFormat:@"%@?user=%@&pwd=%@", kSignInURL, self.userField.text, self.pwdField.text];
    _connection = [JNSConnection connectionWithMethod:false
                                                  URL:url
                                               Params:nil
                                           Completion:^(JNSConnection* connection, NSHTTPURLResponse *response, NSDictionary *json, NSError *error)
   {
       [UIApplication sharedApplication].networkActivityIndicatorVisible = false;
       self.view.userInteractionEnabled = true;
       
       if (json) {
           [self succeeded:json];
       } else {
           UIAlertView* view = [[UIAlertView alloc] initWithTitle:@"登录失败"
                                                          message:[error localizedDescription]
                                                         delegate:nil
                                                cancelButtonTitle:@"取消"
                                                otherButtonTitles:nil];
           [view show];
       }
   }];
    
}

- (void)signup {
    NSString* url = [NSString stringWithFormat:@"%@?user=%@&pwd=%@", kSignUpURL, self.userField.text, self.pwdField.text];
    _connection = [JNSConnection connectionWithMethod:false
                                                  URL:url
                                               Params:nil
                                           Completion:^(JNSConnection* connection, NSHTTPURLResponse *response, NSDictionary *json, NSError *error)
   {
       [UIApplication sharedApplication].networkActivityIndicatorVisible = false;
       self.view.userInteractionEnabled = true;
       
       if (json) {
           [self succeeded:json];
       } else {
           UIAlertView* view = [[UIAlertView alloc] initWithTitle:@"注册失败"
                                                          message:[error localizedDescription]
                                                         delegate:nil
                                                cancelButtonTitle:@"取消"
                                                otherButtonTitles:nil];
           [view show];
           self.view.userInteractionEnabled = true;           
       }
   }];
    
}

- (void)succeeded:(NSDictionary*)json {
    JNSUser* user = [JNSUser userWithID:self.userField.text
                                   JSON:json
                                Context:[JNSConfig config].managedObjectContext];
    [[JNSConfig config] setCachedUser:user];
}

// UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (self.userField.text.length == 0 ||
        self.pwdField.text.length == 0) {
        return NO;
    }
    
    [textField resignFirstResponder];
    [self start:nil];
    return YES;
}

@end
