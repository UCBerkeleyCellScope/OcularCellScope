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
#import "ImageScrollViewController.h"

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
@synthesize selectedEye = _selectedEye;
@synthesize debugMode;
@synthesize redOffIndicator;
@synthesize flashOffIndicator;

@synthesize longPressGestureRecognizer;

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
    
    // Added gesture recognizer for taps to focus
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didReceiveTapToFocus:)];
    [self.view addGestureRecognizer:tapGestureRecognizer];

    longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressedToCapture:)];
    [self.view addGestureRecognizer:longPressGestureRecognizer];
    
    
    /// WHY IS THIS HERE>>>??? IN ORDER TO
    //GET TURN OFF/TURN ON TO WORK
    [[self.bleManager whiteFlashLight]toggleLight];
    
    //[self.captureManager unlockFocus];
    
    self.imageArray = [[NSMutableArray alloc] init];
    
    [[CellScopeContext sharedContext] setCamViewLoaded:YES];
    
    self.capturedImageView.layer.affineTransform = CGAffineTransformInvert(CGAffineTransformMakeRotation(M_PI));
}

-(void) viewWillAppear:(BOOL)animated{
    NSLog(@"APPEARED");
    [self.captureManager setupVideoForView:self.view];
    
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    [self.captureManager setExposureLock:NO];
    
    [self setupIndicators];
    
    self.debugMode = [[NSUserDefaults standardUserDefaults] boolForKey:@"debugMode"];
    
    int fixationLightValue = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"fixationLightValue"];
    
    [self.bleDisabledLabel setHidden:YES];
    self.counterLabel.hidden = YES;
    
    [self.bleDisabledLabel setHidden:YES];
    [self.navigationItem setHidesBackButton:NO animated:YES];
    if(self.bleManager.isConnected== YES){ //BLE disabled label needs to go away succesfully
        [self.bleManager.redFocusLight turnOn];
        [self.bleManager.whiteFocusLight turnOn];
        
        [[self.bleManager.fixationLights objectAtIndex: self.bleManager.selectedLight]
         changeIntensity:fixationLightValue];
         //turnOn];
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

-(void)viewWillDisappear:(BOOL)animated{
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

-(void) setupIndicators {
    int redVal = [[[NSUserDefaults standardUserDefaults] objectForKey:@"redFocusValue"]intValue];
    int flashVal =[[[NSUserDefaults standardUserDefaults] objectForKey:@"whiteFlashValue"]intValue];
    
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


/*
- (IBAction)tappedToFocus:(UITapGestureRecognizer *)sender {
    [self.captureButton setEnabled:NO];
    CGPoint focusPoint = [sender locationInView:self.view];
    //NSLog(@"x = %f  y = %f", focusPoint.x, focusPoint.y);
    [self.captureManager setFocusWithPoint:focusPoint];
    [self.captureButton setEnabled:YES];
}
*/





- (IBAction)didPressCapture:(id)sender{
    NSLog(@"didPressCapture");
    [self.captureButton setEnabled:NO];
    //[self.captureManager setExposureLock:YES];
    [self.captureManager lockFocus];
    [self.navigationItem setHidesBackButton:YES animated:YES];

    BOOL timedFlash = [[NSUserDefaults standardUserDefaults] boolForKey:@"timedFlash"];
    
    [self setExposureUsingWhiteLight];
    
    if(timedFlash == YES){
        NSNumber *interval = [[NSUserDefaults standardUserDefaults] objectForKey:@"captureDelay"];
        
        self.repeatingTimer = [NSTimer scheduledTimerWithTimeInterval:[interval doubleValue] target:self selector:@selector(captureTimerFired) userInfo:nil repeats:YES];
    }
    else{
        //[self.bleManager.whitePing turnOn];
        NSNumber *interval = [[NSUserDefaults standardUserDefaults] objectForKey:@"captureDelay"];
        
        self.repeatingTimer = [NSTimer scheduledTimerWithTimeInterval:[interval doubleValue] target:self selector:@selector(captureTimerFired) userInfo:nil repeats:YES];
    }
}

-(void) setExposureUsingWhiteLight{
    //THIS MIGHT BE A PROBLEM
    if(self.bleManager.debugMode==NO){
        NSLog(@"FOCUSING FLASH");
        [self.bleManager turnOffAllLights];
        [self.bleManager.whiteFlashLight turnOn];
        [self.bleManager.redFlashLight turnOn];
        
        [NSThread sleepForTimeInterval: .4];
        [self.captureManager setExposureLock:YES];
        [NSThread sleepForTimeInterval: .3];
        [self.bleManager.whiteFlashLight turnOff];
        [self.bleManager.redFlashLight turnOff];

    }
}
    
-(void)captureTimerFired{
    self.currentImageCount++;
    int totalNumberOfImages = [[[NSUserDefaults standardUserDefaults] objectForKey:@"numberOfImages"] intValue];
    if(self.currentImageCount <= totalNumberOfImages){
        [self updateCounterLabelText];
        // Timed flash or ping back
        
        BOOL timedFlash = [[NSUserDefaults standardUserDefaults] boolForKey:@"timedFlash"];

        if(timedFlash){
        [self.bleManager timedFlash];
        }
        
        ///>>>>?????
        else{
        [self.bleManager arduinoFlash];
        }
            
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
                                   fixationLight: _bleManager.selectedLight];
    self.capturedImageView.image = image;
    
    NSLog(@"%@",[[CellScopeContext sharedContext]selectedEye]);
    
    float scaleFactor = [[NSUserDefaults standardUserDefaults] floatForKey:@"ImageScaleFactor"];
    image.thumbnail = [image resizedImageWithScaleFactor:scaleFactor];
    // Add the capture image to the image array
    [self.imageArray addObject:image];
    
    NSLog(@"Saved Image %lu!",(unsigned long)[self.imageArray count]);
    
    // Once all images are captured, segue to the Image Selection View
    int totalNumberOfImages = [[[NSUserDefaults standardUserDefaults] objectForKey:@"numberOfImages"] intValue];
    if([self.imageArray count] >= totalNumberOfImages){
        NSLog(@"About to segue to ImageSelectionView");
//        [self performSegueWithIdentifier:@"ImageScrollSegue" sender:self];
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

- (IBAction)didReceiveTapToFocus:(id)sender {
    // Focuses camera if not currently capturing images
    if(!self.captureManager.isCapturingImages){
        CGPoint tapPoint = [sender locationInView:self.view];
        CGPoint focusPoint = CGPointMake(tapPoint.x/self.view.bounds.size.width, tapPoint.y/self.view.bounds.size.height);
        NSLog(@"x = %f, y = %f",focusPoint.x,focusPoint.y);
        [self.captureManager setFocusWithPoint:focusPoint];
    }
}

- (IBAction)longPressedToCapture:(id)sender {
    
    if (self.longPressGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        NSLog(@"OMG LONG PRESS");
        [self.longPressGestureRecognizer setEnabled:NO];
        [self didPressCapture:sender];
    }
   
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ImageSelectionSegue"])
        //@"ImageScrollSegue"
    {
        self.navigationController.navigationBar.alpha = 1;
        ImageSelectionViewController *isvc = (ImageSelectionViewController*)[segue destinationViewController];
//        ImageScrollViewController *isvc = (ImageScrollViewController*)[segue destinationViewController];
        isvc.images = self.imageArray;
        isvc.reviewMode = NO;
    }
}


@end
