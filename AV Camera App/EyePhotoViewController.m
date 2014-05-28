//
//  EyePhotoViewController.m
//  OcularCellscope
//
//  Created by Chris Echanique on 5/1/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import "EyePhotoViewController.h"
#import "EyePhotoCell.h"
#import "CellScopeContext.h"
#import "CoreDataController.h"

@interface EyePhotoViewController ()
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic) int currentIndex;
@property (strong, nonatomic) UIAlertView *saveAlert;
@property (strong, nonatomic) UIAlertView *cancelAlert;
@end

@implementation EyePhotoViewController

@synthesize imagesArray = _imagesArray;
@synthesize reviewMode = _reviewMode;

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"View Did Load");
    
    //[self setupCollectionView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"View Will Appear");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UICollectionView methods

-(void)setupCollectionView {
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flowLayout setMinimumInteritemSpacing:0.0f];
    [flowLayout setMinimumLineSpacing:0.0f];
    [self.collectionView setPagingEnabled:YES];
    [self.collectionView setCollectionViewLayout:flowLayout];
}


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.imagesArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    EyePhotoCell *cell = (EyePhotoCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    
    cell.eyeImage = [self.imagesArray objectAtIndex:[indexPath row]];
    self.currentIndex = [indexPath row];
    NSLog(@"Index path %ld", (long)[indexPath row]);
    
    [cell updateCell];
    
    return cell;
    
}

/*
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.collectionView.frame.size;
}
 */

#pragma mark -
#pragma mark Rotation handling methods

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:
(NSTimeInterval)duration {
    
    // Fade the collectionView out
    [self.collectionView setAlpha:0.0f];
    
    // Suppress the layout errors by invalidating the layout
    [self.collectionView.collectionViewLayout invalidateLayout];
    
    // Calculate the index of the item that the collectionView is currently displaying
    CGPoint currentOffset = [self.collectionView contentOffset];
    self.currentIndex = currentOffset.x / self.collectionView.frame.size.width;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    // Force realignment of cell being displayed
    CGSize currentSize = self.collectionView.bounds.size;
    float offset = self.currentIndex * currentSize.width;
    [self.collectionView setContentOffset:CGPointMake(offset, 0)];
    
    // Fade the collectionView back in
    [UIView animateWithDuration:0.125f animations:^{
        [self.collectionView setAlpha:1.0f];
    }];
    
}

- (IBAction)didPressSave:(id)sender {
    NSLog(@"PRESSED SAVE");
    self.saveAlert = [[UIAlertView alloc] initWithTitle:@"Save all unmarked images?"
                                                message:@"Images marked for deletion with be permanently deleted."
                                               delegate:self
                                      cancelButtonTitle:@"No"
                                      otherButtonTitles:@"Yes",nil];
    [self.saveAlert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1){
        if(alertView == self.saveAlert){
            [SelectableUIEyeImage saveUnselectedImagesWithImageArray:self.imagesArray];
            UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            [view startAnimating];
            [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(segueToFixationView) userInfo:nil repeats:NO];
            
        }
        else if(alertView == self.cancelAlert){
            self.imagesArray = nil;
            [self segueToFixationView];
        }
            
        /*
        NSPredicate *p = [NSPredicate predicateWithFormat: @"exam == %@ AND eye == %@ AND fixationLight == %d",
                          [[CellScopeContext sharedContext]currentExam],
                          [[CellScopeContext sharedContext]selectedEye],
                          [[CellScopeContext sharedContext]bleManager].selectedLight];
        
        [CoreDataController deleteAllObjectsForEntity:@"EyeImage" withPredicate:p andContext:[[CellScopeContext sharedContext]managedObjectContext]];
        */
    }
}

- (void) segueToFixationView{
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

- (IBAction)didPressCancel:(id)sender {
    NSLog(@"pressed Cancel");
    self.cancelAlert = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to delete all images?"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes",nil];
    [self.cancelAlert show];
}

@end