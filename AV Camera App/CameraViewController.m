//
//  CameraViewController.m
//  AV Camera App
//
//  Created by NAYA LOUMOU on 11/24/13.
//  Copyright (c) 2013 Cellscop. All rights reserved.
//

#import "CameraViewController.h"
#import <ImageIO/ImageIO.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Foundation/Foundation.h>


@interface CameraViewController ()
@end

@implementation CameraViewController
@synthesize preview;
@synthesize session;
@synthesize device;
@synthesize input;
@synthesize stillOutput;
@synthesize captureVideoPreviewLayer;
dispatch_queue_t backgroundQueue;

//@TODO- Hacky
double totScale=1;
int doubleTapEnabled=1;
int speak=1;
int mirrored=0;
int volumeSnap=0;
int location, focus=0, exposure=0;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.toolbarHidden = NO;
    
    //initialize for first eye
    location=1;
    
    //set up capture button
    [self.captureButton setImage:[UIImage imageNamed:@"capture.png"] forState:UIControlStateNormal] ;
    // [self.captureButton setTintColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    //    [self.captureButton setImage:[UIImage imageNamed:@"capture.png"] forState:UIControlStateNormal] ;
    self.captureButton.layer.cornerRadius=100;
    self.captureButton.layer.borderColor=[UIColor blueColor].CGColor;
    self.captureButton.layer.borderWidth=2.0f;
    
    
    //    [self.captureButton setTintColor:[UIColor colorWithRed:22 green:160 blue:133 alpha:1]];
    
    self.captureButton.tintColor = [UIColor whiteColor];
    //[self didPressRight:(id)self];
    //backgroundQueue = dispatch_queue_create("robbie.cellscope.playsound", NULL);
    
    // Setup the AV foundation capture session
    
    //@TODO-note that the capture session is not being taken down correctly, update from Lightscope3
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetPhoto;
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];
    if (!input) {
		NSLog(@"ERROR: trying to open camera: %@", error);
	}
    
    // Setup image preview layer
    
    //rotate and translate image
    preview.transform = CGAffineTransformMakeRotation(M_PI * 180 / 180.0f);
    preview.transform = CGAffineTransformTranslate(preview.transform,320,0);
    
    CALayer *viewLayer = self.preview.layer;
    captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession: self.session];
    captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    captureVideoPreviewLayer.frame = viewLayer.bounds;
    NSMutableArray *layers = [NSMutableArray arrayWithArray:viewLayer.sublayers];
    [layers insertObject:captureVideoPreviewLayer atIndex:0];
    viewLayer.sublayers = [NSArray arrayWithArray:layers];
    if (mirrored==1) {
        captureVideoPreviewLayer.transform = CATransform3DScale(CATransform3DMakeRotation(M_PI, 0, 0, 0),
                                                                -1, -1, 1);
    }
    // captureVideoPreviewLayer.frame = viewLayer.bounds;
    
    // Setup still image output
    self.stillOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [self.stillOutput setOutputSettings:outputSettings];
    [self.session addInput:self.input];
    [self.session addOutput:self.stillOutput];
    [self.session startRunning];
}



- (void)didPressCapture:(id)sender {
    [self snap];
    NSLog(@"did get image");
}


- (void)didPressNext: (id)sender{
    
    if (location==1){
        UIBarButtonItem * nextItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(didPressNext:)];
        self.navigationItem.rightBarButtonItem = nextItem;
        location=2;
        NSLog(@"Location turned to: %u", location);
        UILabel *lblTitle = [[UILabel alloc] init];
        lblTitle.text = @"Patient's Left Light";
        lblTitle.backgroundColor = [UIColor clearColor];
        lblTitle.textColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0];
        //lblTitle.shadowColor = [UIColor whiteColor];
        //lblTitle.shadowOffset = CGSizeMake(0, 1);
        lblTitle.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0];
        [lblTitle sizeToFit];
        self.navigationItem.titleView = lblTitle;
    }
    
    else if (location==2){
        [[self navigationController] popToRootViewControllerAnimated:YES];
    }
    
}

- (void)shoot:(NSNumber *)counter {
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in stillOutput.connections)
	{
		for (AVCaptureInputPort *port in [connection inputPorts])
		{
			if ([[port mediaType] isEqual:AVMediaTypeVideo] )
			{
				videoConnection = connection;
				break;
			}
		}
		if (videoConnection) { break; }
	}
    
    int n = [counter intValue];
    if (n > 0) {
        [self takeStill:videoConnection];
        [self performSelector:@selector(shoot:)
                   withObject:[NSNumber numberWithInt:n - 1]
                   afterDelay:1.0];
    }
}

- (void) takeStill:(AVCaptureConnection*)videoConnection
{
    [stillOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         UIImage *image = [[UIImage alloc] initWithData:imageData];
         // Request to save the image to camera roll
         ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
         
         [library writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error){
             if (error) {
                 NSLog(@"Error writing image to photo album");
             }
             else {
                 NSString *myString = [assetURL absoluteString];
                 NSString *myPath = [assetURL path];
                 NSLog(@"%@", myString);
                 NSLog(@"%@", myPath);
                 
                 EyeImage* newImage = (EyeImage*)[NSEntityDescription insertNewObjectForEntityForName:@"Images" inManagedObjectContext:self.managedObjectContext];
                 newImage.filePath = assetURL.absoluteString;
                 if (location==1){
                     newImage.eye = @"right"; //TODO: handle multiple fields
                     NSLog(@"Location is: %u", location);
                 }
                 else if (location== 2){
                     newImage.eye = @"left"; //TODO: handle multiple fields
                     NSLog(@"Location is: %u", location);
                 }
                 newImage.drName = self.currentImage.drName;
                 newImage.date = [NSDate date];
                 newImage.exam = self.currentExam;
                 
                 //newImage.patient = self.currentExam.patientID;
                 self.navigationItem.rightBarButtonItem.enabled = YES;
                 
                 
             }
         }];
     }];
    
}


- (IBAction)snap {
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
	NSLog(@"about to request a capture from: %@", stillOutput);
    [self shoot:[NSNumber numberWithInt:5]];
    
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    // Handle error saving image to camera roll
    if (error != NULL) {
        NSLog(@"Error saving picture");
    }
}

//control focus

-(IBAction)controlFocus:(id)sender{
    NSError *error2;
    if ([self.device lockForConfiguration:&error2]){
        if (focus==1) {
            focus=0;
            if ([self.device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
                
                CGPoint autofocusPoint = CGPointMake(0.5f, 0.5f);
                
                [self.device setFocusPointOfInterest:autofocusPoint];
                
                [self.device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
                NSLog(@"continuous auto focus on");
            }
            //change button title to lock
            [sender setTitle:@"Lock Focus" forState:UIControlStateNormal];
        }
        else if (focus==0){
            focus=1;
            if ([self.device isFocusModeSupported:AVCaptureFocusModeLocked]) {
                [self.device setFocusMode:AVCaptureFocusModeLocked];
                NSLog(@"changing focus to locked");
            }
            //change button title to unlock
            [sender setTitle:@"Unlock Focus" forState:UIControlStateNormal];
        }
        [self.device unlockForConfiguration];
    }
}

//control exposure
//still to do: change button title

-(IBAction)controlExpo:(id)sender{
    NSError *error2;
    if ([self.device lockForConfiguration:&error2]) {
        if (exposure==1) {
            exposure=0;
            if ([self.device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
                
                CGPoint exposurePoint = CGPointMake(0.5f, 0.5f);
                
                [self.device setExposurePointOfInterest:exposurePoint];
                
                [self.device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
                
            }
            NSLog(@"continuous exposure focus on");
            //change button title to lock
            [sender setTitle:@"Lock Exposure" forState:UIControlStateNormal];
        }
        else if (exposure==0){
            exposure=1;
            if ([self.device isExposureModeSupported:AVCaptureExposureModeLocked]) {
                [self.device setExposureMode:AVCaptureExposureModeLocked];
                NSLog(@"changing exposure to locked");
            }
            //change button title to Unlock
            [sender setTitle:@"Unlock Exposure" forState:UIControlStateNormal];
        }
        [self.device unlockForConfiguration];
    }
}


-(void) observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*) change context:(void*)context{
    NSLog(@"%@", [change objectForKey:NSKeyValueChangeNewKey]);
    if ([[change objectForKey:NSKeyValueChangeNewKey] intValue]==0 && device.exposureMode!=AVCaptureExposureModeLocked) {
        NSLog(@"locking exposure");
        NSError * error;
        [self.device lockForConfiguration:&error];
        [device setExposureMode:AVCaptureExposureModeLocked];
        [self.device unlockForConfiguration];
    }
}


- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIView *piece = gestureRecognizer.view;
        CGPoint locationInView = [gestureRecognizer locationInView:piece];
        CGPoint locationInSuperview = [gestureRecognizer locationInView:piece.superview];
        
        piece.layer.anchorPoint = CGPointMake(locationInView.x / piece.bounds.size.width, locationInView.y / piece.bounds.size.height);
        piece.center = locationInSuperview;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [self setPreview:nil];
    [super viewDidUnload];
}
@end