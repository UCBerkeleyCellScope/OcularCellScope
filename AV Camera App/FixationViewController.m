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
#import "CellScopeContext.h"
#import "TabViewController.h"
#import "UIColor+Custom.h"

@interface FixationViewController ()

@property(strong, nonatomic) UISegmentedControl *segControl;
@property(strong, nonatomic) NSArray *oDImageFileNames;
@property(strong, nonatomic) NSArray *oSImageFileNames;
@property(strong, nonatomic) UIAlertView *fixationAlert;

@end

@implementation FixationViewController


@synthesize selectedEye, selectedLight, imageArray, segControl, fixationAlert, beginButton;

//This is an EyeImage
@synthesize currentEyeImage;

//These are Buttons
@synthesize centerFixationButton, topFixationButton,
bottomFixationButton, leftFixationButton, rightFixationButton, noFixationButton;
//This is an array of buttons
@synthesize fixationButtons;

@synthesize currentEImage, uim, passedImages;
@synthesize eyeImages;
@synthesize oDImageFileNames, oSImageFileNames;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    fixationButtons = [NSMutableArray arrayWithObjects: noFixationButton, centerFixationButton, topFixationButton,
                                       bottomFixationButton, leftFixationButton, rightFixationButton, nil];
    
    
    oDImageFileNames = [NSArray arrayWithObjects: @"od_center.png", @"od_center.png",
                          @"od_top.png", @"od_bottom.png",
                          @"od_left.png", @"od_right", nil];
    
    
    oSImageFileNames = [NSArray arrayWithObjects: @"os_center.png", @"os_center.png",
                          @"os_top.png", @"os_bottom.png",
                          @"os_left.png", @"os_right", nil];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver: self
           selector:@selector(createNextSelectableEyeImage:)
               name:@"SelectableEyeImageCreated" //The notification that was sent is named ____
             object:nil]; //doesn't matter who sent the notification

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fixationDisplayChange:) name:@"FixationDisplayChangeNotification" object:nil];
    
    [self setupFixationButtons];
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:(BOOL) animated];
    
    self.tabBarController.title = nil;
    
    //[_bleManager turnOffAllLights];
    
    NSLog(@"CSContext SelectedEye: %d",[[CellScopeContext sharedContext]selectedEye]);
    [self initSegControl];
    [self loadImages];
    
}

- (void)fixationDisplayChange:(NSNotification *)notification
{
    
    NSDictionary *ui = [notification userInfo];
    NSString* newDisplayState = ui[@"displayState"];
    
    if ([newDisplayState isEqualToString:@"NONE"]) {
    }
    else if ([newDisplayState isEqualToString:@"OD"]) {
        [self.segControl setSelectedSegmentIndex:0];
    }
    else if ([newDisplayState isEqualToString:@"OS"]) {
        [self.segControl setSelectedSegmentIndex:1];
    }
    
    [self didSegmentedValueChanged:nil];
}

-(void) initSegControl{
    NSArray* segmentTitles = [[NSArray alloc ]initWithObjects:@"OD",@"OS", nil];
    self.segControl = [[UISegmentedControl alloc] initWithItems:segmentTitles];
    CGRect f = self.segControl.frame;
    f.size.width = f.size.width*2; //make it wider so it's easier to tap
    
    self.segControl.frame = f;
    
    self.segControl.selectedSegmentIndex = 0;
    self.tabBarController.navigationItem.titleView = self.segControl;
    [self.segControl addTarget:self
                        action:@selector(didSegmentedValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    if ([[CellScopeContext sharedContext] selectedEye] == OD_EYE)
    {
        [self.segControl setSelectedSegmentIndex: 0];
    }
    else if([[CellScopeContext sharedContext]selectedEye] == OS_EYE){
        [self.segControl setSelectedSegmentIndex: 1];
    }
    else if([[CellScopeContext sharedContext]selectedEye] == 0)
    {
        NSLog(@"Selected Eye was previously nil");
        [self.segControl setSelectedSegmentIndex: 0];
        [[CellScopeContext sharedContext]setSelectedEye: OD_EYE];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    
    self.segControl = nil;
    self.tabBarController.navigationItem.titleView = nil;
}

-(void)loadImages{
    
    if ([[CellScopeContext sharedContext] selectedEye]==OD_EYE) {
            self.leftLabel.text = @"Temporal";
            self.rightLabel.text = @"Nasal";
    }
    else {
        self.leftLabel.text = @"Nasal";
        self.rightLabel.text = @"Temporal";
    }
    
        for (int i = 0; i <= 5; i++)
        {
            //[fixationButtons[i] setImage: nil forState:UIControlStateNormal];
            
            NSString* eyeString;
            if ([[CellScopeContext sharedContext] selectedEye] == 1)
                eyeString = @"OD";
            else
                eyeString = @"OS";
            
            NSPredicate *p = [NSPredicate predicateWithFormat: @"exam == %@ AND eye == %@ AND fixationLight == %d", [[CellScopeContext sharedContext]currentExam],
                              eyeString, i];
            if( i==0)
                NSLog(@"%d",[[CellScopeContext sharedContext] selectedEye]);
            
            
            NSArray *temp = [CoreDataController searchObjectsForEntity:@"EyeImage" withPredicate: p
                                                            andSortKey: @"date" andSortAscending: YES
                                                            andContext:   [[CellScopeContext sharedContext] managedObjectContext]];
            
            self.eyeImages = [NSMutableArray arrayWithArray:temp];
        
            NSLog(@"Images for Fixation %d : %d", i, (int)[eyeImages count]);
            
            if([eyeImages count] != 0){
                currentEyeImage = eyeImages[0];
                
                UIImage* thumbImage = [UIImage imageWithData: currentEyeImage.thumbnail];
                [fixationButtons[i] setImage: thumbImage forState:UIControlStateSelected];
                [fixationButtons[i] setImage: thumbImage forState:UIControlStateNormal];
                
                [fixationButtons[i] setSelected: YES];
                
                [(UIButton*)fixationButtons[i] setTransform: CGAffineTransformMakeRotation(M_PI)]; //added to rotate thumbnails
            }
            else{
                UIImage* thumbImage;
                if([[CellScopeContext sharedContext]selectedEye]  == OD_EYE ||
                   [[CellScopeContext sharedContext]selectedEye]  == 0 ){
                    thumbImage = [UIImage imageNamed: [oDImageFileNames objectAtIndex:i]];
                }
                else if([[CellScopeContext sharedContext]selectedEye]  == OS_EYE){
                    thumbImage = [UIImage imageNamed: [oSImageFileNames objectAtIndex:i]];
                }
                else{
                    NSLog(@"ERROR SHOULD NEVER HAPPEN");
                    NSLog(@"%d",[[CellScopeContext sharedContext]selectedEye]);
                }
                [fixationButtons[i] setImage: thumbImage forState:UIControlStateSelected];
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
    //[_bleManager setSelectedLight: self.selectedLight];
    
    if( [sender isSelected] == NO){

        [self performSegueWithIdentifier:@"CamViewSegue" sender:(id)sender];
    }
    
    else if([sender isSelected] == YES ){
        //there are pictures!
        //[self performSegueWithIdentifier:@"ImageReviewSegue" sender:(id)sender];
        
        self.fixationAlert = [[UIAlertView alloc] initWithTitle:@"Would you like to review existing images or add new ones?"
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:@"Review"
                                              otherButtonTitles:@"Add",nil];
        [self.fixationAlert show];
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == self.fixationAlert){
        if(buttonIndex == 1){
            //Index 1 Selected
            [self performSegueWithIdentifier:@"CamViewSegue" sender:self];
        }
        else{
            //Index 0 Selected
            [self loadImagesForImageReview];
            
            }
    }
}

-(void)loadImagesForImageReview{
    
    self.passedImages = [[NSMutableArray alloc]init];

    //[self.passedImages removeAllObjects];//assigned to ISVC
    NSString* eyeString;
    if ([[CellScopeContext sharedContext] selectedEye] == 1)
        eyeString = @"OD";
    else
        eyeString = @"OS";
    
    NSPredicate *p = [NSPredicate predicateWithFormat: @"exam == %@ AND eye == %@ AND fixationLight == %d", [[CellScopeContext sharedContext]currentExam], eyeString,
                      self.selectedLight];
    
    NSArray *temp = [CoreDataController searchObjectsForEntity:@"EyeImage" withPredicate: p
                                                    andSortKey: @"date" andSortAscending: YES
                                                    andContext: [[CellScopeContext sharedContext] managedObjectContext]];
    
    self.eyeImages = [NSMutableArray arrayWithArray:temp];
    
    temp = nil;
    
    [self createSelectableEyeImage];
}

-(void)createSelectableEyeImage{
    NSLog(@"eyeImages: %d",[self.eyeImages count]);
    __block EyeImage* ei = [self.eyeImages objectAtIndex:0];
    [self.eyeImages removeObjectAtIndex:0];
    
    
    NSURL *aURL = [NSURL URLWithString: ei.filePath];
    NSLog(@"displaying image at: %@",ei.filePath);
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:aURL resultBlock:^(ALAsset *asset)
     {
         NSLog(@"Does the inner block have access to EI?%@",ei.description);
        
         ALAssetRepresentation* rep = [asset defaultRepresentation];
         CGImageRef iref = [rep fullResolutionImage];
         uim = [UIImage imageWithCGImage:iref];
         
         
         if (uim!=nil) {

         NSLog(@"%@",[ei filePath]);
         NSLog(@"%@",[ei date]);
         NSLog(@"%@",[ei eye]);
         NSLog(@"FIX LIGHT %d",[[ei fixationLight] intValue]);
         
         UIImage *th = [UIImage imageWithData: ei.thumbnail];
         SelectableEyeImage *image = [[SelectableEyeImage alloc] initWithUIImage: uim
                                                                            date: ei.date
                                                                             eye: ei.eye
                                                                   fixationLight: ei.fixationLight.intValue
                                                                       thumbnail: th];

         image.coreDataImage = ei;
         [self.passedImages addObject: image];
             th = nil;
         }
         
         NSNumber* eyeImagesCount = [NSNumber numberWithInteger:[self.eyeImages count]];
  
         NSDictionary *extraInfo = [NSDictionary dictionaryWithObject:eyeImagesCount forKey:@"imagesLeft"];
         NSNotification *note = [NSNotification notificationWithName:@"SelectableEyeImageCreated" object:self userInfo:extraInfo];
         [[NSNotificationCenter defaultCenter] postNotification: note];
         
         ei = nil;
         uim = nil;
         
     }
            failureBlock:^(NSError *error)
     {
         
         NSLog(@"failure loading video/image from AssetLibrary");
     }];
}

-(void)createNextSelectableEyeImage:(NSNotification*)note{
    bool fired = FALSE;
    if ([self.eyeImages count]==0 && fired == FALSE){
        fired = TRUE;
        NSLog(@"Segue to ImageReview");
        
        [self performSegueWithIdentifier:@"ImageReviewSegue" sender:self];
    }
    else{
        [self createSelectableEyeImage];
    }
}

- (void)didSegmentedValueChanged:(id)sender {
    
    if(self.segControl.selectedSegmentIndex == 0)
        [[CellScopeContext sharedContext]setSelectedEye:OD_EYE];
    else if (self.segControl.selectedSegmentIndex == 1)
        [[CellScopeContext sharedContext]setSelectedEye:OS_EYE];
    
    [self loadImages ];
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"CamViewSegue"])
    {
        
        NSLog(@"Preparing for CamViewSegue");
        CamViewController* cvc = (CamViewController*)[segue destinationViewController];
        //[[[CellScopeContext sharedContext]bleManager]setBLECdelegate:cvc];
        cvc.fullscreeningMode = NO;
        cvc.selectedLight = self.selectedLight;
        
    }
    if ([[segue identifier] isEqualToString:@"FullScreeningSegue"]) //TODO: when is this used?
    {
        
        NSLog(@"Preparing for FullScreeningSegue");
        CamViewController* cvc = (CamViewController*)[segue destinationViewController];
        //[[[CellScopeContext sharedContext]bleManager]setBLECdelegate:cvc];
        cvc.fullscreeningMode = YES;
        cvc.selectedLight = self.selectedLight;
    }
    
    else if ([[segue identifier] isEqualToString:@"ImageReviewSegue"])
    {
        NSLog(@"Segue to ImageReview");
        ImageSelectionViewController * isvc = (ImageSelectionViewController*)[segue destinationViewController];
        
        isvc.reviewMode = YES;
        
        /*
        [passedImages removeAllObjects];
        
        
        NSPredicate *p = [NSPredicate predicateWithFormat: @"exam == %@ AND eye == %@ AND fixationLight == %d", [[CellScopeContext sharedContext]currentExam], self.selectedEye,
                           self.selectedLight];
    
        NSArray *temp = [CoreDataController searchObjectsForEntity:@"EyeImage" withPredicate: p
                                                        andSortKey: @"date" andSortAscending: YES
                                                        andContext: [[CellScopeContext sharedContext] managedObjectContext]];
        
        //NOTE THAT eyeImages DO NOT get passed over to ISVC, only EImages do!!!, So let's create some EImages
        self.eyeImages = [NSMutableArray arrayWithArray:temp];
        
        [self createSelectableEyeImage];
        
        
        NSLog(@"%lu",(unsigned long)[eyeImages count]);
        
        for( EyeImage* i in eyeImages){
            if(i){
                NSLog(@"%@",[i filePath]);
                NSLog(@"%@",[i date]);
                NSLog(@"%@",[i eye]);
                NSLog(@"FIX LIGHT %d",[[i fixationLight] intValue]);
                
                UIImage *im = [UIImage imageWithContentsOfFile: i.filePath]; //was commented out
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

         
                     NSNumber* obj = [NSNumber numberWithInteger:[imagesToUpload count]];
                     
                     NSDictionary *extraInfo = [NSDictionary dictionaryWithObject:obj forKey:@"imagesLeft"];
                     NSNotification *note = [NSNotification notificationWithName:@"OperationAdded" object:self userInfo:extraInfo];
                     [[NSNotificationCenter defaultCenter] postNotification: note];
         
        
                 }
                        failureBlock:^(NSError *error)
                 {

                     NSLog(@"failure loading video/image from AssetLibrary");
                 }];


                NSLog(@"What's the Fixation %@", i.fixationLight);
                
                UIImage *th = [UIImage imageWithData: i.thumbnail];
                             
                SelectableEyeImage *image = [[SelectableEyeImage alloc] initWithUIImage: th //was th
                                                        date: i.date
                                                         eye: i.eye
                                               fixationLight: i.fixationLight.intValue
                                                      thumbnail: th];
                image.coreDataImage = i;
                [passedImages addObject: image];
        
            }
            
        }
         */
    
        isvc.images = self.passedImages;
        self.passedImages = nil; //ugh
    }

}


-(void) setupFixationButtons{
    for(UIButton *button in self.fixationButtons){
        button.layer.cornerRadius = button.frame.size.width / 2;
        button.clipsToBounds = YES;
        button.layer.borderWidth = 2.0f;
        button.layer.borderColor = [UIColor pinkColor].CGColor;
        button.imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
}

- (IBAction)didPressBeginExam:(UIButton*)sender {
    self.selectedLight = sender.tag;
    [self performSegueWithIdentifier:@"FullScreeningSegue" sender:(id)sender];
}
@end
