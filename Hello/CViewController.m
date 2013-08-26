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
#import "JNSConfig.h"
#import "JNSLoadManager.h"
#import "JNSEntryView.h"

@interface CViewController ()
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) JNSTimelineEntry *activeEntry;

- (IBAction)buttonTouched:(id)sender;
@end

@implementation CViewController

// MOVE
-(void) entryWithIndex:(int)index LoadedWithError:(NSString*)err {
    NSLog(@"reloadRowsAtIndexPaths %d", index);
    
    [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]]
                      withRowAnimation:UITableViewRowAnimationFade];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.view bringSubviewToFront:(self.addButton)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // Camera Button
    //self.addButton
//    CALayer* layer = self.addButton.layer;
//    layer.shadowColor = [UIColor whiteColor].CGColor;
//    layer.shadowOpacity = 1;
//    layer.shadowRadius = 10;
//    layer.shadowOffset = CGSizeMake(0, 0);
    
    [[JNSConfig config] addObserver:self forKeyPath:@"cachedUser" options:0 context:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    JNSUser* user = [JNSUser activeUser];
    if (user) {
        user.timeline.delegate = self;
    }
}

- (void)viewDidAppear:(BOOL)animated {

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // TODO Dispose of any resources that can be recreated.
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == [JNSConfig config]) {
        if ([JNSUser activeUser] == nil) {
            // Reset table view
            [self.tableView reloadData];
            UIAlertView* view = [[UIAlertView alloc] initWithTitle:@"需要重新登录"
                                                           message:@""
                                                          delegate:nil
                                                 cancelButtonTitle:@"确定"
                                                 otherButtonTitles:nil];
            [view show];

            JNSWizardViewController* vc = [[self storyboard] instantiateViewControllerWithIdentifier:@"wizard_view"];
            [self presentViewController:vc animated:YES completion:nil];
        }
    }
}

// JNSTimelineDelegate
-(void)didLoadLatestWithIndexes:(NSArray*)indexes Error:(NSError*)error {
    if (error) {
        UIAlertView* view = [[UIAlertView alloc] initWithTitle:@"加载错误"
                                                       message:[error localizedDescription]
                                                      delegate:nil
                                             cancelButtonTitle:@"确定"
                                             otherButtonTitles:nil];
        [view show];
        return;
    }
    
    NSMutableArray* array = [NSMutableArray new];
    for (NSNumber* index in indexes) {
        [array addObject:[NSIndexPath indexPathForRow: [index integerValue]
                           inSection: 0]];
    }
    
    if ([array count] != 0) {
        [self.tableView insertRowsAtIndexPaths:array
                              withRowAnimation:UITableViewRowAnimationFade];
        
        //scroll to bottom
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[[JNSUser activeUser].timeline.entries count]-1 inSection:0]
                          atScrollPosition:UITableViewScrollPositionNone
                                  animated:true];
        
        //active entry may have changed
        JNSTimelineEntry* last = [JNSUser activeUser].timeline.entries.lastObject;
        if (_activeEntry) {
            // TODO
        }
    }
    
    
}

// UITableView delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSAssert(section == 0, @"");
    NSLog(@"Number of rows in section %d: %d", section, [[JNSUser activeUser].timeline.entries count]);
    return [[JNSUser activeUser].timeline.entries count] + 1; // 1 for the top padding
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 44+20;
    }
    
    JNSTimelineEntry* entry = [JNSUser activeUser].timeline.entries[indexPath.row-1];
    return [JNSEntryView heightForEntry:entry];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"cellForRow: %D", [indexPath row]);

    UITableViewCell *cell = [UITableViewCell new];
    
    if (indexPath.row == 0) {
        return cell;
    }
    
    JNSTimelineEntry* entry = [JNSUser activeUser].timeline.entries[indexPath.row-1];
    
    cell.frame = CGRectMake(0, 0, 320, [JNSEntryView heightForEntry:entry] + 5);

    id view = [[JNSEntryView alloc] initWithEntry:entry];
    [[cell contentView] addSubview:view];
    
    if (entry.needDownload && !entry.downloading) {
        [[JNSLoadManager manager] queueEntry:entry];
    }
    
    return cell;
}

//- (UIProgressView*) createProgressViewInCell:(UITableViewCell*)cell {
//    UIProgressView* progress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
//    int y = (cell.frame.size.height - progress.intrinsicContentSize.height)/2;
//    int width = 150;
//    progress.frame = CGRectMake((self.view.window.frame.size.width - width)/2, y,
//                                150, progress.intrinsicContentSize.height);
//    progress.progress = 0;
//    [[cell contentView] addSubview:progress];
//    return progress;
//}

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
        
        image = [CViewController scaledImageWithImage:image];
        JNSTimelineEntry* activeEntry = [JNSUser activeUser].timeline.activeEntry;
        if (activeEntry) { // TODO
            // add to existant
            [activeEntry replyEntryWithImage:image];
            // TODO refresh entry
            
        } else {
            // Add as separate entry
            [[JNSUser activeUser].timeline addEntryWithImage:image];
            
            [self.tableView insertRowsAtIndexPaths:
             [NSArray arrayWithObject:
              [NSIndexPath indexPathForRow: [[JNSUser activeUser].timeline.entries count]
                                 inSection:0]]
                                  withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // scroll to bottom
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[[JNSUser activeUser].timeline.entries count]
                                                          inSection:0]
                      atScrollPosition:UITableViewScrollPositionNone
                              animated:true];
}

+ (UIImage*)scaledImageWithImage:(UIImage*)image;
{
    CGSize newSize = image.size;
    if (newSize.width > 320) {
        newSize = CGSizeMake(320, 320*image.size.height/image.size.width);
    }
    
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}

@end
