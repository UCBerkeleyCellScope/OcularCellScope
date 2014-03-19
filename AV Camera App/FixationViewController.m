//
//  FixationViewController.m
//  OcularCellscope
//
//  Created by PJ Loury on 2/27/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import "FixationViewController.h"
#import "CaptureViewController.h"
#import "ImageSelectionViewController.h"
#import "CoreDataController.h"
#import "CameraAppDelegate.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface FixationViewController ()

@end

@implementation FixationViewController


@synthesize selectedEye, selectedLight, segmentedControl, oldSegmentedIndex, actualSegmentedIndex, imageArray;

//This is an EyeImage
@synthesize currentEyeImage;

//These are Buttons
@synthesize centerFixationButton, topFixationButton,
bottomFixationButton, leftFixationButton, rightFixationButton, noFixationButton;

@synthesize currentEImage, uim;


//This is an array of buttons
@synthesize fixationButtons;

@synthesize eyeImages;

@synthesize managedObjectContext= _managedObjectContext;
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
    
    CameraAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    _managedObjectContext = [appDelegate managedObjectContext];

    fixationButtons = [NSMutableArray arrayWithObjects: centerFixationButton, topFixationButton,
                                       bottomFixationButton, leftFixationButton, rightFixationButton, noFixationButton, nil];

    //[self loadImages: self.segmentedControl.selectedSegmentIndex];
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:(BOOL) animated];
    
    NSLog(@"Seg Back, even from ImageSelection");
    
    if (self.selectedEye){
        if ([self.selectedEye isEqualToString: LEFT_EYE]) [segmentedControl setSelectedSegmentIndex: 0];
        else if([self.selectedEye isEqualToString: LEFT_EYE]) [segmentedControl setSelectedSegmentIndex: 1];
    }
    else{
        [segmentedControl setSelectedSegmentIndex: 0];

    }
    
    [self loadImages: self.segmentedControl.selectedSegmentIndex];
    
}

-(void)loadImages:(NSInteger)segmentedIndex{
    
    if(self.segmentedControl.selectedSegmentIndex == 0){
        selectedEye = LEFT_EYE;
    }
    else{
        selectedEye = RIGHT_EYE;
    }
        //load the images
        for (int i = 1; i <= 6; i++)
        {
            //Attempt 3
            /*
             self.eyeImages = [CoreDataController getObjectsForEntity:@"EyeImage" withSortKey:@"date" andSortAscending:YES andContext:self.managedObjectContext];
            */
            
            
            NSPredicate *p = [NSPredicate predicateWithFormat: @"eye == %@ AND fixationLight == %d", selectedEye, i];
            
            
            NSArray *temp = [CoreDataController searchObjectsForEntity:@"EyeImage" withPredicate: p
                                                                                         andSortKey: @"date" andSortAscending: YES
                             
                                                            andContext: _managedObjectContext];
            
            self.eyeImages = [NSMutableArray arrayWithArray:temp];
            
            NSLog(@"For Fixation Light %d, %d images were Retrieved!", i, [eyeImages count]);
            
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
                UIImage* thumbImage = [UIImage imageNamed: @"img.jpeg"];
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
        //CaptureViewController *nextViewController = [[CaptureViewController alloc] init];
        //[self.navigationController pushViewController:nextViewController animated:YES];
        [self performSegueWithIdentifier:@"CaptureViewSegue" sender:(id)sender];
    
    }
    
    else if([sender isSelected] == YES ){
                //[self.navigationController pushViewController:nextViewController animated:YES];
        
        [self performSegueWithIdentifier:@"ImageReviewSegue" sender:(id)sender];
        
    }
    
}


- (IBAction)didSegmentedValueChanged:(id)sender {
    //self.oldSegmentedIndex = self.actualSegmentedIndex;
    //self.actualSegmentedIndex = self.segmentedControl.selectedSegmentIndex;
    
    [self loadImages: self.segmentedControl.selectedSegmentIndex];
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"CaptureViewSegue"])
    {
        NSLog(@"Preparing for CaptureViewSegue");
        CaptureViewController* cvc = (CaptureViewController*)[segue destinationViewController];
        cvc.selectedEye = self.selectedEye;
        cvc.selectedLight = self.selectedLight;
    }
    
    else if ([[segue identifier] isEqualToString:@"ImageReviewSegue"])
    {
        NSLog(@"Segue to ImageReview");
       ImageSelectionViewController * isvc = (ImageSelectionViewController*)[segue destinationViewController];
       isvc.selectedEye = self.selectedEye;
       isvc.selectedLight = self.selectedLight;
        
        NSPredicate *p = [NSPredicate predicateWithFormat: @"eye == %@ AND fixationLight == %d", self.selectedEye, self.selectedLight];
        
        
        NSArray *temp = [CoreDataController searchObjectsForEntity:@"EyeImage" withPredicate: p
                                                        andSortKey: @"date" andSortAscending: YES
                                                        andContext: _managedObjectContext];
        
        self.eyeImages = [NSMutableArray arrayWithArray:temp];
        
        NSLog(@"%lu",(unsigned long)[eyeImages count]);
        NSMutableArray* images = [[NSMutableArray alloc] init];
        
        for( EyeImage* i in eyeImages){
            if(i){
                NSLog(@"%@",[i filePath]);
                NSLog(@"%@",[i date]);
                NSLog(@"%@",[i eye]);
                NSLog(@"%ld",(long)[i fixationLight]);

                //UIImage *im = [UIImage imageWithContentsOfFile: i.filePath];
                
                //Let's get an image!
                
                
                NSURL *aURL = [NSURL URLWithString: i.filePath];
                
                NSLog(@"displaying image at: %@",i.filePath);
                
                ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                [library assetForURL:aURL resultBlock:^(ALAsset *asset)
                 {
                     ALAssetRepresentation* rep = [asset defaultRepresentation];
                     CGImageRef iref = [rep fullResolutionImage];
                     
                     UIImage *uim = [UIImage imageWithCGImage:iref];
                     
                 }
                        failureBlock:^(NSError *error)
                 {
                     // error handling
                     NSLog(@"failure loading video/image from AssetLibrary");
                 }];

                /*
                currentEImage.date = i.date;
                currentEImage.eye = i.eye;
                currentEImage.fixationLight = i.fixationLight;
                */
                NSLog(@"What's the Fixation %@", i.fixationLight);
                
                
                
                //NSData* d = [NSData dataWithContentsOfFile: i.filePath];
                
                NSData *d = UIImagePNGRepresentation(uim);
                NSLog(d);
                             
                EImage *image = [[EImage alloc] initWithData: d
                                                        date: i.date
                                                         eye: i.eye
                                               fixationLight: i.fixationLight];
                NSLog(@"does it make it here");
                NSLog(image);
                
                
                
                [images addObject: currentEImage];
                NSLog(@"OR it make it here");
            }
         //NSLog(@"%lu",(unsigned long)[images count]);
        }
        
        isvc.images = images;
    }

}


@end
