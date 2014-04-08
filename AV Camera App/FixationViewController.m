//
//  FixationViewController.m
//  OcularCellscope
//
//  Created by PJ Loury on 2/27/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import "CellScopeContext.h"

#import "FixationViewController.h"
#import "CaptureViewController.h"
#import "ImageSelectionViewController.h"
#import "CoreDataController.h"
#import "CameraAppDelegate.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface FixationViewController ()

@property(strong, nonatomic) UISegmentedControl *sco;

@end

@implementation FixationViewController


@synthesize selectedEye, selectedLight, imageArray, sco;

//This is an EyeImage
@synthesize currentEyeImage;

//These are Buttons
@synthesize centerFixationButton, topFixationButton,
bottomFixationButton, leftFixationButton, rightFixationButton, noFixationButton;

@synthesize currentEImage, uim, passedImages;

//This is an array of buttons
@synthesize fixationButtons;

@synthesize eyeImages;

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

    
    //CameraAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    //_managedObjectContext = [appDelegate managedObjectContext];

    fixationButtons = [NSMutableArray arrayWithObjects: centerFixationButton, topFixationButton,
                                       bottomFixationButton, leftFixationButton, rightFixationButton, noFixationButton, nil];
    
    passedImages = [[NSMutableArray alloc]init];
    
    
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:(BOOL) animated];
        
    NSLog(@"Seg Back, even from ImageSelection");
    
    
    self.tabBarController.title = nil;
    
    //UIBarButtonItem *seg = [[UIBarButtonItem alloc] initWithCustomView:sco];
    
    NSArray* segmentTitles = [[NSArray alloc ]initWithObjects:@"Left",@"Right", nil];
    
    sco = [[UISegmentedControl alloc] initWithItems:segmentTitles];
    sco.selectedSegmentIndex = 0;
    
    self.tabBarController.navigationItem.titleView = sco;
    
    [sco addTarget:self
            action:@selector(didSegmentedValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    if (self.selectedEye){
        if ([self.selectedEye isEqualToString: LEFT_EYE]) [sco setSelectedSegmentIndex: 0];
        else if([self.selectedEye isEqualToString: LEFT_EYE]) [sco setSelectedSegmentIndex: 1];
    }
    else{
        [sco setSelectedSegmentIndex: 0];

    }
    
    
    
    
    [self loadImages: self.sco.selectedSegmentIndex];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    
    sco = nil;
}


-(void)loadImages:(NSInteger)segmentedIndex{
    
    if(self.sco.selectedSegmentIndex == 0){
        selectedEye = LEFT_EYE;
    }
    else{
        selectedEye = RIGHT_EYE;
    }
    
    
    /*
     NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"EyeImage" inManagedObjectContext:[[CellScopeContext sharedContext]managedObjectContext]];
     request.predicate = [NSPredicate predicateWithFormat:@"parent.grandparent == %@", grandParentObject];
     request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"age" ascending:YES]];
     */

  
    //load the images
        for (int i = 1; i <= 6; i++)
        {
            //Attempt 3
            /*
             self.eyeImages = [CoreDataController getObjectsForEntity:@"EyeImage" withSortKey:@"date" andSortAscending:YES andContext:self.managedObjectContext];
            */
            
            
            NSPredicate *p = [NSPredicate predicateWithFormat: @"exam == %@ AND eye == %@ AND fixationLight == %d", [[CellScopeContext sharedContext]currentExam],selectedEye, i];
            
            
            NSArray *temp = [CoreDataController searchObjectsForEntity:@"EyeImage" withPredicate: p
                                                            andSortKey: @"date" andSortAscending: YES
                                                            andContext:   [[CellScopeContext sharedContext] managedObjectContext]];
            
            self.eyeImages = [NSMutableArray arrayWithArray:temp];
            
            //NSLog(@"For Fixation Light %d, %lu images were Retrieved!", i, (unsigned long)[eyeImages count]);
            
            //Attempt 1
            /*
            //NSFetchRequest *request = [[NSFetchRequest alloc] init];
            NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"EyeImage"];
            
            //request.entity = [NSEntityDescription entityForName:@"EyeImage" inManagedObjectContext: _managedObjectContext];
            request.predicate = [NSPredicate predicateWithFormat: @"eye == %@ AND fixationLight == %d", selectedEye, i];
            request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
            request.fetchLimit = 1;
            NSError *error;
            NSArray *array = [_managedObjectContext executeFetchRequest:request error:&error];
            */
            
            if([imageArray count]>0){
                NSLog(@"testing transition from image selection");
                EImage *image = [imageArray objectAtIndex:0];
                if(image.eye == selectedEye && image.fixationLight == i){
                    [fixationButtons[i-1] setImage: image.thumbnail forState:UIControlStateNormal];
                    [fixationButtons[i-1] setSelected: YES];
                }
            }
            
            if([eyeImages count] != 0){
                currentEyeImage = eyeImages[0];
                UIImage* thumbImage = [UIImage imageWithData: currentEyeImage.thumbnail];
                [fixationButtons[i-1] setImage: thumbImage forState:UIControlStateNormal];
                [fixationButtons[i-1] setSelected: YES];
            }
            else{
                UIImage* thumbImage = [UIImage imageNamed: @"Icon@2x.png"];
                [fixationButtons[i-1] setImage: thumbImage forState: UIControlStateNormal];
                [fixationButtons[i-1] setSelected: NO];
                
            }
        }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didPressFixation:(id)sender {
    
    
    self.selectedLight = [sender tag];
    
    
    if( [sender isSelected] == NO){
        //there are pictures!
        [self performSegueWithIdentifier:@"CaptureViewSegue" sender:(id)sender];
    }
    
    else if([sender isSelected] == YES ){
        [self performSegueWithIdentifier:@"ImageReviewSegue" sender:(id)sender];
    }
    
}


- (void)didSegmentedValueChanged:(id)sender {
    
    [self loadImages: self.sco.selectedSegmentIndex];
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"CaptureViewSegue"])
    {
        NSLog(@"Preparing for CaptureViewSegue");
        CaptureViewController* cvc = (CaptureViewController*)[segue destinationViewController];
        cvc.selectedEye = self.selectedEye;
        cvc.selectedLight = self.selectedLight;
        [[CellScopeContext sharedContext] setCvc: cvc];
        
    }
    
    else if ([[segue identifier] isEqualToString:@"ImageReviewSegue"])
    {
        NSLog(@"Segue to ImageReview");
        ImageSelectionViewController * isvc = (ImageSelectionViewController*)[segue destinationViewController];
       //isvc.selectedEye = self.selectedEye;
       //isvc.selectedLight = self.selectedLight;
        

        isvc.navigationItem.leftBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"Delete" style:UIBarButtonItemStylePlain target: self action:@selector(didPressDelete:)];
        
        NSPredicate *p = [NSPredicate predicateWithFormat: @"eye == %@ AND fixationLight == %d", self.selectedEye, self.selectedLight];
        
        
        NSArray *temp = [CoreDataController searchObjectsForEntity:@"EyeImage" withPredicate: p
                                                        andSortKey: @"date" andSortAscending: YES
                                                        andContext: [[CellScopeContext sharedContext] managedObjectContext]];
        
        self.eyeImages = [NSMutableArray arrayWithArray:temp];
        
        NSLog(@"%lu",(unsigned long)[eyeImages count]);
        
        
        for( EyeImage* i in eyeImages){
            if(i){
                NSLog(@"%@",[i filePath]);
                NSLog(@"%@",[i date]);
                NSLog(@"%@",[i eye]);
                NSLog(@"%ld",(long)[i fixationLight]);

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
                 }
                        failureBlock:^(NSError *error)
                 {
                     // error handling
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
