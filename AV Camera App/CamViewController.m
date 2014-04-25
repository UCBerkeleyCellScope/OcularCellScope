//
//  CamViewController.m
//  OcularCellscope
//
//  Created by Chris Echanique on 4/17/14.
//  Copyright (c) 2014 UC Berkeley Ocular CellScope. All rights reserved.
//

#import "CamViewController.h"
#import "UIImage+Resize.h"
#import "ImageSelectionViewController.h"

@interface CamViewController ()

@end

@implementation CamViewController

@synthesize bleManager = _bleManager;
@synthesize captureManager  = _captureManager;
@synthesize currentImageCount = _currentImageCount;
@synthesize repeatingTimer = _repeatingTimer;
@synthesize waitForBle = _waitForBle;

@synthesize imageArray = _imageArray;
@synthesize captureButton = _captureButton;
@synthesize settingsButton = _settingsButton;
@synthesize capturedImageView = _capturedImageView;
@synthesize aiv = _aiv;
@synthesize counterLabel = _counterLabel;
@synthesize bleDisabledLabel = _bleDisabledLabel;
@synthesize selectedLight = _selectedLight;
@synthesize selectedEye = _selectedEye;
@synthesize debugMode;
@synthesize redOffIndicator;
@synthesize flashOffIndicator;


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
    self.bleManager = [[CellScopeContext sharedContext] bleManager];
    self.captureManager = [[AVCaptureManager alloc] init];
    self.captureManager.delegate = self;
    self.currentImageCount = 0;
    
    [[self.bleManager whiteLight]toggleLight];
    

    //[self.captureManager unlockFocus];
    
    self.imageArray = [[NSMutableArray alloc] init];
    
    
    [[CellScopeContext sharedContext] setCamViewLoaded:YES];
    
    [self.captureManager setupVideoForView:self.view];
}

-(void) viewWillAppear:(BOOL)animated{
    NSLog(@"APPEARED");
    [self.captureManager setExposureLock:NO];
    
    [self setupIndicators];
    
    self.debugMode = [[NSUserDefaults standardUserDefaults] boolForKey:@"debugMode"];
    
    
    [self.bleDisabledLabel setHidden:YES];
    self.counterLabel.hidden = YES;
    
    [self.bleDisabledLabel setHidden:YES];
    [self.navigationItem setHidesBackButton:NO animated:YES];
    if(self.bleManager.isConnected== YES){ //BLE disabled label needs to go away succesfully
        [self.bleManager.redLight turnOn];
        [[self.bleManager.fixationLights objectAtIndex: self.bleManager.selectedLight] turnOn];
    }
    
    if (self.bleManager.isConnected == NO && self.debugMode == NO){
        NSLog(@"No connection yet, going to WAIT");
        [self.aiv startAnimating];
        [self.captureButton setEnabled:NO];
        //JUST WAIT FOR CONNECTION
    }
    
    else if (self.debugMode == YES){
        [self.aiv stopAnimating];
        [self.bleDisabledLabel setHidden:NO];
    }
    else{
        NSLog(@"Device is in Standard Mode");
    }

}

-(void) setupIndicators {
    int redVal = [[[NSUserDefaults standardUserDefaults] objectForKey:@"redLightValue"]intValue];
    int flashVal =[[[NSUserDefaults standardUserDefaults] objectForKey:@"flashLightValue"]intValue];
    
    if (redVal==0){
        [redOffIndicator setHidden:NO];
    }
    else
        [redOffIndicator setHidden:YES];
    if (flashVal==0){
        [flashOffIndicator setHidden:NO];
    }
    else
        [flashOffIndicator setHidden:YES];
}

    
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) didReceiveConnectionConfirmation{
    NSLog(@"The Connection Delegate was told that a Connection did occur");
    
    [self.aiv stopAnimating];
    [self.captureButton setEnabled:YES];
    [self.bleDisabledLabel setHidden:YES];
}

-(void) didReceiveNoBLEConfirmation{
    NSLog(@"The Connection Delegate was told that no BLE could be found");
    [self.aiv stopAnimating];
    [self.captureButton setEnabled:YES];
    [self.bleDisabledLabel setHidden:NO];
}

-(void) didReceiveFlashConfirmation{
    NSLog(@"The Connection Delegate received a flash confirmation and is taking a picture");
    [self.captureManager takePicture];
    //Tell the Flash to Stay on for a certain amount of time
}


-(IBAction)didPressPause:(id)sender{
    [self.repeatingTimer invalidate];
    [self.captureManager setExposureLock:NO];
    [self.captureManager lockFocus];
    [self.captureButton setEnabled:YES];
}

- (IBAction)tappedToFocus:(UITapGestureRecognizer *)sender {
    CGPoint focusPoint = [sender locationInView:self.view];
    NSLog(@"x = %f  y = %f", focusPoint.x, focusPoint.y);
    [self.captureManager setFocusWithPoint:focusPoint];
}

- (IBAction)didPressCapture:(id)sender{
    NSLog(@"didPressCapture");
    [self.captureButton setEnabled:NO];
    //[self.captureManager setExposureLock:YES];
    [self.captureManager lockFocus];
    [self.navigationItem setHidesBackButton:YES animated:YES];

    BOOL timedFlash = [[NSUserDefaults standardUserDefaults] boolForKey:@"timedFlash"];
    
    [self focusingFlash];
    
    if(timedFlash == YES){
        NSNumber *interval = [[NSUserDefaults standardUserDefaults] objectForKey:@"captureDelay"];
        
        self.repeatingTimer = [NSTimer scheduledTimerWithTimeInterval:[interval doubleValue] target:self selector:@selector(captureTimerFired) userInfo:nil repeats:YES];
    }
    else{
        [self.bleManager.whitePing turnOn];
    }
}

-(void) focusingFlash{
    if(self.bleManager.debugMode==NO){
        NSLog(@"FOCUSING FLASH");
        [self.bleManager.whiteLight turnOn];
        [NSThread sleepForTimeInterval: .6];
        [self.captureManager setExposureLock:YES];
        [NSThread sleepForTimeInterval: .3];
        [self.bleManager.whiteLight turnOff];
    }
}
    
-(void)captureTimerFired{
    self.currentImageCount++;
    int totalNumberOfImages = [[[NSUserDefaults standardUserDefaults] objectForKey:@"numberOfImages"] intValue];
    if(self.currentImageCount <= totalNumberOfImages){
        [self updateCounterLabelText];
        // Timed flash or ping back
        [self.bleManager timedFlash];
        [self.bleManager bleDelay];
        
        //self.waitForBle = [NSTimer scheduledTimerWithTimeInterval:[bleDelay doubleValue] target:self selector:@selector(readyToTakePicture) userInfo:nil repeats:NO];
        [self.captureManager takePicture];
    }
    else{
        [self.repeatingTimer invalidate];
        self.repeatingTimer = nil;
    }
}


-(void) readyToTakePicture{
    [self.captureManager takePicture];
}


-(void)didCaptureImageWithData:(NSData *)data{
    EImage *image = [[EImage alloc] initWithData:  data
                                            date: [NSDate date]
                                             eye: [[CellScopeContext sharedContext] selectedEye]
                                   fixationLight: self.selectedLight];
    self.capturedImageView.image = image;
    
    float scaleFactor = [[NSUserDefaults standardUserDefaults] floatForKey:@"ImageScaleFactor"];
    image.thumbnail = [image resizedImageWithScaleFactor:scaleFactor];
    // Add the capture image to the image array
    [self.imageArray addObject:image];
    
    NSLog(@"Saved Image %lu!",(unsigned long)[self.imageArray count]);
    
    // Once all images are captured, segue to the Image Selection View
    int totalNumberOfImages = [[[NSUserDefaults standardUserDefaults] objectForKey:@"numberOfImages"] intValue];
    if([self.imageArray count] >= totalNumberOfImages){
        NSLog(@"About to segue to ImageSelectionView");
        [self performSegueWithIdentifier:@"ImageSelectionSegue" sender:self];
        
    }
}

-(void)updateCounterLabelText{
    self.counterLabel.hidden = NO;
    if(self.currentImageCount < 10)
        self.counterLabel.text = [NSString stringWithFormat:@"0%d",self.currentImageCount];
    else
        self.counterLabel.text = [NSString stringWithFormat:@"%d",self.currentImageCount];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ImageSelectionSegue"])
    {
        self.navigationController.navigationBar.alpha = 1;
        ImageSelectionViewController *isvc = (ImageSelectionViewController*)[segue destinationViewController];
        isvc.images = self.imageArray;
        isvc.reviewMode = NO;
    }
}


@end
