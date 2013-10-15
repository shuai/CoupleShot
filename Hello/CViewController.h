//
//  CViewController.h
//  Hello
//
//  Created by Shuai on 5/20/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JNSUser.h"
#import "JNSWizardViewController.h"

@interface CViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,  UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIToolbarDelegate,
    JNSTimelineDelegate>

@end
