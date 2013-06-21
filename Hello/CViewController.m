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

const int kContentMargin = 5;


@interface CViewController () {
}
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)buttonTouched:(id)sender;
@end

@implementation CViewController

JNSUser* _user;

// JNSTimelineDelegate
-(void) loadFromCacheComplte {
    
}

-(void) pullComplte:(int)count WithError:(NSString *)error {
    if (error) {
        UIAlertView* view = [[UIAlertView alloc] initWithTitle:@"加载错误" message:error delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [view show];
    } else {
        NSMutableArray* array = [NSMutableArray new];
        for (int i=0; i<count; i++) {
            [array addObject:[NSIndexPath indexPathForRow: [current_user.timeline count]-i-1 inSection:0]];
        }
        
        [self.tableView insertRowsAtIndexPaths:array
                              withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(void) entryWithIndex:(int)index LoadedWithError:(NSString*)err {
    NSLog(@"reloadRowsAtIndexPaths %d", index);
    
    [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]]
                      withRowAnimation:UITableViewRowAnimationFade];
}


// user


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.view bringSubviewToFront:(self.addButton)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)viewDidAppear:(BOOL)animated {
    if (!current_user || !current_user.partner_id) {
        JNSWizardViewController* wizard = [[self storyboard] instantiateViewControllerWithIdentifier:@"wizard_view"];
        [self presentViewController:wizard animated:false completion:nil];
    } else if (!_user) {
        _user = current_user;
        _user.delegate = self;
        _user.timeline.delegate = self;
        [_user.timeline loadLatest];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonTouched:(id)sender {
    
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = false;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    
    [self presentViewController:picker animated:true completion:nil];
}

// UITableView delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSAssert(section == 0, @"");
    //NSLog(@"Number of rows in section %d: %d", section, [current_user.timeline count]);
    return [current_user.timeline count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    JNSTimelineEntry* entry = _user.timeline.array[indexPath.row];
    int height = 0;
    
    if (entry.image) {
        int width = 320-kContentMargin*2;
        height = entry.image.size.height*width/entry.image.size.width + kContentMargin - 2; // border
    }
    //NSLog(@"heightForRowAtIndexPath %d: %d", indexPath.row, height);
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JNSTimelineEntry* entry = _user.timeline.array[indexPath.row];
    
    UITableViewCell *cell = [UITableViewCell new];
    
    if (entry.image) {
        UIImageView* image_view = [[UIImageView alloc] initWithImage:entry.image];
        
        int width = 320-kContentMargin*2;
        int height = entry.image.size.height*width/entry.image.size.width;
        
        image_view.frame = CGRectMake(kContentMargin, kContentMargin, width, height);
        [[cell contentView] addSubview:image_view];
        
        // slow
        CALayer* layer = image_view.layer;
        layer.cornerRadius = 5;
        layer.borderColor = [[UIColor whiteColor] CGColor];
        layer.borderWidth = 1;
        layer.masksToBounds = true;
        
        //        layer.shadowColor = [UIColor blackColor].CGColor;
        //        layer.shadowOpacity = 0.5;
        //        layer.shadowRadius = 10;
        //        layer.shadowOffset = CGSizeMake(3, 3);
    } else {
        // TODO
    }
    
    
    return cell;
}


// UIImagePickerControllerDelegate

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
        
        JNSTimelineEntry* entry = [[JNSTimelineEntry alloc] initWithImage:image];
        [current_user.timeline addEntry:entry];
        
        [self.tableView insertRowsAtIndexPaths:
         [NSArray arrayWithObject:
          [NSIndexPath indexPathForRow: [current_user.timeline count]-1
                             inSection:0]]
                              withRowAnimation:UITableViewRowAnimationFade];
        
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[current_user.timeline count]-1 inSection:0]
                      atScrollPosition:UITableViewScrollPositionNone
                              animated:true];
    
//    [_tableView scrollToRowAtIndexPath:
//        [NSIndexPath indexPathForRow:[current_user.timeline count]-1 inSection:0]]
//                    atScrollPosition:
//            animated:true];
}

@end
