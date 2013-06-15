//
//  CViewController.m
//  Hello
//
//  Created by Shuai on 5/20/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import "CViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "JNSWizardViewController.h"
#import "JNSUser.h"

@interface CViewController ()
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)buttonTouched:(id)sender;
@end

@implementation CViewController
NSMutableArray* dataArray;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.view bringSubviewToFront:(self.addButton)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    dataArray = [NSMutableArray new];
}

- (void)viewDidAppear:(BOOL)animated {
    if (!current_user || !current_user.partner_id) {
        JNSWizardViewController* wizard = [[self storyboard] instantiateViewControllerWithIdentifier:@"wizard_view"];
        [self presentViewController:wizard animated:false completion:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonTouched:(id)sender {
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        return;
    }

    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = false;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    //[picker setSourceType:UIImagePickerControllerSourceTypeCamera];
    [self presentViewController:picker animated:true completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"template"];
    int c = indexPath.row;
    UIImage* image = dataArray[c];
    UIImageView* view = (UIImageView*)[cell viewWithTag:0];
    [view setImage:image];
    return cell;
}


// ---

- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

// For responding to the user accepting a newly-captured picture or movie
- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    if ([mediaType compare:(NSString*)kUTTypeImage] == NSOrderedSame) {
        UIImage* image = [info objectForKey: UIImagePickerControllerEditedImage];
        if (image == nil)
            image = [info objectForKey: UIImagePickerControllerOriginalImage];
        
        [dataArray addObject: image];
        [self.tableView insertRowsAtIndexPaths:
                            [NSArray arrayWithObject:
                                [NSIndexPath indexPathForRow: [dataArray count]-1
                                                   inSection:0]]
                        withRowAnimation:UITableViewRowAnimationFade];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
