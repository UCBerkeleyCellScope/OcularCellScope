//
//  FixationViewController.m
//  OcularCellscope
//
//  Created by PJ Loury on 2/27/14.
//  Copyright (c) 2014 UC Berkeley Ocular CellScope. All rights reserved.
//

#import "CameraAppDelegate.h"
#import "FixationViewController.h"
#import "CamViewController.h"
#import "ImageSelectionViewController.h"
#import "CoreDataController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>

@interface FixationViewController ()

@property(strong, nonatomic) UISegmentedControl *segControl;
@property(strong, nonatomic) NSArray *imageFileNames;

@end

@implementation FixationViewController


@synthesize selectedEye, selectedLight, imageArray, segControl;
@synthesize bleManager = _bleManager;

//This is an EyeImage
@synthesize currentEyeImage;

//These are Buttons
@synthesize centerFixationButton, topFixationButton,
bottomFixationButton, leftFixationButton, rightFixationButton, noFixationButton;
//This is an array of buttons
@synthesize fixationButtons;

@synthesize currentEImage, uim, passedImages;
@synthesize eyeImages;
@synthesize imageFileNames;

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
    
    fixationButtons = [NSMutableArray arrayWithObjects: centerFixationButton, topFixationButton,
                                       bottomFixationButton, leftFixationButton, rightFixationButton, noFixationButton, nil];
    
    
    imageFileNames = [NSArray arrayWithObjects: @"retina_icon_center.png",
                      @"retina_icon_top.png", @"retina_icon_bottom.png",
                      @"retina_icon_left.png", @"retina_icon_right",
                      @"retina_icon_center.png", nil];
    
    _bleManager = [[CellScopeContext sharedContext] bleManager];
    
    passedImages = [[NSMutableArray alloc]init];
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:(BOOL) animated];
            
    [_bleManager turnOffAllLights];
    
    [self setSelectedEye:  [[CellScopeContext sharedContext]selectedEye] ];
    
    self.tabBarController.title = nil;
    
    [self initSegControl];
    
    [self loadImages: self.segControl.selectedSegmentIndex];
    
}

-(void) initSegControl{
    NSArray* segmentTitles = [[NSArray alloc ]initWithObjects:@"Left",@"Right", nil];
    self.segControl = [[UISegmentedControl alloc] initWithItems:segmentTitles];
    self.segControl.selectedSegmentIndex = 0;
    self.tabBarController.navigationItem.titleView = self.segControl;
    [self.segControl addTarget:self
                        action:@selector(didSegmentedValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    if (self.selectedEye){
        if ([self.selectedEye isEqualToString: LEFT_EYE]) [self.segControl setSelectedSegmentIndex: 0];
        else if([self.selectedEye isEqualToString: RIGHT_EYE]) [self.segControl setSelectedSegmentIndex: 1];
    }
    else{
        [segControl setSelectedSegmentIndex: 0];
        self.selectedEye = LEFT_EYE;
        [[CellScopeContext sharedContext]setSelectedEye: LEFT_EYE];

    }
}

-(void)viewDidAppear:(BOOL)animated{
    
}

- (void)viewWillDisappear:(BOOL)animated{
    
    self.segControl = nil;
    self.tabBarController.navigationItem.titleView = nil;
}


-(void)loadImages:(NSInteger)segmentedIndex{
    
    UIView* fxv = [[UIView alloc]init];
    
    if(self.segControl.selectedSegmentIndex == 0){
        [[CellScopeContext sharedContext] setSelectedEye: LEFT_EYE];
        self.selectedEye = LEFT_EYE;

    }
    else{
        [[CellScopeContext sharedContext] setSelectedEye: RIGHT_EYE];
        self.selectedEye = RIGHT_EYE;
    }
    
    
    /*
     NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"EyeImage" inManagedObjectContext:[[CellScopeContext sharedContext]managedObjectContext]];
     request.predicate = [NSPredicate predicateWithFormat:@"parent.grandparent == %@", grandParentObject];
     request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"age" ascending:YES]];
     */

    
    /*
    NSArray *allImages = [CoreDataController getObjectsForEntity:@"EyeImage" withSortKey:@"date" andSortAscending:YES andContext:[[CellScopeContext sharedContext]managedObjectContext]];
    NSLog(@"ALL Images count is %d", (int)[allImages count]);
    */
    
  
    //load the images
        for (int i = 0; i <= 5; i++)
        {
            [fixationButtons[i] setImage: nil forState:UIControlStateNormal];
            //Attempt 3
            /*
             self.eyeImages = [CoreDataController getObjectsForEntity:@"EyeImage" withSortKey:@"date" andSortAscending:YES andContext:self.managedObjectContext];
            */
            
            
            NSPredicate *p = [NSPredicate predicateWithFormat: @"exam == %@ AND eye == %@ AND fixationLight == %d", [[CellScopeContext sharedContext]currentExam],
                              [[CellScopeContext sharedContext] selectedEye], i];
            if( i==0)
                NSLog(@"%@",[[CellScopeContext sharedContext] selectedEye]);
            
            
            
            NSArray *temp = [CoreDataController searchObjectsForEntity:@"EyeImage" withPredicate: p
                                                            andSortKey: @"date" andSortAscending: YES
                                                            andContext:   [[CellScopeContext sharedContext] managedObjectContext]];
            
            
            self.eyeImages = [NSMutableArray arrayWithArray:temp];
        
            NSLog(@"Images for Fixation %d : %d", i, (int)[eyeImages count]);
            
            /*
            if([imageArray count]>0){
                NSLog(@"testing transition from image selection");
                EImage *image = [imageArray objectAtIndex:0];
                if(image.eye == selectedEye && image.fixationLight == i){
                    [fixationButtons[i] setImage: image.thumbnail forState:UIControlStateNormal];
                    [fixationButtons[i] setSelected: YES];
                }
            }
            */
            
            if([eyeImages count] != 0){
                currentEyeImage = eyeImages[0];
                UIImage* thumbImage = [UIImage imageWithData: currentEyeImage.thumbnail];
                [fixationButtons[i] setImage: thumbImage forState:UIControlStateNormal];
                [fixationButtons[i] setSelected: YES];
            }
            else{
                UIImage* thumbImage = [UIImage imageNamed: [imageFileNames objectAtIndex:i]];
                [fixationButtons[i] setImage: thumbImage forState: UIControlStateNormal];
                [fixationButtons[i] setSelected: NO];
                
            }
        }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didPressFixation:(id)sender {
    
    self.selectedLight = (int)[sender tag];
    [_bleManager setSelectedLight: self.selectedLight];
    
    if( [sender isSelected] == NO){
        //there are pictures!
        [self performSegueWithIdentifier:@"CamViewSegue" sender:(id)sender];
    }
    
    else if([sender isSelected] == YES ){
        [self performSegueWithIdentifier:@"ImageReviewSegue" sender:(id)sender];
    }
    
}


- (void)didSegmentedValueChanged:(id)sender {
    
    /*
    [UIView transitionFromView: self.fixView
                        toView: self.fixView
                      duration:1.0
                       options: UIViewAnimationOptionTransitionFlipFromRight
                    completion:^(BOOL finished){                      [self loadImages: self.segControl.selectedSegmentIndex];}
                    ];
     
     */
    
    //self.view.layer.affineTransform = CGAffineTransformInvert(CGAffineTransformMake(0,0,0,-1,0,0));
    
    
    [self loadImages: self.segControl.selectedSegmentIndex];
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"CamViewSegue"])
    {

        NSLog(@"Preparing for CamViewSegue");
        CamViewController* cvc = (CamViewController*)[segue destinationViewController];
        [[[CellScopeContext sharedContext]bleManager]setBLECdelegate:cvc];
        
    }
    
    else if ([[segue identifier] isEqualToString:@"ImageReviewSegue"])
    {
        NSLog(@"Segue to ImageReview");
        ImageSelectionViewController * isvc = (ImageSelectionViewController*)[segue destinationViewController];
        
        isvc.reviewMode = YES;
        
        //NSLog([[CellScopeContext sharedContext]currentExam].description);
        
        [passedImages removeAllObjects];
        
        NSPredicate *p = [NSPredicate predicateWithFormat: @"exam == %@ AND eye == %@ AND fixationLight == %d", [[CellScopeContext sharedContext]currentExam], self.selectedEye,
                           _bleManager.selectedLight];
    
        NSArray *temp = [CoreDataController searchObjectsForEntity:@"EyeImage" withPredicate: p
                                                        andSortKey: @"date" andSortAscending: YES
                                                        andContext: [[CellScopeContext sharedContext] managedObjectContext]];
        
        //NOTE THAT eyeImages DO NOT get passed over to ISVC, only EImages do!!!, So let's create some EImages
        self.eyeImages = [NSMutableArray arrayWithArray:temp];
        
        NSLog(@"%lu",(unsigned long)[eyeImages count]);
        
        for( EyeImage* i in eyeImages){
            if(i){
                NSLog(@"%@",[i filePath]);
                NSLog(@"%@",[i date]);
                NSLog(@"%@",[i eye]);
                NSLog(@"FIX LIGHT %d",[[i fixationLight] intValue]);
                
                //UIImage *im = [UIImage imageWithContentsOfFile: i.filePath];
                //Let's get an image!
                
                NSURL *aURL = [NSURL URLWithString: i.filePath];
                //NSLog(@"displaying image at: %@",i.filePath);
                
                ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                [library assetForURL:aURL resultBlock:^(ALAsset *asset)
                 {
                     ALAssetRepresentation* rep = [asset defaultRepresentation];
                     CGImageRef iref = [rep fullResolutionImage];
                     uim = [UIImage imageWithCGImage:iref];
                     
                     NSLog(@"What's the Fixation %@", i.fixationLight);
                     
//                         UIImage *th = [UIImage imageWithData: i.thumbnail];
//                         
//                         EImage *image = [[EImage alloc] initWithUIImage: uim
//                                                                    date: i.date
//                                                                     eye: i.eye
//                                                           fixationLight: i.fixationLight
//                                                               thumbnail: th];
//                         
//                         [passedImages addObject: image];

                     
                 }
                        failureBlock:^(NSError *error)
                 {

                     NSLog(@"failure loading video/image from AssetLibrary");
                 }];


                NSLog(@"What's the Fixation %@", i.fixationLight);
                
                UIImage *th = [UIImage imageWithData: i.thumbnail];
                             
                EImage *image = [[EImage alloc] initWithUIImage: th
                                                        date: i.date
                                                         eye: i.eye
                                               fixationLight: i.fixationLight
                                                      thumbnail: th];
                
                [passedImages addObject: image];
        
            }
            
        }
    
        isvc.images = passedImages;
    }

}


@end
