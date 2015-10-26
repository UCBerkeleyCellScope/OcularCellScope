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
#import "UIImage+Resize.h"

#import "RetinalStitcherInterface.h"

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
    
    fixationButtons = [NSMutableArray arrayWithObjects: self.stitchButton, centerFixationButton, topFixationButton,
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
    
    self.stitchButton.layer.cornerRadius = 15;
    self.stitchButton.clipsToBounds = YES;
    self.autoButton.layer.cornerRadius = 15;
    self.autoButton.clipsToBounds = YES;
    
    //[_bleManager turnOffAllLights];
    
    NSLog(@"CSContext SelectedEye: %d",[[CellScopeContext sharedContext]selectedEye]);
    [self initSegControl];
    [self loadImages];
    
    //not best place for this
    TabViewController* tvc = (TabViewController*)self.tabBarController;
    if ([[CellScopeContext sharedContext] currentExam].eyeImages.count>0) {
        tvc.uploadButton.enabled = YES;
        tvc.uploadButton.title = @"Upload";
    }
    else {
        tvc.uploadButton.enabled = NO;
        tvc.uploadButton.title = @"";
    }
    
    CSLog(@"Fixation view presented", @"USER");
    
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

            
            NSArray *temp = [CoreDataController searchObjectsForEntity:@"EyeImage" withPredicate: p
                                                            andSortKey: @"date" andSortAscending: YES
                                                            andContext:   [[CellScopeContext sharedContext] managedObjectContext]];
            
            self.eyeImages = [NSMutableArray arrayWithArray:temp];
        
            
            if([eyeImages count] != 0){
                currentEyeImage = eyeImages[0];
                
                if (i>0) { //don't do this for the stitched image button
                    UIImage* thumbImage = [UIImage imageWithData: currentEyeImage.thumbnail];
                    [fixationButtons[i] setImage: thumbImage forState:UIControlStateSelected];
                    [fixationButtons[i] setImage: thumbImage forState:UIControlStateNormal];
                    [(UIButton*)fixationButtons[i] setTransform: CGAffineTransformMakeRotation(M_PI)]; //added to rotate thumbnails
                }
                
                [fixationButtons[i] setSelected: YES]; //this will tell the button press handler that this has photos

            }
            else{
                if (i>0) {
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
                }
                
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
    NSString* logmsg = [NSString stringWithFormat:@"Selected fixation light %d",self.selectedLight];
    CSLog(logmsg, @"USER");
    
    
    if( [sender isSelected] == NO){
        if ([sender tag]==0)
            [self stitch];
        else
            [self performSegueWithIdentifier:@"CamViewSegue" sender:(id)sender];
    }
    
    else if([sender isSelected] == YES ){
        //there are pictures!
        //[self performSegueWithIdentifier:@"ImageReviewSegue" sender:(id)sender];
        
        if ([sender tag]==0) {
            self.fixationAlert = [[UIAlertView alloc] initWithTitle:@"Would you like to stitch again or review previously stitched image?"
                                                            message:@""
                                                           delegate:self
                                                  cancelButtonTitle:@"Review"
                                                  otherButtonTitles:@"Stitch",nil];
        }
        else {
            self.fixationAlert = [[UIAlertView alloc] initWithTitle:@"Would you like to review existing images or add new ones?"
                                                            message:@""
                                                           delegate:self
                                                  cancelButtonTitle:@"Review"
                                                  otherButtonTitles:@"Add",nil];
        }
        [self.fixationAlert show];
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == self.fixationAlert){
        if(buttonIndex == 1){
            //Index 1 Selected
            if ([[self.fixationAlert buttonTitleAtIndex:1] isEqualToString:@"Stitch"]) {
                [self stitch];
            }
            else
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
    
    NSString* logmsg = [NSString stringWithFormat:@"Reviewing images for eye %@ and region %d",eyeString,self.selectedLight];
    CSLog(logmsg, @"USER");
    
    
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
         
         CSLog(@"failure loading video/image from AssetLibrary",@"ERROR");
     }];
}

-(void)createNextSelectableEyeImage:(NSNotification*)note{
    bool fired = FALSE;
    if ([self.eyeImages count]==0 && fired == FALSE){
        fired = TRUE;
        
        [self performSegueWithIdentifier:@"ImageReviewSegue" sender:self];
    }
    else{
        [self createSelectableEyeImage];
    }
}

- (void)didSegmentedValueChanged:(id)sender {
    
    if(self.segControl.selectedSegmentIndex == 0) {
        [[CellScopeContext sharedContext]setSelectedEye:OD_EYE];
        CSLog(@"OD Selected",@"USER");
    }
    else if (self.segControl.selectedSegmentIndex == 1) {
        [[CellScopeContext sharedContext]setSelectedEye:OS_EYE];
        CSLog(@"OS Selected",@"USER");
    }
    
    [self loadImages ];
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"CamViewSegue"])
    {
        
        CamViewController* cvc = (CamViewController*)[segue destinationViewController];
        //[[[CellScopeContext sharedContext]bleManager]setBLECdelegate:cvc];
        
        //"99" is the tag given to the auto scan button. When this is pressed, it will
        //tell the CamViewController to start at fixation #1 (central), and automatically take one
        //image from each quadrant.
        if (self.selectedLight==99) {
            cvc.selectedLight = 1; //this will start the acquisition on the central light
            cvc.automaticallyCycleThroughFixationLights = YES;
        }
        else
            cvc.selectedLight = self.selectedLight;
        
    }
    else if ([[segue identifier] isEqualToString:@"ImageReviewSegue"])
    {
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
    
    //make the auto button look like the others too...
    self.autoButton.layer.cornerRadius = self.autoButton.frame.size.width / 2;
    self.autoButton.clipsToBounds = YES;
    self.autoButton.layer.borderWidth = 2.0f;
    self.autoButton.layer.borderColor = [UIColor pinkColor].CGColor;
    self.autoButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
}

- (IBAction)didPressBeginExam:(UIButton*)sender {
    self.selectedLight = sender.tag;
    [self performSegueWithIdentifier:@"CamViewSegue" sender:(id)sender];
}


//this is a quick and dirty way to implement stitching. it just queries core data, gets the earliest
//image taken for each fixation light, loads it as a UIImage, and then passes it on to the C++ stitching
//algorithm
- (void)stitch {
    
    NSString* eyeString;
    if ([[CellScopeContext sharedContext] selectedEye] == 1)
        eyeString = @"OD";
    else
        eyeString = @"OS";

    NSString* logmsg = [NSString stringWithFormat:@"Generating stitched image for exam %@ and eye %@",[[[CellScopeContext sharedContext]currentExam] patientID],eyeString];
    CSLog(logmsg, @"USER");
    
    
    NSPredicate *predicate;
    NSArray* coreDataResults;
    __block UIImage* centerImage;
    __block UIImage* leftImage;
    __block UIImage* rightImage;
    __block UIImage* topImage;
    __block UIImage* bottomImage;
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    //center image
    predicate = [NSPredicate predicateWithFormat: @"exam == %@ AND eye == %@ AND fixationLight == 1", [[CellScopeContext sharedContext]currentExam], eyeString];
    coreDataResults = [CoreDataController searchObjectsForEntity:@"EyeImage" withPredicate: predicate
                                                    andSortKey: @"date" andSortAscending: YES
                                                    andContext: [[CellScopeContext sharedContext] managedObjectContext]];
    if (coreDataResults.count>0) {
        EyeImage* ei = [coreDataResults objectAtIndex:0]; //get the earliest image taken (later we'll let the user choose)
        [library assetForURL:[NSURL URLWithString: ei.filePath] resultBlock:^(ALAsset *asset)
         {
             NSLog(@"fetching center");
             CGImageRef iref = [[asset defaultRepresentation] fullResolutionImage];
             centerImage = [UIImage imageWithCGImage:iref];
         }
         failureBlock:^(NSError *error)
         {
             
             CSLog(@"failure loading video/image from AssetLibrary",@"ERROR");
         }];
    }
    
    //top image
    predicate = [NSPredicate predicateWithFormat: @"exam == %@ AND eye == %@ AND fixationLight == 2", [[CellScopeContext sharedContext]currentExam], eyeString];
    coreDataResults = [CoreDataController searchObjectsForEntity:@"EyeImage" withPredicate: predicate
                                                      andSortKey: @"date" andSortAscending: YES
                                                      andContext: [[CellScopeContext sharedContext] managedObjectContext]];
    if (coreDataResults.count>0) {
        EyeImage* ei = [coreDataResults objectAtIndex:0]; //get the earliest image taken (later we'll let the user choose)
        [library assetForURL:[NSURL URLWithString: ei.filePath] resultBlock:^(ALAsset *asset)
         {
             NSLog(@"fetching top");
             CGImageRef iref = [[asset defaultRepresentation] fullResolutionImage];
             topImage = [UIImage imageWithCGImage:iref];
         }
                failureBlock:^(NSError *error)
         {
             
             CSLog(@"failure loading video/image from AssetLibrary",@"ERROR");
         }];
    }
    
    //bottom image
    predicate = [NSPredicate predicateWithFormat: @"exam == %@ AND eye == %@ AND fixationLight == 3", [[CellScopeContext sharedContext]currentExam], eyeString];
    coreDataResults = [CoreDataController searchObjectsForEntity:@"EyeImage" withPredicate: predicate
                                                      andSortKey: @"date" andSortAscending: YES
                                                      andContext: [[CellScopeContext sharedContext] managedObjectContext]];
    if (coreDataResults.count>0) {
        EyeImage* ei = [coreDataResults objectAtIndex:0]; //get the earliest image taken (later we'll let the user choose)
        [library assetForURL:[NSURL URLWithString: ei.filePath] resultBlock:^(ALAsset *asset)
         {
             NSLog(@"fetching bottom");
             CGImageRef iref = [[asset defaultRepresentation] fullResolutionImage];
             bottomImage = [UIImage imageWithCGImage:iref];
         }
                failureBlock:^(NSError *error)
         {
             
             CSLog(@"failure loading video/image from AssetLibrary",@"ERROR");
         }];
    }
    
    //left image
    predicate = [NSPredicate predicateWithFormat: @"exam == %@ AND eye == %@ AND fixationLight == 4", [[CellScopeContext sharedContext]currentExam], eyeString];
    coreDataResults = [CoreDataController searchObjectsForEntity:@"EyeImage" withPredicate: predicate
                                                      andSortKey: @"date" andSortAscending: YES
                                                      andContext: [[CellScopeContext sharedContext] managedObjectContext]];
    if (coreDataResults.count>0) {
        EyeImage* ei = [coreDataResults objectAtIndex:0]; //get the earliest image taken (later we'll let the user choose)
        [library assetForURL:[NSURL URLWithString: ei.filePath] resultBlock:^(ALAsset *asset)
         {
             NSLog(@"fetching left");
             CGImageRef iref = [[asset defaultRepresentation] fullResolutionImage];
             leftImage = [UIImage imageWithCGImage:iref];
         }
                failureBlock:^(NSError *error)
         {
             
             CSLog(@"failure loading video/image from AssetLibrary",@"ERROR");
         }];
    }
    
    
    //right image
    predicate = [NSPredicate predicateWithFormat: @"exam == %@ AND eye == %@ AND fixationLight == 5", [[CellScopeContext sharedContext]currentExam], eyeString];
    coreDataResults = [CoreDataController searchObjectsForEntity:@"EyeImage" withPredicate: predicate
                                                      andSortKey: @"date" andSortAscending: YES
                                                      andContext: [[CellScopeContext sharedContext] managedObjectContext]];
    if (coreDataResults.count>0) {
        EyeImage* ei = [coreDataResults objectAtIndex:0]; //get the earliest image taken (later we'll let the user choose)
        [library assetForURL:[NSURL URLWithString: ei.filePath] resultBlock:^(ALAsset *asset)
         {
             NSLog(@"fetching right");
             CGImageRef iref = [[asset defaultRepresentation] fullResolutionImage];
             rightImage = [UIImage imageWithCGImage:iref];
         }
                failureBlock:^(NSError *error)
         {
             
             CSLog(@"failure loading video/image from AssetLibrary",@"ERROR");
         }];
    }
    
    //display an activity indicator
    UIView *grayScreen = [[UIView alloc] initWithFrame:self.view.window.frame];
    grayScreen.backgroundColor = [UIColor blackColor];
    grayScreen.alpha = 0.3;
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activity.center = self.view.window.center;
    [activity startAnimating];
    [self.view.window addSubview:grayScreen];
    [self.view.window addSubview:activity];

    //do the stitching
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
        
        //give it some time to return all these images from AL (kludge!)
        [NSThread sleepForTimeInterval:5.0];
        
        //run stitching algorithm and return resulting image
        RetinalStitcherInterface* rsi = [[RetinalStitcherInterface alloc] init];
        rsi.centerImage = centerImage;
        rsi.topImage = topImage;
        rsi.bottomImage = bottomImage;
        rsi.leftImage = leftImage;
        rsi.rightImage = rightImage;
        
        UIImage* stitchedResult = [rsi stitch];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //turn this stitched image into a SelectableEyeImage object with fixationlight = 0
            SelectableEyeImage* sei = [[SelectableEyeImage alloc] initWithUIImage:stitchedResult
                                                                             date:[NSDate date]
                                                                              eye:eyeString
                                                                    fixationLight:0
                                                                        thumbnail:[stitchedResult resizedImageWithScaleFactor:[[NSUserDefaults standardUserDefaults] floatForKey:@"ImageScaleFactor"]]];
            
            NSLog(@"stitched width = %d, height = %d",sei.size.width,sei.size.height);
            
            //remove activity indicator
            [activity stopAnimating];
            [grayScreen removeFromSuperview];
            [activity removeFromSuperview];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            ImageSelectionViewController *isvc = [storyboard instantiateViewControllerWithIdentifier:@"ImageSelectionViewController"];
            
            isvc.images = [NSArray arrayWithObjects:sei,nil];
            isvc.reviewMode = NO;
            [self.navigationController pushViewController:isvc animated:YES];
            
            
            NSLog(@"stitching complete");
        });
        
    });
    
 
    
}

@end
