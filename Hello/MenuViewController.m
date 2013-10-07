//
//  MenuViewController.m
//  Hello
//
//  Created by Shuai on 9/30/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import "MenuViewController.h"
#import "IIViewDeckController.h"
#import "JNSConfig.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 2) {
        // sign out
        [JNSUser signOut];
        
        [self.viewDeckController closeLeftViewAnimated:YES];
//        [self.viewDeckController closeLeftViewBouncing:^(IIViewDeckController *controller) {
//            if ([controller.centerController isKindOfClass:[UINavigationController class]]) {
//                UITableViewController* cc = (UITableViewController*)((UINavigationController*)controller.centerController).topViewController;
//                cc.navigationItem.title = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
//                if ([cc respondsToSelector:@selector(tableView)]) {
//                    [cc.tableView deselectRowAtIndexPath:[cc.tableView indexPathForSelectedRow] animated:NO];
//                }
//            }
////            [NSThread sleepForTimeInterval:(300+arc4random()%700)/1000000.0]; // mimic delay... not really necessary
//        }];
    }
}

@end
