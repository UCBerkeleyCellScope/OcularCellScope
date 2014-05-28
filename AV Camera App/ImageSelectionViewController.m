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


@interface ImageSelectionViewController ()

@property(assign, nonatomic) int currentImageIndex;
@property UIViewController *fixationVC;
@property UIAlertView   *deleteAllAlert;
@end

@implementation ImageSelectionViewController

@synthesize imageView, slider, images, currentImageIndex, imageViewButton, selectedIcon, reviewMode, imageCollectionView;
@synthesize fixationVC, deleteAllAlert;

//ARE WE PASSING SELECTED LIGHT< SELECTED EYE TO THIS VC?


/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    currentImageIndex = 0;
    selectedIcon.layer.shadowOffset = CGSizeMake(0, 1);
    
    NSArray* viewControllers = self.navigationController.viewControllers;
    fixationVC = [viewControllers objectAtIndex: 1 ];
    self.imageView.layer.affineTransform = CGAffineTransformInvert(CGAffineTransformMakeRotation(M_PI));

    
}

-(void)viewWillAppear:(BOOL)animated
{
    //[selectedIcon setImage:[UIImage imageNamed:@"x_button.png"]];
    NSLog(@"There are %lu images", (unsigned long)[images count]);
    //NSLog(@"There are %lu images", (unsigned long)[_eyeImages count]);
    
    if([images count]<=1){
        slider.hidden = YES;
        NSLog(@"LESS THAN 1");
    }
    else{
        slider.hidden = NO;
        slider.minimumValue = 0;
        slider.maximumValue = [images count]-1;
        
        [self updateViewWithImage:[images objectAtIndex:currentImageIndex] useThumbnail:NO];
    }
    
    if(reviewMode == YES){
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.leftBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"Delete All" style:UIBarButtonItemStylePlain target: self action:@selector(didPressDeleteAll)];

    }
    
    NSMutableArray *imageViews = [[NSMutableArray alloc] init];
    for(EImage *im in images){
        [imageViews addObject:[[UIImageView alloc] initWithImage: im]];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)didMoveSlider:(id)sender{
    int newImageIndex = (int) (slider.value + .5);
    
    if(newImageIndex!=currentImageIndex){
        currentImageIndex = newImageIndex;
        
        [self updateViewWithImage:[images objectAtIndex:currentImageIndex] useThumbnail:YES];
        
        //[imageView setImage:[thumbnails objectAtIndex:newImageIndex]];
        
        /*
        NSNumber* currentIndex = [NSNumber numberWithInt:currentImageIndex];
        
        BOOL isCurrentlySelected =[selectedImageIndices containsObject:currentIndex];
        
        if(isCurrentlySelected){
            // Deselect image
            [self changeImageIconToSelected:YES];
        }
        else{
            // Select image
            [self changeImageIconToSelected:NO];
        }
         */
    }
    
}

-(IBAction)didTouchUpFromSlider:(id)sender{
    //slider.value = currentImageIndex;
    //[imageView setImage:[images objectAtIndex:currentImageIndex]];
    //[self load:currentImageIndex];
    
    [self updateViewWithImage:[images objectAtIndex:currentImageIndex] useThumbnail:NO];
}

-(IBAction)didSelectImage:(id)sender{
    NSLog(@"Image %d touched", currentImageIndex);
    
    EImage* currentImage = [images objectAtIndex:currentImageIndex];
    [currentImage toggleSelected];
    [self changeImageIconToSelected:[currentImage isSelected]];
    
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
  
    if(reviewMode == NO){
            //NSMutableArray* eImagesToSave = [EImage selectedImagesFromArray:images];
        for( EImage* ei in images){//eImagesToSave){     //HACK TO SAVE ALL
                EyeImage* coreDataObject = (EyeImage*)[NSEntityDescription insertNewObjectForEntityForName:@"EyeImage" inManagedObjectContext:[[CellScopeContext sharedContext] managedObjectContext]];
                coreDataObject.date = ei.date;
                coreDataObject.eye = ei.eye;
            
                coreDataObject.fixationLight = [[NSNumber alloc ]initWithInteger: [[[CellScopeContext sharedContext]bleManager]selectedLight]];
            
                NSLog(@"FIxATION LIGHT CORE DATA %@", coreDataObject.fixationLight);
                coreDataObject.exam = [[CellScopeContext sharedContext]currentExam];
            
            
                [self saveImageToCameraRoll:ei coreData: coreDataObject];
                coreDataObject.thumbnail = UIImagePNGRepresentation(ei.thumbnail);
            
                //NSNumber *myNum = [NSNumber numberWithInteger:ei.fixationLight];
                //coreDataObject.fixationLight = myNum;
                
            
                Exam* e = [[CellScopeContext sharedContext ]currentExam ];
                [e addEyeImagesObject:coreDataObject];
                 
                
            //}
            
        }
        [self.navigationController popToViewController:fixationVC animated:YES];
    }
    
    else{
        /*
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Images Selected"
                                                        message:@"You must select at least one image before saving."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        */
        [self.navigationController popToViewController:fixationVC animated:YES];
    }
    
}


-(void)saveImageToCameraRoll:(UIImage*) image coreData: (EyeImage*) cd{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    [library writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error){
        if (error) {
            NSLog(@"Error writing image to photo album");
        }
        else {
            NSString *myString = [assetURL absoluteString];
            NSString *myPath = [assetURL path];
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

-(void)updateViewWithImage:(EImage*) image useThumbnail:(bool) useThumbnail{
    NSLog(@"IMAGE REVIEW FL %d",image.fixationLight);
    
    if(useThumbnail)
        [imageView setImage:image.thumbnail];
    else
        [imageView setImage:image];
    
    [self changeImageIconToSelected:[image isSelected]];
}

-(void)changeImageIconToSelected:(BOOL) isSelected{
    if(isSelected){
        [selectedIcon setImage:[UIImage imageNamed:@"selected_icon.png"]];
    }
    else{
        [selectedIcon setImage:[UIImage imageNamed:@"unselected_icon.png"]];
    }
}

@end
