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
#import "MBProgressHUD.h"
#import "JNSAPIClient.h"
#import "AFJSONRequestOperation.h"

@interface CLoginViewController () {
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
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = true;
    
    if ([self.segmentControl selectedSegmentIndex] == 0) {
        [self signup];
    } else {
        [self signin];
    }
}

- (void)signin {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"正在登陆..";
    
    NSMutableURLRequest* request = [[JNSAPIClient sharedClient] requestWithMethod:@"POST"
                                                                      path:kSignInURL
                                                                parameters:@{@"user": self.userField.text,
                                                                             @"pwd": self.pwdField.text}];
    [request setTimeoutInterval:10];

    AFJSONRequestOperation* operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        [hud hide:YES];
        [self createUserFromJSON:JSON LoadTimeline:YES];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        
        [hud hide:YES];
        UIAlertView* view = [[UIAlertView alloc] initWithTitle:@"登录失败"
                                                       message:[error localizedDescription]
                                                      delegate:nil
                                             cancelButtonTitle:@"取消"
                                             otherButtonTitles:nil];
        [view show];
    }];
    
    [[JNSAPIClient sharedClient] enqueueHTTPRequestOperation:operation];
}

- (void)signup {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"正在注册..";
    
    NSMutableURLRequest* request = [[JNSAPIClient sharedClient] requestWithMethod:@"POST"
                                                                             path:kSignUpURL
                                                                       parameters:@{@"user": self.userField.text,
                                                                                    @"pwd": self.pwdField.text}];
    [request setTimeoutInterval:10];
    AFJSONRequestOperation* operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        [hud hide:YES];
        [self createUserFromJSON:JSON LoadTimeline:NO];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        
        [hud hide:YES];
        UIAlertView* view = [[UIAlertView alloc] initWithTitle:@"注册失败"
                                                       message:[error localizedDescription]
                                                      delegate:nil
                                             cancelButtonTitle:@"取消"
                                             otherButtonTitles:nil];
        [view show];
    }];
    
    [[JNSAPIClient sharedClient] enqueueHTTPRequestOperation:operation];
}

- (void)createUserFromJSON:(NSDictionary*)json LoadTimeline:(BOOL)load {
    JNSUser* user = [JNSUser userWithID:self.userField.text
                                   JSON:json
                                Context:[JNSConfig config].managedObjectContext];
    if (load) {
        [user.timeline loadLatest];
    }
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
