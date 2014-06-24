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
@property (nonatomic, strong) UIAlertView *nextFixationAlert;

@end

@implementation CamViewController

@synthesize beepBeepSound;
@synthesize camFocus;

//@synthesize bleManager = _bleManager;
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
    /*
    self.bleManager = [[CellScopeContext sharedContext] bleManager];
    
    if(self.fullscreeningMode)
        self.selectedLight = CENTER_LIGHT;
    else
        self.selectedLight = self.bleManager.selectedLight;
    */
    
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
    //[[self.bleManager whiteFlashLight]toggleLight];
    
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
    
    
    //int fixationLightValue = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"fixationLightValue"];
    
    self.counterLabel.hidden = YES;
    [self.bleDisabledLabel setHidden:YES];
    [self.navigationItem setHidesBackButton:NO animated:YES];
    
    //TODO: handle connection
    
    //turn on focus light and fixation light
    int whiteIntensity = [[NSUserDefaults standardUserDefaults] integerForKey:@"whiteFocusValue"];
    int redIntensity = [[NSUserDefaults standardUserDefaults] integerForKey:@"redFocusValue"];
    int fixationIntensity = [[NSUserDefaults standardUserDefaults] integerForKey:@"fixationLightValue"];
    
    [[[CellScopeContext sharedContext] bleManager] setIlluminationWhite:whiteIntensity Red:redIntensity];
    [[[CellScopeContext sharedContext] bleManager] setFixationLight:self.selectedLight Intensity:fixationIntensity];
    
    /*
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
     */
    

}

-(void)viewWillDisappear:(BOOL)animated{
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];

    [[[CellScopeContext sharedContext] bleManager] setIlluminationWhite:0 Red:0];
    [[[CellScopeContext sharedContext] bleManager] setFixationLight:FIXATION_LIGHT_NONE Intensity:0];
    
    //[self.bleManager.fixationLights[self.bleManager.selectedLight] turnOff];
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
    
    //set flash intensity
    int whiteIntensity = [[NSUserDefaults standardUserDefaults] integerForKey:@"whiteFlashValue"];
    int redIntensity = [[NSUserDefaults standardUserDefaults] integerForKey:@"redFlashValue"];
    [[[CellScopeContext sharedContext] bleManager] setFlashIntensityWhite:whiteIntensity Red:redIntensity];
    
    
    //TODO: lockFocus should happen every time you tap, not here
    [self.captureManager lockFocus];
    
    //TODO: lock white balance should probably happen during exposure lock
    [self.captureManager lockWhiteBalance];
    
    [self.navigationItem setHidesBackButton:YES animated:YES];
    
    //[self.bleManager turnOffAllLights];
    
    //set the exposure using the flash light
    [self setExposureUsingLight];

    //start the capture sequence
    [self beginImageCapture];
    
}

- (void) beginImageCapture{
    int interval = [[NSUserDefaults standardUserDefaults] integerForKey:@"captureDelay"];
    
    self.repeatingTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(captureTimerFired) userInfo:nil repeats:YES];

}

-(void) setExposureUsingLight {

    int whiteFlashIntensity = [[NSUserDefaults standardUserDefaults] integerForKey:@"whiteFlashValue"];
    int redFlashIntensity = [[NSUserDefaults standardUserDefaults] integerForKey:@"redFlashValue"];
    int whiteFocusIntensity = [[NSUserDefaults standardUserDefaults] integerForKey:@"whiteFocusValue"];
    int redFocusIntensity = [[NSUserDefaults standardUserDefaults] integerForKey:@"redFocusValue"];
    float autoExposureDelay = [[NSUserDefaults standardUserDefaults] integerForKey:@"autoExposureDelay"];
    
    //turn on the LED w/ flash intensity
    [[[CellScopeContext sharedContext] bleManager] setIlluminationWhite:whiteFlashIntensity Red:redFlashIntensity];

    //wait for phone to adjust exposure
    [NSThread sleepForTimeInterval:autoExposureDelay];
    
    //lock exposure
    [self.captureManager setExposureLock:YES];
    
    //turn off lights
    [[[CellScopeContext sharedContext] bleManager] setIlluminationWhite:whiteFocusIntensity Red:redFocusIntensity];
    
}
    
-(void)captureTimerFired{
    self.currentImageCount++;
    int totalNumberOfImages = [[NSUserDefaults standardUserDefaults] integerForKey:@"numberOfImages"];
    
    if(self.currentImageCount <= totalNumberOfImages){
        [self updateCounterLabelText];
        // Timed flash or ping back
        
        //BOOL timedFlash = [[NSUserDefaults standardUserDefaults] boolForKey:@"timedFlash"];

        //send flash signal
        [[[CellScopeContext sharedContext] bleManager] doFlashWithDuration:[[NSUserDefaults standardUserDefaults] integerForKey:@"flashDuration"]];
        
        //wait for ble command to be sent
        [NSThread sleepForTimeInterval: [[NSUserDefaults standardUserDefaults] integerForKey:@"bleDelay"]];
        
        
        //turn off fixation light, snap a picture, turn fixation back on
        //[[[CellScopeContext sharedContext] bleManager] setFixationLight:FIXATION_LIGHT_NONE Intensity:0];
        [self.captureManager takePicture];
        //[[[CellScopeContext sharedContext] bleManager] setFixationLight:self.selectedLight Intensity:[[NSUserDefaults standardUserDefaults] integerForKey:@"fixationLightValue"]];

    }
    else{
        [self.repeatingTimer invalidate];
        self.repeatingTimer = nil;
    }
}

-(void)didCaptureImageWithData:(NSData *)data{
    
    SelectableEyeImage *image;
    
    if(mirroredView){
        
        /*
        UIImage *sourceImage = [UIImage imageWithData:data];
        UIImage *flippedImage = [UIImage imageWithCGImage: sourceImage.CGImage
                                                    scale: sourceImage.scale
                                              orientation: UIImageOrientationLeftMirrored];
        
        
        
        float scaleFactor = [[NSUserDefaults standardUserDefaults] floatForKey:@"ImageScaleFactor"];
        UIImage *thumbnail = [flippedImage resizedImageWithScaleFactor:scaleFactor];
        
        image = [[SelectableEyeImage alloc] initWithUIImage: flippedImage
                                                       date: [NSDate date]
                                                        eye: [[CellScopeContext sharedContext] selectedEye]
                                              fixationLight: (int) self.selectedLight
                                                  thumbnail: thumbnail];
        
         */
        
        image = [[SelectableEyeImage alloc] initWithData:data
                                                    date: [NSDate date]
                                                     eye: [[CellScopeContext sharedContext] selectedEye]
                                           fixationLight: (int) self.selectedLight];
        
        float scaleFactor = [[NSUserDefaults standardUserDefaults] floatForKey:@"ImageScaleFactor"];
        image.thumbnail = [image resizedImageWithScaleFactor:scaleFactor];
    }
    
    else{
        image = [[SelectableEyeImage alloc] initWithData:data
                                                    date: [NSDate date]
                                                     eye: [[CellScopeContext sharedContext] selectedEye]
                                           fixationLight: (int) self.selectedLight];
        
        float scaleFactor = [[NSUserDefaults standardUserDefaults] floatForKey:@"ImageScaleFactor"];
        image.thumbnail = [image resizedImageWithScaleFactor:scaleFactor];
    }
    
    
    
    NSLog(@"Date: %@",[image.date stringWithISO8061Format]);
    
    
    NSString* path = [image.date stringWithISO8061Format];
    
    [data writeToFile:[@"BaseDirectory/" stringByAppendingPathComponent:[image.date stringWithISO8061Format]]
           atomically:YES];
    
    NSLog(@"Save fixation light %ld", self.selectedLight);
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
            
        case FIXATION_LIGHT_CENTER:
            self.fixationImageView.image = [UIImage imageNamed:@"center.png"];
            break;
        case FIXATION_LIGHT_UP:
            self.fixationImageView.image = [UIImage imageNamed:@"top.png"];
            break;
        case FIXATION_LIGHT_DOWN:
            self.fixationImageView.image = [UIImage imageNamed:@"bottom.png"];
            break;
        case FIXATION_LIGHT_LEFT:
            self.fixationImageView.image = [UIImage imageNamed:@"left.png"];
            break;
        case FIXATION_LIGHT_RIGHT:
            self.fixationImageView.image = [UIImage imageNamed:@"right.png"];
            break;
        case FIXATION_LIGHT_NONE:
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
