//
//  ImageSelectionViewController.m
//  OcularCellscope
//
//  Created by Chris Echanique on 2/19/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import "ImageSelectionViewController.h"
#import "EImage.h"
#import "FixationViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "CameraAppDelegate.h"

@interface ImageSelectionViewController ()

@property(assign, nonatomic) int currentImageIndex;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSString *file;

@end

@implementation ImageSelectionViewController

@synthesize imageView,slider, images, currentImageIndex, selectedLight, selectedEye, thumbnails, imageViewButton, selectedIcon, file;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize eyeImages = _eyeImages;

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
    
    CameraAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    _managedObjectContext = [appDelegate managedObjectContext];

    NSLog(@" %@, %d", selectedEye, selectedLight);
    
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    currentImageIndex = 0;
    selectedIcon.layer.shadowOffset = CGSizeMake(0, 1);
}

-(void)viewWillAppear:(BOOL)animated
{
    //[selectedIcon setImage:[UIImage imageNamed:@"x_button.png"]];
    NSLog(@"There are %lu images", (unsigned long)[images count]);
    NSLog(@"There are %lu images", (unsigned long)[_eyeImages count]);
    NSLog(@"There are %lu thumbnails", (unsigned long)[thumbnails count]);
    
    if([images count]<1){
        slider.hidden = YES;
        NSLog(@"LESS THAN 1");
    }
    else{
        slider.hidden = NO;
        slider.minimumValue = 0;
        slider.maximumValue = [images count]-1;
        
        [self updateViewWithImage:[images objectAtIndex:currentImageIndex] useThumbnail:NO];
    }
    
}

/*
-(void) load: (int) cii{
    NSLog(@"IN THE LOAD");
    currentEyeImage = [eyeImages objectAtIndex:cii];
    
    NSURL *aURL = [NSURL URLWithString: currentEyeImage.filePath];
    
    NSLog(@"displaying image at: %@",currentEyeImage.filePath);
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:aURL resultBlock:^(ALAsset *asset)
     {
         ALAssetRepresentation* rep = [asset defaultRepresentation];
         CGImageRef iref = [rep fullResolutionImage];
         
         [imageView setImage:[UIImage imageWithCGImage:iref]];
     }
            failureBlock:^(NSError *error)
     {
         // error handling
         NSLog(@"failure loading video/image from AssetLibrary");
     }];
    
}
 */

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
    
    /*
    NSNumber* currentIndex = [NSNumber numberWithInt:currentImageIndex];
    
    BOOL isCurrentlySelected = [selectedImageIndices containsObject:currentIndex];
    
    if(isCurrentlySelected){
        // Deselect image
        NSLog(@"Image %d deselected", currentImageIndex);
        [self changeImageIconToSelected:YES];
        [selectedImageIndices removeObject:currentIndex];
    }
    else{
        // Select image
        NSLog(@"Image %d selected", currentImageIndex);
        [self changeImageIconToSelected:NO];
        [selectedImageIndices addObject:currentIndex];
    }
        */
    
}

-(IBAction)didPressCancel:(id)sender{
    NSArray* viewControllers = self.navigationController.viewControllers;
    UIViewController* fixationVC = [viewControllers objectAtIndex: 1 ];
    //The Fixation ViewController will be either index 1 out of 0-2 or 1 out of 0-3.
    
    [self.navigationController popToViewController:fixationVC animated:YES];
}

-(IBAction)didPressSave:(id)sender{
    if([EImage containsSelectedImageInArray:images]){
        //save
        
        NSMutableArray* eImagesToSave = [EImage selectedImagesFromArray:images];
        for( EImage* ei in eImagesToSave){
            EyeImage* coreDataObject = (EyeImage*)[NSEntityDescription insertNewObjectForEntityForName:@"EyeImage" inManagedObjectContext:self.managedObjectContext];
            coreDataObject.date = ei.date;
            coreDataObject.eye = ei.eye;
            [self saveImageToCameraRoll:ei coreData: coreDataObject];
            coreDataObject.thumbnail = UIImagePNGRepresentation(ei.thumbnail);
            
            NSNumber *myNum = [NSNumber numberWithInteger:ei.fixationLight];
            coreDataObject.fixationLight = myNum;
        }
        
        NSArray* viewControllers = self.navigationController.viewControllers;
        UIViewController* fvc = [viewControllers objectAtIndex:[viewControllers count]-3];
        //fvc.imageArray = [EImage selectedImagesFromArray:images];
        
        [self.navigationController popToViewController:fvc animated:YES];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Images Selected"
                                                        message:@"You must select at least one image before saving."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
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
            NSLog(@"Super important! This is the file path!");
            NSLog(@"%@", myString);
            NSLog(@"%@", myPath);
            
            NSLog(@"Added image to asset library");
            
            cd.filePath = [assetURL absoluteString];
            
        }
    }]; // end of completion block
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //isEqualToString identifiers won't work
    
    if ([[segue identifier] isEqualToString:@"CaptureViewSegue"])
    {
       /*
        NSLog(@"Preparing for CaptureViewSegue");
        FixationViewController* fvc = (FixationViewController*)[segue destinationViewController];
        fvc.imageArray = [EImage selectedImagesFromArray:images];
        */
    }
    
    else if ([[segue identifier] isEqualToString:@"ImageSelectionSegue"])
    {
        /*
        ImageSelectionViewController * isvc = (ImageSelectionViewController*)[segue destinationViewController];
        isvc.selectedEye = self.selectedEye;
        isvc.selectedLight = self.selectedLight;
         */
    }
    
}

-(void)updateViewWithImage:(EImage*) image useThumbnail:(bool) useThumbnail{
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
