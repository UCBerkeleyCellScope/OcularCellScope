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
#import "CameraFocusSquare.h"

@interface CamViewController ()
@property (assign) SystemSoundID beepBeepSound;
@property (nonatomic) CameraFocusSquare* camFocus;
@property (nonatomic, assign) long selectedLight;
@property (nonatomic, strong) UIAlertView *nextFixationAlert;

@end

@implementation CamViewController

@synthesize beepBeepSound;
@synthesize camFocus;

@synthesize bleManager = _bleManager;
@synthesize captureManager  = _captureManager;
@synthesize currentImageCount = _currentImageCount;
@synthesize repeatingTimer = _repeatingTimer;
@synthesize waitForBle = _waitForBle;

@synthesize imageArray = _imageArray;
@synthesize captureButton = _captureButton;
@synthesize capturedImageView = _capturedImageView;
@synthesize aiv = _aiv;
@synthesize counterLabel = _counterLabel;
@synthesize bleDisabledLabel = _bleDisabledLabel;
@synthesize debugMode;
@synthesize mirroredView;
@synthesize fullscreeningMode = _fullscreeningMode;
@synthesize nextFixationAlert = _nextFixationAlert;
@synthesize fixationImageView = _fixationImageView;

@synthesize redOffIndicator;
@synthesize flashOffIndicator;

@synthesize tapGestureRecognizer;
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
    
    if(self.fullscreeningMode)
        self.selectedLight = CENTER_LIGHT;
    else
        self.selectedLight = self.bleManager.selectedLight;
    
    self.captureManager = [[AVCaptureManager alloc] init];
    self.captureManager.delegate = self;
    self.currentImageCount = 0;
    
    // Added gesture recognizer for taps to focus
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didReceiveTapToFocus:)];
    [self.view addGestureRecognizer:tapGestureRecognizer];

    longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressedToCapture:)];
    [self.view addGestureRecognizer:longPressGestureRecognizer];
    
    
    /// WHY IS THIS HERE>>>??? IN ORDER TO
    //GET TURN OFF/TURN ON TO WORK
    [[self.bleManager whiteFlashLight]toggleLight];
    
    self.imageArray = [[NSMutableArray alloc] init];
    
    [[CellScopeContext sharedContext] setCamViewLoaded:YES];
    
    
}

-(void) viewWillAppear:(BOOL)animated{
    [self.captureManager setupVideoForView:self.view];
    [self updateFixationImageView];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    [self.captureManager setExposureLock:NO];
    [self.captureManager unlockFocus];
    [self.captureManager unlockWhiteBalance];
    
    [self setupIndicators];
    
    self.debugMode = [[NSUserDefaults standardUserDefaults] boolForKey:@"debugMode"];
    self.mirroredView = [[NSUserDefaults standardUserDefaults] boolForKey:@"mirroredView"];

    /*
    if(mirroredView == YES){
        self.capturedImageView.transform = CGAffineTransformMakeRotation(M_PI);
    }
    else{
        self.capturedImageView.transform = CGAffineTransformMakeRotation(0);
    }
     */
    
    
    int fixationLightValue = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"fixationLightValue"];
    
    [self.bleDisabledLabel setHidden:YES];
    self.counterLabel.hidden = YES;
    
    [self.bleDisabledLabel setHidden:YES];
    [self.navigationItem setHidesBackButton:NO animated:YES];
    if(self.bleManager.isConnected== YES){
        //BLE disabled label needs to go away succesfully
        [self.bleManager.redFocusLight turnOn];
        [self.bleManager.whiteFocusLight turnOn];
        
        [[self.bleManager.fixationLights objectAtIndex: self.selectedLight]
         changeIntensity:fixationLightValue];
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
    [self.bleManager.fixationLights[self.bleManager.selectedLight] turnOff];
    [self.captureManager setExposureLock:NO];
    [self.captureManager unlockFocus];
    [self.captureManager unlockWhiteBalance];
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
    [self playSound:@"beepbeep.wav"];
    [self.captureButton setEnabled:NO];
    
    //[self.bleManager.fixationLights[self.bleManager.selectedLight] turnOn];

    [self.captureManager lockFocus];
    [self.captureManager lockWhiteBalance];
    
    [self.navigationItem setHidesBackButton:YES animated:YES];
    
    [self.bleManager turnOffAllLights];
    [self setExposureUsingLight];

    [self beginImageCapture];
    
}

- (void) beginImageCapture{
    NSNumber *interval = [[NSUserDefaults standardUserDefaults] objectForKey:@"captureDelay"];
    
    self.repeatingTimer = [NSTimer scheduledTimerWithTimeInterval:[interval doubleValue] target:self selector:@selector(captureTimerFired) userInfo:nil repeats:YES];

}

-(void) setExposureUsingLight{
    //THIS MIGHT BE A PROBLEM
    if(self.bleManager.debugMode==NO){
        NSLog(@"FOCUSING FLASH");
        //[self.bleManager.fixationLights[self.bleManager.selectedLight] turnOn];
        [self.bleManager.whiteFlashLight turnOn];
        [self.bleManager.redFlashLight turnOn];
        
        [NSThread sleepForTimeInterval: 0.4];//.4
        [self.captureManager setExposureLock:YES];
        //[NSThread sleepForTimeInterval: 0.1];//.3
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

        [self.bleManager.fixationLights[self.bleManager.selectedLight] turnOn];
        
        //if(timedFlash){
        //[self.bleManager timedFlash];
        //}
        
        //else{
        [self.bleManager arduinoFlash];
        //}
            
        [self.bleManager bleDelay];
        
        [self.bleManager.fixationLights[self.bleManager.selectedLight] turnOff];
        [self.captureManager takePicture];
        [self.bleManager.fixationLights[self.bleManager.selectedLight] turnOn];
    }
    else{
        [self.repeatingTimer invalidate];
        self.repeatingTimer = nil;
    }
}

-(void)didCaptureImageWithData:(NSData *)data{
    
    SelectableEyeImage *image;
    
    if(mirroredView){
        UIImage *sourceImage = [UIImage imageWithData:data];
        UIImage *flippedImage = [UIImage imageWithCGImage: sourceImage.CGImage
                                                    scale: sourceImage.scale
                                              orientation: UIImageOrientationLeft];
        
        float scaleFactor = [[NSUserDefaults standardUserDefaults] floatForKey:@"ImageScaleFactor"];
        UIImage *thumbnail = [flippedImage resizedImageWithScaleFactor:scaleFactor];
        
        image = [[SelectableEyeImage alloc] initWithUIImage: flippedImage
                                                       date: [NSDate date]
                                                        eye: [[CellScopeContext sharedContext] selectedEye]
                                              fixationLight: (int) self.selectedLight
                                                  thumbnail: thumbnail];
    }
    
    else{
        image = [[SelectableEyeImage alloc] initWithData:data
                                                    date: [NSDate date]
                                                     eye: [[CellScopeContext sharedContext] selectedEye]
                                           fixationLight: (int) self.selectedLight];
        
        float scaleFactor = [[NSUserDefaults standardUserDefaults] floatForKey:@"ImageScaleFactor"];
        image.thumbnail = [image resizedImageWithScaleFactor:scaleFactor];
    }
    
    NSLog(@"Save fixation light %ld", self.bleManager.selectedLight);
    NSLog(@"%@",[[CellScopeContext sharedContext]selectedEye]);
    
    self.capturedImageView.image = image;

    // Add the capture image to the image array
    [self.imageArray addObject:image];
    
    NSLog(@"Saved Image %lu!",(unsigned long)[self.imageArray count]);
    
    // Once all images are captured, segue to the Image Selection View
    int totalNumberOfImages = [[[NSUserDefaults standardUserDefaults] objectForKey:@"numberOfImages"] intValue];
    if(self.currentImageCount >= totalNumberOfImages){
        if(!self.fullscreeningMode){
            NSLog(@"About to segue to ImageSelectionSegue");
            [self performSegueWithIdentifier:@"ImageSelectionSegue" sender:self];
        }
        else
            [self didFinishCaptureRound];
    }
}


- (void) didFinishCaptureRound{
    if([self proceedToNextLight]){
        [self resetView];
        [self displayNextFixationView];
    }
    else{
        NSLog(@"About to segue to ImageSelectionSegue");
        [self performSegueWithIdentifier:@"ImageSelectionSegue" sender:self];
    }
}

- (void) displayNextFixationView{
    
    //NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2.0  target:self selector:@selector(beginImageCapture) userInfo:nil repeats:NO];
    self.nextFixationAlert = [[UIAlertView alloc] initWithTitle:@"Proceed to next fixation light?"
                                                   message:@""
                                                  delegate:self
                                         cancelButtonTitle:@"No"
                                         otherButtonTitles:@"Yes",nil];
    [self.nextFixationAlert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == self.nextFixationAlert){
        if(buttonIndex == 1){
            [self beginImageCapture];
        }
        else{
            NSLog(@"About to segue to ImageSelectionSegue");
            [self performSegueWithIdentifier:@"ImageSelectionSegue" sender:self];
        }
    }
}

- (void) resetView{
    self.capturedImageView.image = nil;
    self.currentImageCount = 0;
    [self updateCounterLabelText];
    [self updateFixationImageView];
    [self.repeatingTimer invalidate];
    self.repeatingTimer = nil;
}

- (BOOL) proceedToNextLight{
    self.selectedLight++;
    
    if(self.selectedLight > 4){
        return NO;
    }
    
    return YES;
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
    
    tapGestureRecognizer.enabled = NO;
    
    if(!self.captureManager.isCapturingImages){

        [self playSound:@"long-beep.wav"];
        CGPoint tapPoint = [sender locationInView:self.view];
        CGPoint focusPoint = CGPointMake(tapPoint.x/self.view.bounds.size.width, tapPoint.y/self.view.bounds.size.height);
        
        if(camFocus){
            camFocus = nil;
        }
        
        camFocus = [[CameraFocusSquare alloc]initWithFrame:CGRectMake(tapPoint.x-40, tapPoint.y-40, 80, 80)];
        
        //replace sublayer??
        
        [camFocus setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:camFocus];
        [camFocus setNeedsDisplay];
        
        /*
        [self.camFocus.layer removeAllAnimations];
        [self.view.layer removeAnimationForKey:@"opacity"];
        */
         
        //[self.view.layer.superlayer removeAllAnimations];
        
        NSLog(@"x = %f, y = %f",focusPoint.x,focusPoint.y);
        [self.captureManager setFocusWithPoint:focusPoint];
        
//        [self.longPressGestureRecognizer setEnabled: NO];
//        [self.captureButton setEnabled:NO];
        
        
    }
    tapGestureRecognizer.enabled = YES;

}

- (IBAction)longPressedToCapture:(id)sender {
    if (self.longPressGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        NSLog(@"OMG LONG PRESS");
        [self.longPressGestureRecognizer setEnabled:NO];
        [self didPressCapture:sender];
    }
}

-(void) playSound: (NSString*)name{
    NSString* path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:name];
    NSURL *soundURL = [NSURL fileURLWithPath:path];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &beepBeepSound);
    AudioServicesPlaySystemSound(self.beepBeepSound);
}

-(void) updateFixationImageView{
    
    switch(self.selectedLight){
            
        case CENTER_LIGHT:
            self.fixationImageView.image = [UIImage imageNamed:@"center.png"];
            break;
        case TOP_LIGHT:
            self.fixationImageView.image = [UIImage imageNamed:@"top.png"];
            break;
        case BOTTOM_LIGHT:
            self.fixationImageView.image = [UIImage imageNamed:@"bottom.png"];
            break;
        case LEFT_LIGHT:
            self.fixationImageView.image = [UIImage imageNamed:@"left.png"];
            break;
        case RIGHT_LIGHT:
            self.fixationImageView.image = [UIImage imageNamed:@"right.png"];
            break;
        case NO_LIGHT:
            self.fixationImageView.image = nil;
            break;
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
