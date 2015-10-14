//
//  JNSShotViewController.m
//  Hello
//
//  Created by Shuai on 10/16/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import "JNSShotViewController.h"
#import "JNSTemplateManager.h"

@interface JNSShotViewController ()

@end

@implementation JNSShotViewController
- (IBAction)cancelTouched:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

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


// UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray* array = [JNSTemplateManager manager].templates;
    NSAssert(array, @"");
    
    return [array count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"template" forIndexPath:indexPath];
    
    UIImageView* image = (UIImageView*)[[cell contentView] viewWithTag:99];
    id<JNSTemplate> template = [[JNSTemplateManager manager].templates objectAtIndex:[indexPath item]];
    image.image = [template image];
    
    return cell;
}



@end
