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
#import "Constants.h"
#import "EImage.h"


@interface FixationViewController ()

@end

@implementation FixationViewController


@synthesize selectedEye, segmentedControl, selectedLight, oldSegmentedIndex, actualSegmentedIndex;

//This is an EyeImage
@synthesize leftEyeImage;

//These are Buttons
@synthesize centerFixationButton, topFixationButton,
bottomFixationButton, leftFixationButton, rightFixationButton, noFixationButton;

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
    
    //ONLY RELOAD IF ITS CHANGED
    
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
            else if([eyeImages count] != 0){
                leftEyeImage = eyeImages[0];
                UIImage* thumbImage = [UIImage imageWithData: leftEyeImage.thumbnail];
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
    
    [self performSegueWithIdentifier:@"CaptureViewSegue" sender:(id)sender];
    
    /*
    if( [sender isSelected] == NO){
        //there are pictures!
        CaptureViewController *nextViewController = [[CaptureViewController alloc] initWithNibName:nil bundle:nil];
        
        [self.navigationController pushViewController:nextViewController animated:YES];
    
    }
    
    else if([sender isSelected] == YES ){
        
        ImageSelectionViewController *nextViewController = [[ImageSelectionViewController alloc] initWithNibName:nil bundle:nil];
        
        [self.navigationController pushViewController:nextViewController animated:YES];
        //[self performSegueWithIdentifier:@"imageSelectionSegue" sender:(id)sender];
        
    }
     */
    
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
    
    else if ([[segue identifier] isEqualToString:@"ImageSelectionSegue"])
    {
        ImageSelectionViewController * isvc = (ImageSelectionViewController*)[segue destinationViewController];
       isvc.selectedEye = self.selectedEye;
       isvc.selectedLight = self.selectedLight;
    }

}


@end
