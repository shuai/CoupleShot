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

@interface CViewController ()
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)buttonTouched:(id)sender;
@end

@implementation CViewController

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

- (void)loadTimeline {
    // Load timeline
    JNSUser* user = [JNSUser activeUser];
    if (user) {
        user.delegate = self;
        
        [user.timeline loadLatestCompletion:^(unsigned int count, NSError *error) {
            if (error) {
                UIAlertView* view = [[UIAlertView alloc] initWithTitle:@"加载错误"
                                                               message:[error localizedDescription]
                                                              delegate:nil
                                                     cancelButtonTitle:@"确定"
                                                     otherButtonTitles:nil];
                [view show];
            } else {
                NSMutableArray* array = [NSMutableArray new];
                for (int i=0; i<count; i++) {
                    [array addObject:
                     [NSIndexPath indexPathForRow: i
                                        inSection:0]];
                }
                
                if ([array count] != 0) {
                    [self.tableView insertRowsAtIndexPaths:array
                                          withRowAnimation:UITableViewRowAnimationFade];
                    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[array count]-1 inSection:0]
                                      atScrollPosition:UITableViewScrollPositionNone
                                              animated:true];
                }
            }
        }];
    }    
}

- (void)wizardViewWillDisappear {
}

- (void)viewWillAppear:(BOOL)animated {
    [self loadTimeline];
}

- (void)viewDidAppear:(BOOL)animated {

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonTouched:(id)sender {
    
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = true;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    
    [self presentViewController:picker animated:true completion:nil];
}

// UITableView delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSAssert(section == 0, @"");
    NSLog(@"Number of rows in section %d: %d", section, [[JNSUser activeUser].timeline.entries count]);
    return [[JNSUser activeUser].timeline.entries count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    JNSTimelineEntry* entry = [JNSUser activeUser].timeline.entries[indexPath.row];
    return [self heightForEntry:entry];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JNSTimelineEntry* entry = [JNSUser activeUser].timeline.entries[indexPath.row];
    
    UITableViewCell *cell = [UITableViewCell new];
    cell.frame = CGRectMake(0, 0, 320, [self heightForEntry:entry]);

    UIImageView* image_view = [self createViewForEntry:entry];
    [[cell contentView] addSubview:image_view];
    
    if (entry.image) {
        image_view.image = entry.image;
        
        if (entry.uploading) {
            UIProgressView* progress = [self createProgressViewInCell:cell];
            [entry trackUploadProgress:^(unsigned int p, NSString *error) {
                NSLog(@"Uploading progress:%d", p);
                if (p == 100) {
                    [UIView animateWithDuration:0.3 animations:^{
                        progress.alpha = 0;
                    } completion:^(BOOL finished) {
                        [progress removeFromSuperview];
                    }];
                } else {
                    progress.progress = p;
                }
            }];
        }
    } else if (!entry.downloading) {
        UIProgressView* progress = [self createProgressViewInCell:cell];
        
        [entry downloadContentProgress:^(unsigned p, NSString *error) {
            NSLog(@"Downloading progress:%d", p);
            if (p == 100) {
                image_view.image = entry.image;
                image_view.alpha = 0;

                [UIView animateWithDuration:0.3 animations:^{
                    progress.alpha = 0;
                    image_view.alpha = 1;
                } completion:^(BOOL finished) {
                    [progress removeFromSuperview];
                }];
            } else {
                progress.progress = p;
            }
        }];
    }
    
    
    return cell;
}

- (UIProgressView*) createProgressViewInCell:(UITableViewCell*)cell {
    UIProgressView* progress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    int y = (cell.frame.size.height - progress.intrinsicContentSize.height)/2;
    int width = 150;
    progress.frame = CGRectMake((self.view.window.frame.size.width - width)/2, y,
                                150, progress.intrinsicContentSize.height);
    progress.progress = 0;
    [[cell contentView] addSubview:progress];
    return progress;
}

-(UIImageView*) createViewForEntry:(JNSTimelineEntry*)entry {
    
    int width = 320-kContentMargin*2;
    int height = 240;
    
    if (entry.height) {
        height = [entry.height intValue] * width / [entry.width intValue];
    }

    UIImageView* image_view = [[UIImageView alloc] initWithFrame:
                               CGRectMake(kContentMargin, kContentMargin, width, height)];
        
    // slow
    CALayer* layer = image_view.layer;
    layer.cornerRadius = 5;
    layer.borderColor = [[UIColor colorWithWhite:0.5 alpha:0.2] CGColor];
    layer.borderWidth = 1;
    layer.masksToBounds = true;
    
    //        layer.shadowColor = [UIColor blackColor].CGColor;
    //        layer.shadowOpacity = 0.5;
    //        layer.shadowRadius = 10;
    //        layer.shadowOffset = CGSizeMake(3, 3);
    
    // Add time label
    UILabel* label = [[UILabel alloc] init];
    NSDate* date = [NSDate dateWithTimeIntervalSince1970: [entry.timestamp doubleValue]/1000];
    int interval = -[date timeIntervalSinceNow];
    if (interval < 0) {
        interval = 0;
    }
    
    NSString* text;
    if (interval < 5*60) {
        text = @"刚刚";
    } else if (interval < 60*60) {
        text = [NSString stringWithFormat:@"%d分钟前", (int)interval/60];
    } else if (interval < 24*60*60) {
        text = [NSString stringWithFormat:@"%d小时前", (int)interval/3600];
    } else {
        text = [NSString stringWithFormat:@"%d天前", (int)interval/(24*3600)];
    }
    
    [label setText:text];
    label.font = [UIFont systemFontOfSize:9];
    CGRect rect = CGRectMake(300 - [label intrinsicContentSize].width - 10,
                             10,
                             [label intrinsicContentSize].width+10,
                             [label intrinsicContentSize].height+10);
    label.frame = rect;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithWhite:0.8 alpha:1];
    label.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.5];
    label.layer.cornerRadius = 5;
    label.layer.masksToBounds = YES;
    
    [image_view addSubview:label];
    
    return image_view;
}

-(int) heightForEntry:(JNSTimelineEntry*)entry {
    int height = 0;
    
    if ([entry.width intValue] != 0) {
        int width = 320-kContentMargin*2;
        height = [entry.height intValue]*width/[entry.width intValue] + kContentMargin - 2; // border
    } else {
        // TODO arbitraty default height
        height = 240;
    }
    
    return height;
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
        
        [[JNSUser activeUser].timeline addEntryWithImage:image];
        
        [self.tableView insertRowsAtIndexPaths:
         [NSArray arrayWithObject:
          [NSIndexPath indexPathForRow: [[JNSUser activeUser].timeline.entries count]-1
                             inSection:0]]
                              withRowAnimation:UITableViewRowAnimationFade];
        
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // scroll to bottom
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[[JNSUser activeUser].timeline.entries count]-1
                                                          inSection:0]
                      atScrollPosition:UITableViewScrollPositionNone
                              animated:true];
}

@end
