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
@synthesize mirroredView;
@synthesize fullscreeningMode = _fullscreeningMode;
@synthesize nextFixationAlert = _nextFixationAlert;
@synthesize fixationImageView = _fixationImageView;

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
    /*
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didReceiveTapToFocus:)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
*/
    
    /*
    longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressedToCapture:)];
    [self.view addGestureRecognizer:longPressGestureRecognizer];
    */
    
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureHandler)];
    [self.view addGestureRecognizer:self.panGestureRecognizer];
    
    /// WHY IS THIS HERE>>>??? IN ORDER TO
    //GET TURN OFF/TURN ON TO WORK
    //[[self.bleManager whiteFlashLight]toggleLight];
    
    self.imageArray = [[NSMutableArray alloc] init];
    
    [[CellScopeContext sharedContext] setCamViewLoaded:YES];
    
    
}

-(void) viewWillAppear:(BOOL)animated{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [self.captureManager setupVideoForView:self.view];
    
    NSLog(@"Self.selectedLight, %ld",self.selectedLight);
    [self updateFixationImageView];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    /*
    [self.captureManager setExposureLock:NO];
    [self.captureManager unlockFocus];
    [self.captureManager unlockWhiteBalance];
    */
    
    [self.captureManager setRedGain:[[NSUserDefaults standardUserDefaults] floatForKey:@"previewRedGain"]
                          greenGain:[[NSUserDefaults standardUserDefaults] floatForKey:@"previewGreenGain"]
                           blueGain:[[NSUserDefaults standardUserDefaults] floatForKey:@"previewBlueGain"]];
    
    self.currentFocusPosition = [[NSUserDefaults standardUserDefaults] floatForKey:@"focusPosition"];
    [self.captureManager setFocusPosition:self.currentFocusPosition];
    
    self.currentExposureDuration = [[NSUserDefaults standardUserDefaults] floatForKey:@"previewExposureDuration"];
    [self.captureManager setExposureDuration:self.currentExposureDuration
                                         ISO:[[NSUserDefaults standardUserDefaults] floatForKey:@"previewISO"]];
    
    [self updateFocusExposureIndicators];
    
    //todo: is this still meaningful?
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
    int whiteIntensity = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"whiteFocusValue"];
    int redIntensity = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"redFocusValue"];
    int fixationIntensity = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"fixationLightValue"];
    
    [[[CellScopeContext sharedContext] bleManager] setIlluminationWhite:whiteIntensity Red:redIntensity];
    
    [[[CellScopeContext sharedContext] bleManager] setFixationLight:(int)self.selectedLight forEye:[[CellScopeContext sharedContext] selectedEye] withIntensity:fixationIntensity];
    

    

}

-(void)viewWillDisappear:(BOOL)animated{
    //take down camera
    [self.captureManager takeDownCamera];
    
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];

    [[[CellScopeContext sharedContext] bleManager] setIlluminationWhite:0 Red:0];
    [[[CellScopeContext sharedContext] bleManager] setFixationLight:FIXATION_LIGHT_NONE forEye:1 withIntensity:0];
    
    [[NSUserDefaults standardUserDefaults] setFloat:   self.focusValueLabel.text.floatValue  forKey:@"focusPosition"];
    [[NSUserDefaults standardUserDefaults] setInteger: self.exposureValueLabel.text.intValue  forKey:@"previewExposureDuration"];

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
    //[self playSound:@"beepbeep.wav"];
    [self.captureButton setEnabled:NO];
    [self.navigationItem setHidesBackButton:YES animated:YES];
    
    //remove preview window
    [self.captureManager.previewLayer removeFromSuperlayer];
    
    //setup exposure, iso, white balance, and flash intensity settings for capture
    int whiteIntensity = [[NSUserDefaults standardUserDefaults] integerForKey:@"whiteFlashValue"];
    int redIntensity = [[NSUserDefaults standardUserDefaults] integerForKey:@"redFlashValue"];
    [[[CellScopeContext sharedContext] bleManager] setFlashIntensityWhite:whiteIntensity Red:redIntensity];
    
    [self.captureManager setRedGain:[[NSUserDefaults standardUserDefaults] floatForKey:@"captureRedGain"]
                          greenGain:[[NSUserDefaults standardUserDefaults] floatForKey:@"captureGreenGain"]
                           blueGain:[[NSUserDefaults standardUserDefaults] floatForKey:@"captureBlueGain"]];
    
    float previewFlashRatio = [[NSUserDefaults standardUserDefaults] floatForKey:@"previewFlashRatio"];
    [self.captureManager setExposureDuration:(int)(self.currentExposureDuration / previewFlashRatio)
                                         ISO:[[NSUserDefaults standardUserDefaults] floatForKey:@"captureISO"]];
    
    //wait for the camera to set
    [NSThread sleepForTimeInterval:0.3];
    
    //start the capture sequence
    [self captureTimerFired];
    
}

/*
-(void) setExposureUsingLight {

    int whiteFlashIntensity = [[NSUserDefaults standardUserDefaults] integerForKey:@"whiteFlashValue"];
    int redFlashIntensity = [[NSUserDefaults standardUserDefaults] integerForKey:@"redFlashValue"];
    int whiteFocusIntensity = [[NSUserDefaults standardUserDefaults] integerForKey:@"whiteFocusValue"];
    int redFocusIntensity = [[NSUserDefaults standardUserDefaults] integerForKey:@"redFocusValue"];
    float autoExposureDelay = [[NSUserDefaults standardUserDefaults] floatForKey:@"autoExposureDelay"];
    
    //turn on the LED w/ flash intensity
    [[[CellScopeContext sharedContext] bleManager] setIlluminationWhite:whiteFlashIntensity Red:redFlashIntensity];

    //wait for phone to adjust exposure
    [NSThread sleepForTimeInterval:autoExposureDelay];
    
    //lock exposure
    [self.captureManager setExposureLock:YES];
    [self.captureManager lockWhiteBalance];
    
    [NSThread sleepForTimeInterval:0.2];
    
    //turn off lights
    [[[CellScopeContext sharedContext] bleManager] setIlluminationWhite:whiteFocusIntensity Red:redFocusIntensity];
    
}
    */

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
        [NSThread sleepForTimeInterval: [[NSUserDefaults standardUserDefaults] floatForKey:@"flashDelay"]/1000];
        
        
        [self.captureManager takePicture];

        int interval = [[NSUserDefaults standardUserDefaults] integerForKey:@"captureInterval"];
        self.repeatingTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(captureTimerFired) userInfo:nil repeats:NO];
        
    }

}

/*
 * This delegate handler gets called by AVCaptureManager after an image
 * is captured. data contains a JPEG image.
 */
-(void)didCaptureImageWithData:(NSData *)data{
    
    //TODO: add metadata to JPEG
    
    //save this JPEG to Documents folder with filename = CSID-Patient#-eye-fxn-number.jpg
    //where number is based on the files already in the dir (auto increment)
    
    //create an EyeImage CD object for this image and add it to the current exam object
    //create/store thumbnail in EyeImage, along with date, file path, all metadata, set flagged=0
    
    //check if "next" button pressed/# images reached. if so, trigger segue to review/next light
    
    /////////////////////////////////////////
    
    SelectableEyeImage *image;
    
    NSString* eyeString;
    if ([[CellScopeContext sharedContext] selectedEye] == 1)
        eyeString = @"OD";
    else
        eyeString = @"OS";
    
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
                                                     eye: eyeString
                                           fixationLight: (int) self.selectedLight];
        
        float scaleFactor = [[NSUserDefaults standardUserDefaults] floatForKey:@"ImageScaleFactor"];
        image.thumbnail = [image resizedImageWithScaleFactor:scaleFactor];
    }
    
    else{
        image = [[SelectableEyeImage alloc] initWithData:data
                                                    date: [NSDate date]
                                                     eye: eyeString
                                           fixationLight: (int) self.selectedLight];
        
        float scaleFactor = [[NSUserDefaults standardUserDefaults] floatForKey:@"ImageScaleFactor"];
        image.thumbnail = [image resizedImageWithScaleFactor:scaleFactor];
    }
    
    
/*
    NSLog(@"Date: %@",image.date.description);

    
    NSString* path = image.date.description;
    
    [data writeToFile:[@"BaseDirectory/" stringByAppendingPathComponent:path]
           atomically:YES];
    
    NSLog(@"Save fixation light %ld", self.selectedLight);
 */
    
    self.capturedImageView.image = image;
    self.capturedImageView.transform = CGAffineTransformMakeRotation(M_PI);
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
            [self captureTimerFired];
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

#define FOCUS_INCREMENT .01
#define EXPOSURE_INCREMENT 1
#define FOCUS_MIN 0.0
#define FOCUS_MAX 1.0
#define EXPOSURE_MIN 1
#define EXPOSURE_MAX 200

- (void)panGestureHandler
{
    
    CGPoint v = [self.panGestureRecognizer velocityInView:self.view];
    NSLog(@"%f",v.x);
    if (abs(v.x)>abs(v.y)) { //we'll treat this as a focus command (x)
        if (abs(v.x)>1)
            self.currentFocusPosition += (v.x/100)*FOCUS_INCREMENT;
        
        if (self.currentFocusPosition>FOCUS_MAX)
            self.currentFocusPosition = FOCUS_MAX;
        else if (self.currentFocusPosition<FOCUS_MIN)
            self.currentFocusPosition = FOCUS_MIN;
        
        
        [self.captureManager setFocusPosition:self.currentFocusPosition];
    }
    else if (abs(v.y)>abs(v.x)) { //treat as exposure command (y)
        if (abs(v.y)>1)
            self.currentExposureDuration -= (v.y/100)*EXPOSURE_INCREMENT;
        
        if (self.currentExposureDuration>EXPOSURE_MAX)
            self.currentExposureDuration = EXPOSURE_MAX;
        else if (self.currentExposureDuration<EXPOSURE_MIN)
            self.currentExposureDuration = EXPOSURE_MIN;
        
        [self.captureManager setExposureDuration:self.currentExposureDuration
                                             ISO:[[NSUserDefaults standardUserDefaults] floatForKey:@"previewISO"]];
    }
    

    [self updateFocusExposureIndicators];
    
    
}

- (void)updateFocusExposureIndicators
{
    CGFloat pos;
    pos = round(self.focusBarView.center.x + self.focusBarView.bounds.size.width*(self.currentFocusPosition/(FOCUS_MAX-FOCUS_MIN) - 0.5));
    [self.focusBarIndicator setCenter:CGPointMake(pos,self.focusBarIndicator.center.y)];
    
    pos = round(self.exposureBarView.center.y - self.exposureBarView.bounds.size.height*( self.currentExposureDuration/(EXPOSURE_MAX-EXPOSURE_MIN) - 0.5));
    [self.exposureBarIndicator setCenter:CGPointMake(self.exposureBarIndicator.center.x,pos)];
    
    
    self.focusValueLabel.text = [NSString stringWithFormat:@"%1.2f",self.currentFocusPosition];
    self.exposureValueLabel.text = [NSString stringWithFormat:@"%1.0f",self.currentExposureDuration];
    
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
    
    NSLog(@"Self.selectedLight, %ld",self.selectedLight);
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
