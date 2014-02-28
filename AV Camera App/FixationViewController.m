//
//  FixationViewController.m
//  OcularCellscope
//
//  Created by PJ Loury on 2/27/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import "FixationViewController.h"
#import "CaptureViewController.h"

@interface FixationViewController ()

@end

@implementation FixationViewController

@synthesize selectedEye, selectedLight, oldSegmentedIndex, actualSegmentedIndex;

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
}

-(void)viewWillAppear:(BOOL)animated{
    
    if(self.segmentedControl.selectedSegmentIndex == 0){
        //load the left images
        
        self.allImages = [CoreDataController getObjectsForEntity:@"Image" withSortKey:@"date" andSortAscending:NO
                                                      andContext: self.managedObjectContext ];

        
        
        
    }
    
    else{
        //load the images
        
    }
    //setImage
    
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
            self.selectedEye = centerLight;
            break;
    
        case 2:
            self.selectedEye = topLight;
            break;

    
        case 3:
            self.selectedEye = bottomLight;
            break;

        case 4:
            self.selectedEye = leftLight;
            break;
            
        case 5:
            self.selectedEye = rightLight;
            break;
            
        case 6:
            self.selectedEye = noLight;
            break;
            
    }

    
    [self performSegueWithIdentifier:@"captureViewSegue" sender:(id)sender];
    
    
}


- (IBAction)didSegmentedValueChanged:(id)sender {
    self.oldSegmentedIndex = self.actualSegmentedIndex;
    self.actualSegmentedIndex = self.segmentedControl.selectedSegmentIndex;
    
    
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"captureViewSegue"])
    {
        CaptureViewController* cvc = (CaptureViewController*)[segue destinationViewController];
        cvc.whichEye = self.selectedEye;
        cvc.whichLight = self.selectedLight;

    }
}


@end
