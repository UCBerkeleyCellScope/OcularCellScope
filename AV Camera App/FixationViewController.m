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

@interface FixationViewController ()

@end

@implementation FixationViewController


@synthesize selectedEye, selectedLight, oldSegmentedIndex, actualSegmentedIndex;
@synthesize leftEyeImage;
@synthesize centerFixationButton, topFixationButton,
bottomFixationButton, leftFixationButton, rightFixationButton, noFixationButton;
@synthesize fixationButtons;

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

    [self loadImages: self.segmentedControl.selectedSegmentIndex];
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:(BOOL) animated];
    
    //ONLY RELOAD IF ITS CHANGED
    [self loadImages: self.segmentedControl.selectedSegmentIndex];
    
}

-(void)loadImages:(NSInteger)segmentedIndex{
    
    if(self.segmentedControl.selectedSegmentIndex == 0){
        selectedEye = leftEye;
    }
    else{
        selectedEye = rightEye;
    }
        //load the images
        for (int i = 1; i <= 6; i++)
        {
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            
            request.entity = [NSEntityDescription entityForName:@"EyeImage" inManagedObjectContext: _managedObjectContext];
            request.predicate = [NSPredicate predicateWithFormat: @"eye == %@ AND fixationLight == %d", selectedEye, i];
            request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
            request.fetchLimit = 1;
            NSError *error;
            
            NSArray *array = [_managedObjectContext executeFetchRequest:request error:&error];
            
            if(array[0]!=nil){
                leftEyeImage = array[0];
                UIImage* thumbImage = [UIImage imageWithData: leftEyeImage.thumbnail];
                [fixationButtons[i-1] setImage: thumbImage forState:UIControlStateNormal];
                [fixationButtons[i-1] setSelected: YES];
            }
            else{
                UIImage* thumbImage = [UIImage imageNamed: @"Icon.png"];
                [fixationButtons[i-1] setImage: thumbImage];
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
    
    switch ([sender tag])
    {
        case 1:
            self.selectedLight = centerLight;
            break;
    
        case 2:
            self.selectedLight = topLight;
            break;

        case 3:
            self.selectedLight = bottomLight;
            break;

        case 4:
            self.selectedLight = leftLight;
            break;
            
        case 5:
            self.selectedLight = rightLight;
            break;
            
        case 6:
            self.selectedLight = noLight;
            break;
            
    }
    
    if( [sender isSelected] == YES){
    //there are pictures!
        [self performSegueWithIdentifier:@"captureViewSegue" sender:(id)sender];
    }
    
    else if([sender isSelected] == NO ){
        [self performSegueWithIdentifier:@"imageSelectionSegue" sender:(id)sender];
        
    }
    
    
    
}


- (IBAction)didSegmentedValueChanged:(id)sender {
    //self.oldSegmentedIndex = self.actualSegmentedIndex;
    //self.actualSegmentedIndex = self.segmentedControl.selectedSegmentIndex;
    
    [self loadImages: self.segmentedControl.selectedSegmentIndex];
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"captureViewSegue"])
    {
        CaptureViewController* cvc = (CaptureViewController*)[segue destinationViewController];
        cvc.whichEye = self.selectedEye;
        cvc.whichLight = self.selectedLight;
    }
    
    else if ([[segue identifier] isEqualToString:@"imageSelectionSegue"])
    {
        ImageSelectionViewController * isvc = (ImageSelectionViewController*)[segue destinationViewController];
        isvc.whichEye = self.selectedEye;
        isvc.whichLight = self.selectedLight;
    }

}


@end
