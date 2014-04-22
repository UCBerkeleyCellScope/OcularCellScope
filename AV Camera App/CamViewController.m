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

@synthesize bluetoothSystem = _bluetoothSystem;
@synthesize captureManager  = _captureManager;
@synthesize currentImageCount = _currentImageCount;
@synthesize repeatingTimer = _repeatingTimer;
@synthesize imageArray = _imageArray;
@synthesize captureButton = _captureButton;
@synthesize settingsButton = _settingsButton;
@synthesize capturedImageView = _capturedImageView;
@synthesize aiv = _aiv;
@synthesize counterLabel = _counterLabel;
@synthesize selectedLight = _selectedLight;
@synthesize selectedEye = _selectedEye;

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
    self.bluetoothSystem = [[CellScopeContext sharedContext] bluetoothSystem];
    self.captureManager = [[AVCaptureManager alloc] init];
    self.captureManager.delegate = self;
    self.currentImageCount = 0;
    
    // Hide label initially
    self.counterLabel.hidden = YES;
    self.imageArray = [[NSMutableArray alloc] init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.captureManager setupVideoForView:self.view];
    [self.bluetoothSystem.redLight turnOn];
    [[self.bluetoothSystem.fixationLights objectAtIndex:self.selectedLight] turnOn];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)didPressPause:(id)sender{
    [self.repeatingTimer invalidate];
}

- (IBAction)didPressCapture:(id)sender{
    NSLog(@"didPressCapture");
    [self.captureManager lockFocus];
    
    NSNumber *interval = [[NSUserDefaults standardUserDefaults] objectForKey:@"captureDelay"];
    
    self.repeatingTimer = [NSTimer scheduledTimerWithTimeInterval:[interval doubleValue] target:self selector:@selector(captureTimerFired) userInfo:nil repeats:YES];
}

-(void)captureTimerFired{
    self.currentImageCount++;
    int totalNumberOfImages = [[[NSUserDefaults standardUserDefaults] objectForKey:@"numberOfImages"] intValue];
    if(self.currentImageCount <= totalNumberOfImages){
        [self updateCounterLabelText];
        // Timed flash or ping back
        [self.bluetoothSystem timedFlash];
        [self.captureManager takePicture];
    }
    else{
        [self.repeatingTimer invalidate];
        self.repeatingTimer = nil;
    }
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
    self.navigationController.navigationBar.alpha = 1;
    ImageSelectionViewController *isvc = (ImageSelectionViewController*)[segue destinationViewController];
    isvc.images = self.imageArray;
    isvc.reviewMode = NO;
}


@end
