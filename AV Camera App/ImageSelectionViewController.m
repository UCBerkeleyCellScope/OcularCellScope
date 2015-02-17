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
#import "CamViewController.h"
#import "EyePhotoCell.h"
#import "Exam+Methods.h"
#import "EyeImage+Methods.h"
#import "Random.h"

@interface ImageSelectionViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property(assign, nonatomic) int currentImageIndex;
@property UIViewController *fixationVC;
@property UIAlertView   *deleteAllAlert;
@property EyePhotoCell *currentCell;
@end

@implementation ImageSelectionViewController

@synthesize images, reviewMode;
//imageCollectionView;
@synthesize fixationVC, deleteAllAlert;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
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
        
        /*self.navigationItem.leftBarButtonItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemDone target: self action:@selector(didPressSave:)];
        self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAdd target:self action:@selector(didPressAdd:)];
         */
    }
    
    NSMutableArray *imageViews = [[NSMutableArray alloc] init];
    for(SelectableEyeImage *im in images){
        [imageViews addObject:[[UIImageView alloc] initWithImage: im]];
    }
    
    //self.collectionView.frame = self.view.window.frame;
    ((UICollectionViewFlowLayout *) self.collectionView.collectionViewLayout).itemSize = self.collectionView.frame.size;
    
    CSLog(@"Image selection view presented", @"USER");
    
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    //self.images = nil;
    

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
    
    //cell.eyeImageView.transform = CGAffineTransformMakeRotation(-M_PI_2); //this works but seems to make gesture recognizers not work
    
    [self.collectionView addGestureRecognizer:cell.scrollView.pinchGestureRecognizer];
    [self.collectionView addGestureRecognizer:cell.scrollView.panGestureRecognizer];
    
    [cell updateCell];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView
  didEndDisplayingCell:(EyePhotoCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.collectionView removeGestureRecognizer:cell.scrollView.pinchGestureRecognizer];
    [self.collectionView removeGestureRecognizer:cell.scrollView.panGestureRecognizer];
}

-(IBAction)didPressCancel:(id)sender{
    
    //The Fixation ViewController will be either index 1 out of 0-2 or 1 out of 0-3.
    [self.navigationController popToViewController:fixationVC animated:YES];
}

-(IBAction)didPressAdd:(id)sender{
    
    //The Fixation ViewController will be either index 1 out of 0-2 or 1 out of 0-3.
    //[self.navigationController popToViewController:fixationVC animated:NO];
    
    CamViewController * cvc = [[CamViewController alloc] init];
    
    //[[[CellScopeContext sharedContext]bleManager]setBLECdelegate:cvc];
    cvc.fullscreeningMode = NO;
    SelectableEyeImage *firstImage = [self.images firstObject];
    cvc.selectedLight = firstImage.fixationLight;
    
    [self.navigationController  pushViewController:cvc animated:YES];
    //[fixationVC performSegueWithIdentifier:@"CamViewSegue" sender:(id)sender];
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
        CSLog(@"Delete all confirmed", @"USER");
        
        for (SelectableEyeImage* img in self.images)
        {
            [[[CellScopeContext sharedContext] managedObjectContext] deleteObject:img.coreDataImage];
        }
        [[[CellScopeContext sharedContext] managedObjectContext] save:nil];

        //[self.navigationController popToViewController:fixationVC animated:YES];
        
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
    }
}

/* this needs to be re-written
 * do away with SelectableEyeImage, use an array to keep track of which images have been selected for deletion.
 * load one image at a time. do away with array of images.
 * save images to local directory so they can be deleted. save them when they are acquired, rather than holding them in memory here.
 * save metadata (including focus, exposure, WB, patient info, etc.) to image file
 */
-(IBAction)didPressSave:(id)sender{
    __block int savePhotosCounter = 0;
    
    CSLog(@"Save button pressed", @"USER");
    
    //[self.navigationController setNavigationBarHidden:YES];
    
    UIView *grayScreen = [[UIView alloc] initWithFrame:self.view.window.frame];
    grayScreen.backgroundColor = [UIColor blackColor];
    grayScreen.alpha = 0.3;
    
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activity.center = self.view.window.center;
    [activity startAnimating];
    [self.view.window addSubview:grayScreen];
    [self.view.window addSubview:activity];
    
    if(!reviewMode){
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        
        for( SelectableEyeImage* ei in images){//eImagesToSave){     //HACK TO SAVE ALL
            if(!ei.isSelected){
                EyeImage* coreDataObject = (EyeImage*)[NSEntityDescription insertNewObjectForEntityForName:@"EyeImage" inManagedObjectContext:[[CellScopeContext sharedContext] managedObjectContext]];

                coreDataObject.filePath=ei.filePath;
                coreDataObject.date = ei.date;
                coreDataObject.eye = ei.eye;
                coreDataObject.uploaded = [NSNumber numberWithBool:NO];
                //coreDataObject.uuid = [[NSUUID UUID] UUIDString];
                coreDataObject.uuid = [Random randomStringWithLength:5];
                coreDataObject.fixationLight = [[NSNumber alloc] initWithInt: ei.fixationLight]; //[[NSNumber alloc ]initWithInteger: [[[CellScopeContext sharedContext]bleManager]selectedLight]];
            
                coreDataObject.appVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleVersion"];
                
                NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
                coreDataObject.illumination = [NSString stringWithFormat:@"PR=%ld PW=%ld FR=%ld FW=%ld",
                                               [prefs integerForKey:@"redFocusValue"],
                                               [prefs integerForKey:@"whiteFocusValue"],
                                               [prefs integerForKey:@"redFlashValue"],
                                               [prefs integerForKey:@"whiteFlashValue"]];
                coreDataObject.focus = [NSString stringWithFormat:@"%ld",[prefs integerForKey:@"focusPosition"]];
                coreDataObject.exposure = [NSString stringWithFormat:@"P=%ld F=%ld",
                                                [prefs integerForKey:@"previewExposureDuration"],
                                                [prefs integerForKey:@"previewExposureDuration"]/[prefs integerForKey:@"previewFlashRatio"]];
                coreDataObject.iso = [NSString stringWithFormat:@"P=%ld F=%ld",
                                           [prefs integerForKey:@"previewISO"],
                                           [prefs integerForKey:@"captureISO"]];
                coreDataObject.flashDuration = [NSString stringWithFormat:@"%ld",
                                                [prefs integerForKey:@"flashDurationMultiplier"]*[prefs integerForKey:@"previewExposureDuration"]/[prefs integerForKey:@"previewFlashRatio"]];
                coreDataObject.flashDelay = [NSString stringWithFormat:@"%ld",[prefs integerForKey:@"flashDelay"]];
                coreDataObject.whiteBalance = [NSString stringWithFormat:@"P=%1.2f/%1.2f/%1.2f F=%1.2f/%1.2f/%1.2f",
                                               [prefs floatForKey:@"previewRedGain"],
                                               [prefs floatForKey:@"previewGreenGain"],
                                               [prefs floatForKey:@"previewBlueGain"],
                                               [prefs floatForKey:@"captureRedGain"],
                                               [prefs floatForKey:@"captureGreenGain"],
                                               [prefs floatForKey:@"captureBlueGain"]];
                
                
                coreDataObject.exam = [[CellScopeContext sharedContext]currentExam];
                
                if ([coreDataObject.exam.uploaded  isEqual: @2]) {
                    coreDataObject.exam.uploaded = @1;
                }

                //TODO: add metadata.
                savePhotosCounter++;
                
                NSString* logmsg = [NSString stringWithFormat:@"Saving image with UUID %@",coreDataObject.uuid];
                CSLog(logmsg,@"DATA");
                
                [library writeImageToSavedPhotosAlbum:ei.CGImage orientation:ALAssetOrientationRight completionBlock:^(NSURL *assetURL, NSError *error){
                    if (error) {
                        CSLog(@"Error writing image to photo album",@"DATA");
                    }
                    else {
                        CSLog(@"Added image to asset library",@"DATA");
                        coreDataObject.filePath = [assetURL absoluteString];
                        [[[CellScopeContext sharedContext] managedObjectContext] save:nil];
                    }
                    savePhotosCounter--;
                }];
                
                coreDataObject.thumbnail = UIImagePNGRepresentation(ei.thumbnail);
                Exam* e = [[CellScopeContext sharedContext ]currentExam ];
                [e addEyeImagesObject:coreDataObject];
                [[[CellScopeContext sharedContext] managedObjectContext] save:nil];
            }
        }
    }
    
    if(reviewMode){
        for( SelectableEyeImage* ei in images){
            if(ei.isSelected){
                CSLog(@"Deleting single image",@"DATA");
                [[[CellScopeContext sharedContext] managedObjectContext] deleteObject: ei.coreDataImage];
                [[[CellScopeContext sharedContext] managedObjectContext] save:nil];
            }
        }
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (savePhotosCounter!=0) { [NSThread sleepForTimeInterval:0.1]; }
        dispatch_async(dispatch_get_main_queue(), ^{
            [activity stopAnimating];
            [grayScreen removeFromSuperview];
            [activity removeFromSuperview];
            [self.navigationController popToViewController:fixationVC animated:YES];
        });
    });

}

@end
