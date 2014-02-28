//
//  FixationViewController.m
//  OcularCellscope
//
//  Created by PJ Loury on 2/27/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import "FixationViewController.h"
#import "CaptureViewController.h"
#import "CoreDataController.h"
#import "CameraAppDelegate.h"

@interface FixationViewController ()

@end

@implementation FixationViewController


@synthesize selectedEye, selectedLight, oldSegmentedIndex, actualSegmentedIndex;

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


}

-(void)viewWillAppear:(BOOL)animated{
    
    if(self.segmentedControl.selectedSegmentIndex == 0){
        //load the left images
        
        
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        request.entity = [NSEntityDescription entityForName:@"EyeImage" inManagedObjectContext: _managedObjectContext];
        request.predicate = [NSPredicate predicateWithFormat: @"eye == %@ AND fixationLight == %@", leftEye, centerLight];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
        request.fetchLimit = 1;
        
        NSError *error;
        
        NSArray *array = [_managedObjectContext executeFetchRequest:request error:&error];
        
        

        
        //request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
        //request.fetchLimit = 1;
        
        
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
