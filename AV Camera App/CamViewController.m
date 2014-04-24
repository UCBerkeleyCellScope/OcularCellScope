//
//  CamViewController.m
//  OcularCellscope
//
//  Created by Chris Echanique on 4/17/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
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
@synthesize prefs = _prefs;

BOOL _debugMode;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    _bleManager = [[CellScopeContext sharedContext] bleManager];
    self.captureManager = [[AVCaptureManager alloc] init];
    self.captureManager.delegate = self;
    self.currentImageCount = 0;
    
    [[_bleManager whiteLight]toggleLight];
    
    _debugMode = [_prefs boolForKey:@"debugMode"];
    [_bleDisabledLabel setHidden:YES];
    self.counterLabel.hidden = YES;
    self.imageArray = [[NSMutableArray alloc] init];
    
    if (_bleManager.isConnected == NO && _debugMode == NO){
        NSLog(@"No connection yet, going to WAIT");
        [_aiv startAnimating];
        [_captureButton setEnabled:NO];
        //JUST WAIT FOR CONNECTION
    }
        
    else if (_debugMode == YES){
        [_aiv stopAnimating];
        [_captureButton setEnabled:YES];
        [_bleDisabledLabel setHidden:NO];
    }
    else{
        NSLog(@"Device is in Standard Mode");
    }
    
    [[CellScopeContext sharedContext] setCamViewLoaded:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.captureManager setupVideoForView:self.view];
    
}

-(void) viewWillAppear:(BOOL)animated{
    NSLog(@"APPEARED");
    if(_bleManager.isConnected== YES){
        [self.bleManager.redLight turnOn];
        [[self.bleManager.fixationLights objectAtIndex: self.bleManager.selectedLight] turnOn];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) didReceiveConnectionConfirmation{
    NSLog(@"The Connection Delegate was told that a Connection did occur");
    
    [_aiv stopAnimating];
    [_captureButton setEnabled:YES];
    [_bleDisabledLabel setHidden:YES];
}

-(void) didReceiveNoBLEConfirmation{
    NSLog(@"The Connection Delegate was told that no BLE could be found");
    [_aiv stopAnimating];
    [_captureButton setEnabled:YES];
}

-(void) didReceiveFlashConfirmation{
    NSLog(@"The Connection Delegate received a flash confirmation and is taking a picture");
    [self.captureManager takePicture];
    //Tell the Flash to Stay on for a certain amount of time
}


-(IBAction)didPressPause:(id)sender{
    [self.repeatingTimer invalidate];
}

- (IBAction)didPressCapture:(id)sender{
    NSLog(@"didPressCapture");
    [self.captureManager lockFocus];
    
    BOOL timedFlash = [[NSUserDefaults standardUserDefaults] boolForKey:@"timedFlash"];
    
    if(timedFlash == YES){
        NSNumber *interval = [[NSUserDefaults standardUserDefaults] objectForKey:@"captureDelay"];
        
        self.repeatingTimer = [NSTimer scheduledTimerWithTimeInterval:[interval doubleValue] target:self selector:@selector(captureTimerFired) userInfo:nil repeats:YES];
    }
    else{
        [self.bleManager.whitePing turnOn];
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
    
    NSLog(@"Saved Image %lu!",[self.imageArray count]);
    
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
