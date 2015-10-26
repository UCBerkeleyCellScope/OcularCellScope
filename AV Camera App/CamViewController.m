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
@synthesize nextFixationAlert = _nextFixationAlert;
@synthesize fixationImageView = _fixationImageView;

@synthesize tapGestureRecognizer;
@synthesize longPressGestureRecognizer;



-(void) viewWillAppear:(BOOL)animated{
    
    self.captureManager = [[AVCaptureManager alloc] init];
    self.captureManager.delegate = self;
    self.currentImageCount = 0;
    
    // Added gesture recognizer for tap to focus. We removed this because we determined that
    // manual focus was better.
    /*
     tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didReceiveTapToFocus:)];
     [self.view addGestureRecognizer:tapGestureRecognizer];
     */
    
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureHandler)];
    [self.view addGestureRecognizer:self.panGestureRecognizer];
    
    //initialize the array that will contain the images
    self.imageArray = [[NSMutableArray alloc] init];
    
    [[CellScopeContext sharedContext] setCamViewLoaded:YES]; //purpose??
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [self.captureManager setupCameraWithPreview:self.view];
    [self updateFixationImageView];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES]; //make sure the display doesn't go dark
    
    //set camera parameters
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

    self.counterLabel.hidden = YES;
    [self.bleDisabledLabel setHidden:YES];
    [self.navigationItem setHidesBackButton:NO animated:YES];
    
    
    //turn on focus light and fixation light
    int whiteIntensity = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"whiteFocusValue"];
    int redIntensity = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"redFocusValue"];
    int fixationIntensity = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"fixationLightValue"];
    
    //this is ugly, but getting this to work reliably has been insanely frustrating. seems that sending BLE commands on a BG thread is best. and send it twice just to make sure.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [[[CellScopeContext sharedContext] bleManager] setIlluminationWhite:whiteIntensity Red:redIntensity];
        [[[CellScopeContext sharedContext] bleManager] setFixationLight:(int)self.selectedLight forEye:[[CellScopeContext sharedContext] selectedEye] withIntensity:fixationIntensity];
        [NSThread sleepForTimeInterval:0.1];
        [[[CellScopeContext sharedContext] bleManager] setIlluminationWhite:whiteIntensity Red:redIntensity];
        [[[CellScopeContext sharedContext] bleManager] setFixationLight:(int)self.selectedLight forEye:[[CellScopeContext sharedContext] selectedEye] withIntensity:fixationIntensity];
        [NSThread sleepForTimeInterval:0.1];
    });

    CSLog(@"Camera view presented", @"USER");
    
}

-(void)viewWillDisappear:(BOOL)animated{
    
    //take down camera
    [self.captureManager takeDownCamera];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];

    //turn off lights/fixation
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [[[CellScopeContext sharedContext] bleManager] setIlluminationWhite:0 Red:0];
        [[[CellScopeContext sharedContext] bleManager] setFixationLight:FIXATION_LIGHT_NONE forEye:1 withIntensity:0];
        [NSThread sleepForTimeInterval:0.1];
        [[[CellScopeContext sharedContext] bleManager] setIlluminationWhite:0 Red:0];
        [[[CellScopeContext sharedContext] bleManager] setFixationLight:FIXATION_LIGHT_NONE forEye:1 withIntensity:0];
        [NSThread sleepForTimeInterval:0.1];
    });
    
    [[NSUserDefaults standardUserDefaults] setFloat:   self.focusValueLabel.text.floatValue  forKey:@"focusPosition"];
    [[NSUserDefaults standardUserDefaults] setInteger: self.exposureValueLabel.text.intValue  forKey:@"previewExposureDuration"];

}

//i don't think these are necessary anymore...
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

//not implemented now, but something we've discussed
-(IBAction)didPressPause:(id)sender{
    [self.repeatingTimer invalidate];
    [self.captureManager setExposureLock:NO];
    [self.captureManager lockFocus];
    [self.captureButton setEnabled:YES];
}


//we removed this because we wanted to stick with manual focus
/*
- (IBAction)tappedToFocus:(UITapGestureRecognizer *)sender {
    [self.captureButton setEnabled:NO];
    CGPoint focusPoint = [sender locationInView:self.view];
    //NSLog(@"x = %f  y = %f", focusPoint.x, focusPoint.y);
    [self.captureManager setFocusWithPoint:focusPoint];
    [self.captureButton setEnabled:YES];
}
*/

//initiates capture sequence. Capture sequence entails:
// 1) exposure, iso, whitebalance settings for camera are set to "flash" values specified in user settings
// 2) flash intensity, duration, and delay parameters transmitted to CellScope
// 3) capture sequence initiated. flash and camera capture are triggered together. cellscope will wait a specified delay between receiving the flash command and turning on the light (to sync it with the camera).

- (IBAction)didPressCapture:(id)sender{
    CSLog(@"Capture button pressed", @"USER");

    //[self playSound:@"beepbeep.wav"];
    [self.captureButton setEnabled:NO];
    [self.navigationItem setHidesBackButton:YES animated:YES];
    
    //remove preview window
    [self.captureManager.previewLayer removeFromSuperlayer];
    
    //setup exposure, iso, white balance, and flash intensity settings for capture
    int whiteIntensity = [[NSUserDefaults standardUserDefaults] integerForKey:@"whiteFlashValue"];
    int redIntensity = [[NSUserDefaults standardUserDefaults] integerForKey:@"redFlashValue"];
    
    float previewFlashRatio = [[NSUserDefaults standardUserDefaults] floatForKey:@"previewFlashRatio"];
    float flashDurationMultiplier = [[NSUserDefaults standardUserDefaults] floatForKey:@"flashDurationMultiplier"];
    int flashExposureDuration = (int)(self.currentExposureDuration / previewFlashRatio);
    int flashDelay = [[NSUserDefaults standardUserDefaults] integerForKey:@"flashDelay"];
    int flashDuration = (int)round(flashExposureDuration*flashDurationMultiplier);
    
    //send flash parameters to cellscope
    //why this works better in a BG thread, i don't know...
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [[[CellScopeContext sharedContext] bleManager] setFlashIntensityWhite:whiteIntensity
                                                                          Red:redIntensity];
        [NSThread sleepForTimeInterval:0.1];
        [[[CellScopeContext sharedContext] bleManager] setFlashTimingDelay: flashDelay
                                                                  Duration: flashDuration];
        [NSThread sleepForTimeInterval:0.1];
    });

    //setup camera
    [self.captureManager setRedGain:[[NSUserDefaults standardUserDefaults] floatForKey:@"captureRedGain"]
                          greenGain:[[NSUserDefaults standardUserDefaults] floatForKey:@"captureGreenGain"]
                           blueGain:[[NSUserDefaults standardUserDefaults] floatForKey:@"captureBlueGain"]];
    
    [self.captureManager setExposureDuration:flashExposureDuration
                                         ISO:[[NSUserDefaults standardUserDefaults] floatForKey:@"captureISO"]];
    
    //log this capture sequence
    NSString* logmsg = [NSString stringWithFormat:@"Capture sequence has begin with Focus=%3.2f, PrevExp=%3.2f, White=%d, Red=%d, FlashExp=%d, FlashDur=%d, FlashDelay=%3.2d, ISO=%3.2f, WB=%3.2f/%3.2f/%3.2f, Interval=%3.2f",
                        self.currentFocusPosition,
                        self.currentExposureDuration,
                        whiteIntensity,
                        redIntensity,
                        flashExposureDuration,
                        flashDuration,
                        flashDelay,
                        [[NSUserDefaults standardUserDefaults] floatForKey:@"captureISO"],
                        [[NSUserDefaults standardUserDefaults] floatForKey:@"captureRedGain"],
                        [[NSUserDefaults standardUserDefaults] floatForKey:@"captureGreenGain"],
                        [[NSUserDefaults standardUserDefaults] floatForKey:@"captureBlueGain"],
                        [[NSUserDefaults standardUserDefaults] floatForKey:@"captureInterval"]
                        ];
    CSLog(logmsg, @"HARDWARE");
    
    //wait for the camera to set
    [NSThread sleepForTimeInterval:0.6];
    
    //start the capture sequence
    [self captureTimerFired];
    
}

//no longer used, this was before iOS8 gave us direct control of exposure.
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

// initiates the capture of a single photo.
-(void)captureTimerFired{
    self.currentImageCount++;
    
    int totalNumberOfImages;
    
    if (self.automaticallyCycleThroughFixationLights)
        totalNumberOfImages = 5;
    else
        totalNumberOfImages = [[NSUserDefaults standardUserDefaults] integerForKey:@"numberOfImages"];
    
    if(self.currentImageCount <= totalNumberOfImages){
        [self updateCounterLabelText];

        //send flash signal
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{

            
            //flash the light on cellscope
            [[[CellScopeContext sharedContext] bleManager] doFlash];
            
            //take a picture
            [self.captureManager takePicture];
            
            //move the fixation light in preparation for next flash
            if (self.automaticallyCycleThroughFixationLights) {
                
                self.selectedLight++;
                
                //send it twice since interface is somewhat finicky
                [[[CellScopeContext sharedContext] bleManager] setFixationLight:FIXATION_LIGHT_NONE forEye:[[CellScopeContext sharedContext] selectedEye] withIntensity:0];
                [NSThread sleepForTimeInterval:0.2];
                [[[CellScopeContext sharedContext] bleManager] setFixationLight:FIXATION_LIGHT_NONE forEye:[[CellScopeContext sharedContext] selectedEye] withIntensity:0];
                [NSThread sleepForTimeInterval:0.2];
                [[[CellScopeContext sharedContext] bleManager] setFixationLight:(int)self.selectedLight forEye:[[CellScopeContext sharedContext] selectedEye] withIntensity:255];
                [NSThread sleepForTimeInterval:0.2];
                [[[CellScopeContext sharedContext] bleManager] setFixationLight:(int)self.selectedLight forEye:[[CellScopeContext sharedContext] selectedEye] withIntensity:255];
                 
                [NSThread sleepForTimeInterval:0.5]; //give user some time to move their eye
            }
            
        });
        
        int interval = [[NSUserDefaults standardUserDefaults] integerForKey:@"captureInterval"];
        self.repeatingTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(captureTimerFired) userInfo:nil repeats:NO];
        
    }

}

/*
 * This delegate handler gets called by AVCaptureManager after an image
 * is captured. data contains a JPEG image.
 */
-(void)didCaptureImageWithData:(NSData *)data{
    
    CSLog(@"Image captured.", @"HARDWARE");
    
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
    
    // this is such a bad hack. but since the automatic cycling is happening on a different thread, self.selectedLight will have already moved on to the next light by the time this image gets saved. So let's do our own internal counting here if we are doing automatic cycling. if we are NOT doing automatic cycling, then this number won't change.
    static int fixationLightNumber = 0;
    if (self.automaticallyCycleThroughFixationLights) {
        fixationLightNumber++;
        if (fixationLightNumber>5) {
            fixationLightNumber = 1;
        }
    }
    else
        fixationLightNumber = self.selectedLight;
    
    image = [[SelectableEyeImage alloc] initWithData:data
                                                date: [NSDate date]
                                                 eye: eyeString
                                       fixationLight: fixationLightNumber];
    
    float scaleFactor = [[NSUserDefaults standardUserDefaults] floatForKey:@"ImageScaleFactor"];
    image.thumbnail = [image resizedImageWithScaleFactor:scaleFactor];
    
    //present this captured imaged on the screen
    self.capturedImageView.image = image;
    self.capturedImageView.transform = CGAffineTransformMakeRotation(M_PI);
    
    // Add the capture image to the image array
    [self.imageArray addObject:image];
    
    NSLog(@"Saved Image %lu!",(unsigned long)[self.imageArray count]);
    
    // Once all images are captured, segue to the Image Selection View
    if (self.automaticallyCycleThroughFixationLights) { //take 5 images (fixation lights 1-5)
        if (self.currentImageCount==5)
            [self performSegueWithIdentifier:@"ImageSelectionSegue" sender:self];
    }
    else { //take however many images are specified in the user settings
        int totalNumberOfImages = [[[NSUserDefaults standardUserDefaults] objectForKey:@"numberOfImages"] intValue];
        if(self.currentImageCount >= totalNumberOfImages)
            [self performSegueWithIdentifier:@"ImageSelectionSegue" sender:self];
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


-(void)updateCounterLabelText{
    self.counterLabel.hidden = NO;
    if(self.currentImageCount < 10)
        self.counterLabel.text = [NSString stringWithFormat:@"0%d",self.currentImageCount];
    else
        self.counterLabel.text = [NSString stringWithFormat:@"%d",self.currentImageCount];
}

//no longer used
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

//some hard-coded parameters that control the swipe gesture user experience
#define FOCUS_INCREMENT .01
#define EXPOSURE_INCREMENT 1
#define FOCUS_MIN 0.0
#define FOCUS_MAX 1.0
#define EXPOSURE_MIN 25
#define EXPOSURE_MAX 200

//this adjusts either focus or exposure, depending on direction
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
    
    if (self.panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        NSString* logmsg = [NSString stringWithFormat:@"Focus=%3.2f, Exposure=%3.2f",self.currentFocusPosition,self.currentExposureDuration];
        CSLog(logmsg, @"USER");
    }
    
}

//updates the sliders on the screen to reflect the current exposure/focus settings
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

//might want to re-enable to make it easier to initiate capture.
- (IBAction)longPressedToCapture:(id)sender {
    if (self.longPressGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self.longPressGestureRecognizer setEnabled:NO];
        [self didPressCapture:sender];
    }
}

//used during tap to focus. not currently being used.
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
