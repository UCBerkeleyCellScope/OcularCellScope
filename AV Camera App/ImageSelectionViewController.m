//
//  ImageSelectionViewController.m
//  OcularCellscope
//
//  Created by Chris Echanique on 2/19/14.
//  Copyright (c) 2014 UC Berkeley Ocular CellScope. All rights reserved.
//


#import "ImageSelectionViewController.h"
#import "CameraAppDelegate.h"
#import "FixationViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ImageCell.h"
#import "CoreDataController.h"
#import "EyePhotoCell.h"


@interface ImageSelectionViewController ()

@property(assign, nonatomic) int currentImageIndex;
@property UIViewController *fixationVC;
@property UIAlertView   *deleteAllAlert;
@end

@implementation ImageSelectionViewController

@synthesize images, reviewMode, imageCollectionView;
@synthesize fixationVC, deleteAllAlert;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    
    
    NSArray* viewControllers = self.navigationController.viewControllers;
    fixationVC = [viewControllers objectAtIndex: 1 ];
    //self.imageView.layer.affineTransform = CGAffineTransformInvert(CGAffineTransformMakeRotation(M_PI));

    
}

-(void)viewWillAppear:(BOOL)animated
{
    //[selectedIcon setImage:[UIImage imageNamed:@"x_button.png"]];
    NSLog(@"There are %lu images", (unsigned long)[images count]);
    //NSLog(@"There are %lu images", (unsigned long)[_eyeImages count]);
        
    if(reviewMode == YES){
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.leftBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"Delete All" style:UIBarButtonItemStylePlain target: self action:@selector(didPressDeleteAll)];

    }
    
    NSMutableArray *imageViews = [[NSMutableArray alloc] init];
    for(SelectableEyeImage *im in images){
        [imageViews addObject:[[UIImageView alloc] initWithImage: im]];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.images count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    EyePhotoCell *cell = (EyePhotoCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    
    cell.eyeImage = [self.images objectAtIndex:[indexPath row]];
    NSLog(@"Index path %ld", (long)[indexPath row]);
    
    [cell updateCell];
    
    return cell;
    
}

-(IBAction)didPressCancel:(id)sender{

    //The Fixation ViewController will be either index 1 out of 0-2 or 1 out of 0-3.
    [self.navigationController popToViewController:fixationVC animated:YES];
}

-(void) didPressDeleteAll{
    NSLog(@"PRESSED DELETE");
    deleteAllAlert = [[UIAlertView alloc] initWithTitle:@"Delete All Images?"
                                                    message:@""
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes",nil];
    [deleteAllAlert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == deleteAllAlert && buttonIndex == 1){
        NSPredicate *p = [NSPredicate predicateWithFormat: @"exam == %@ AND eye == %@ AND fixationLight == %d",
                          [[CellScopeContext sharedContext]currentExam],
                          [[CellScopeContext sharedContext]selectedEye],
                          [[CellScopeContext sharedContext]bleManager].selectedLight];
        
        [CoreDataController deleteAllObjectsForEntity:@"EyeImage" withPredicate:p andContext:[[CellScopeContext sharedContext]managedObjectContext]];
        [self.navigationController popToViewController:fixationVC animated:YES];
    }
}

-(IBAction)didPressSave:(id)sender{
    //if([EImage containsSelectedImageInArray:images]){
        //save
    
    // GO THROUGH AND DELETE THE EyeImages MARKED FOR DELETEION
  
    if(!reviewMode){
            //NSMutableArray* eImagesToSave = [EImage selectedImagesFromArray:images];
        for( SelectableEyeImage* ei in images){//eImagesToSave){     //HACK TO SAVE ALL
            if(!ei.isSelected){
                EyeImage* coreDataObject = (EyeImage*)[NSEntityDescription insertNewObjectForEntityForName:@"EyeImage" inManagedObjectContext:[[CellScopeContext sharedContext] managedObjectContext]];
                coreDataObject.date = ei.date;
                coreDataObject.eye = ei.eye;
            
                coreDataObject.fixationLight = [[NSNumber alloc] initWithInt: ei.fixationLight]; //[[NSNumber alloc ]initWithInteger: [[[CellScopeContext sharedContext]bleManager]selectedLight]];
            
                NSLog(@"FIxATION LIGHT CORE DATA %@", coreDataObject.fixationLight);
                coreDataObject.exam = [[CellScopeContext sharedContext]currentExam];
            
            
                [self saveImageToCameraRoll:ei coreData: coreDataObject];
                coreDataObject.thumbnail = UIImagePNGRepresentation(ei.thumbnail);
            
                //NSNumber *myNum = [NSNumber numberWithInteger:ei.fixationLight];
                //coreDataObject.fixationLight = myNum;
                
            
                Exam* e = [[CellScopeContext sharedContext ]currentExam ];
                [e addEyeImagesObject:coreDataObject];
                 
                
            }
            
        }

    }
    
    if(reviewMode){
        for( SelectableEyeImage* ei in images){
            if(ei.isSelected){
                [[[CellScopeContext sharedContext] managedObjectContext] deleteObject: ei.coreDataImage];
            }
        }
    }
    
    [self.navigationController popToViewController:fixationVC animated:YES];
    
}


-(void)saveImageToCameraRoll:(UIImage*) image coreData: (EyeImage*) cd{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    [library writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error){
        if (error) {
            NSLog(@"Error writing image to photo album");
        }
        else {
            
            //NSString *myString = [assetURL absoluteString];
            //NSString *myPath = [assetURL path];
            //NSLog(@"Super important! This is the file path!");
            //NSLog(@"%@", myString);
            //NSLog(@"%@", myPath);
            
            NSLog(@"Added image to asset library");
            
            cd.filePath = [assetURL absoluteString];
            
        }
    }]; // end of completion block
    //Consider an NSNotification that you may now Segue
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}


@end
