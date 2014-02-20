//
//  CameraViewController.m
//  AV Camera App
//
//  Created by NAYA LOUMOU on 11/24/13.
//  Copyright (c) 2013 Cellscop. All rights reserved.
//

#import "CameraViewController.h"
#import "ImagesViewController.h"
#import "Image.h"
#import <ImageIO/ImageIO.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Foundation/Foundation.h>
#import "UIImage+Resize.h"

@interface CameraViewController ()
@end

@implementation CameraViewController

@synthesize ble;
@synthesize managedObjectContext= _managedObjectContext;

//@synthesize bleConnect;

@synthesize camButton;

@synthesize preview;
@synthesize session;
@synthesize device;
@synthesize input;
@synthesize videoPreviewOutput, videoHDOutput, stillOutput;
@synthesize captureVideoPreviewLayer;

@synthesize currentPatient;
//There is no use for the CamerViewController to have an Image object!!


dispatch_queue_t backgroundQueue;

//@TODO- Hacky
double totScale=1;
int doubleTapEnabled=1;
int speak=1;
int mirrored=0;
int volumeSnap=0;
int location;


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



- (IBAction)btnScanForPeripherals:(id)sender
{
    if (ble.activePeripheral)
        if(ble.activePeripheral.state == CBPeripheralStateConnected)
        {
            [[ble CM] cancelPeripheralConnection:[ble activePeripheral]];
            [bleConnect setTitle:@"Connect"];
            return;
        }
    
    if (ble.peripherals)
        ble.peripherals = nil;
    
    [bleConnect setEnabled:false];
    [ble findBLEPeripherals:2];
    
    [NSTimer scheduledTimerWithTimeInterval:(float)2.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
    
    //[indConnecting startAnimating];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = NO;
    //self.navigationController.toolbarHidden = NO;
   
    ble = [[BLE alloc] init];
    [ble controlSetup];
    ble.delegate = self;
    
    
    location=1;
    
    /*
    [self.captureButton setImage:[UIImage imageNamed:@"capture.png"] forState:UIControlStateNormal] ;
    self.captureButton.layer.cornerRadius=100;
    self.captureButton.layer.borderColor=[UIColor blueColor].CGColor;
    self.captureButton.layer.borderWidth=2.0f;
    
    //    [self.captureButton setTintColor:[UIColor colorWithRed:22 green:160 blue:133 alpha:1]];
    
    self.captureButton.tintColor = [UIColor colorWithRed:22 green:160 blue:133 alpha:1];
    //[self didPressRight:(id)self];
    //backgroundQueue = dispatch_queue_create("robbie.cellscope.playsound", NULL);
    */
     
     
    // Setup the AV foundation capture session
    //@TODO-note that the capture session is not being taken down correctly, update from Eyescope3
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetPhoto;
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];
    if (!input) {
		NSLog(@"ERROR: trying to open camera: %@", error);
	}
    // Setup image preview layer
    //preview.transform = CGAffineTransformMakeRotation(.5*M_PI);
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
    
    //Add gesture recognizers. Why exactly are we doing this here? Must not be using the ones on the Storyboard.
    // UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
	//[singleTap setNumberOfTapsRequired:1];
    //[self.view addGestureRecognizer:singleTap];
    if (doubleTapEnabled==1){
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(handleDoubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [self.view addGestureRecognizer:doubleTap];
        
        //[singleTap requireGestureRecognizerToFail:doubleTap];
    }
}

-(void) connectionTimer:(NSTimer *)timer
{
    [bleConnect setEnabled:true];
    [bleConnect setTitle: @"Disconnect"];
    
    
    if (ble.peripherals.count > 0)
    {
        
        [ble connectPeripheral:[ble.peripherals objectAtIndex:0]];
        NSLog(@"At least attempting connection");
        
        
    }
    else
    {
        [bleConnect setTitle:@"Connect"];
        NSLog(@"No peripherals found");
    }
}

- (void)bleDidDisconnect
{
    NSLog(@"->Disconnected");
    
}

-(void) bleDidConnect
{
    UInt8 buf[] = {0x04, 0x00, 0x00};
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [ble write:data];
    NSLog(@"BLE has succesfully connected");
}
    
// When data is comming, this will be called
-(void) bleDidReceiveData:(unsigned char *)data length:(int)length
{
    NSLog(@"Length: %d", length);
    
    // parse data, all commands are in 3-byte
    for (int i = 0; i < length; i+=3)
    {
        NSLog(@"0x%02X, 0x%02X, 0x%02X", data[i], data[i+1], data[i+2]);
        
        if (data[i] == 0x0A)
        {
            /*
            if (data[i+1] == 0x01)
                swDigitalIn.on = true;
            else
                swDigitalIn.on = false;
             */
        }
        else if (data[i] == 0x0B)
        {
            UInt16 Value;
            
            Value = data[i+2] | data[i+1] << 8;
            //lblAnalogIn.text = [NSString stringWithFormat:@"%d", Value];
        }
    }
}


- (void) handleDoubleTap:(UIGestureRecognizer *) doubleGesture {
    NSLog(@"in double ibaction");
    
    CGPoint tapPoint = [doubleGesture locationInView:doubleGesture.view];
    int tapX = (int) tapPoint.x;
    int tapY = (int) tapPoint.y;
    NSLog(@"TAPPED X:%d Y:%d", tapX, tapY);
    CGPoint  tapPoint2=[self convertToPointOfInterestFromViewCoordinates:(tapPoint)];
    double tapX2 = (double) tapPoint2.x;
    double tapY2 = (double) tapPoint2.y;
    NSLog(@"2!!!TAPPED X:%f Y:%f", tapX2, tapY2);
    CGPoint p; p.x = 1-tapPoint2.x; p.y = 1-tapPoint2.y;
    double px = (double) p.x;
    double py = (double) p.y;
    NSLog(@"3!!!TAPPED X:%f Y:%f", px, py);
    NSError * error;
    if ([self.device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure] &&
        [self.device isExposurePointOfInterestSupported] && doubleTapEnabled==1)
    {
        if ([self.device lockForConfiguration:&error]) {
            NSLog(@"exposing on point...");
            //[self.device setExposurePointOfInterest:p];
            //[self.device setExposureMode:AVCaptureFocusModeAutoFocus];
            
            [device addObserver:self
                     forKeyPath:@"adjustingExposure"
                        options:NSKeyValueObservingOptionNew
                        context:nil];
            [device setExposurePointOfInterest:p];
            [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            //[device setExposureMode:AVCaptureExposureModeLocked];
            [self.device unlockForConfiguration];
        } else {
            NSLog(@"Error: %@", error);
        }
    }
}

- (IBAction)didPressCapture:(id)sender {
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
        lblTitle.text = @"Patient's Left Eye";
        lblTitle.backgroundColor = [UIColor clearColor];
        lblTitle.textColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0];
        //lblTitle.shadowColor = [UIColor whiteColor];
        //lblTitle.shadowOffset = CGSizeMake(0, 1);
        lblTitle.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0];
        [lblTitle sizeToFit];
        self.navigationItem.titleView = lblTitle;
    }
    
    else if (location==2){
        //[[self navigationController] popToRootViewControllerAnimated:YES];
        
        [self performSegueWithIdentifier:@"showImages" sender:self];
        
        //This plus linking directly to the Next Button Worked
        //ImagesViewController *ivc = [[ImagesViewController alloc] init];
        //[[self navigationController] pushViewController:ivc animated:YES];
        
    }
    
}

- (IBAction)didPressConnect:(id)sender {
}


/* Not very intuitive!!
 
 - (IBAction)didPressRight:(id)sender
 {
 [self.RightEyeButton setTitle:@"Right Eye" forState:UIControlStateNormal];
 [self.RightEyeButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
 [self.LeftEyeButton setTitle:@"Left Eye" forState:UIControlStateNormal];
 [self.LeftEyeButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
 location= 1;
 }
 
 - (IBAction)didPressLeft:(id)sender
 {
 [self.RightEyeButton setTitle:@"Right Eye" forState:UIControlStateNormal];
 [self.RightEyeButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
 [self.LeftEyeButton setTitle:@"Left Eye" forState:UIControlStateNormal];
 [self.LeftEyeButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
 location= 2;
 }
 
 */

//@TODO this is a mess and needs to be re-rewritten
- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates
{
    NSLog(@"screen height %f", [[UIScreen mainScreen] bounds].size.height);
    NSLog(@"screen width %f", [[UIScreen mainScreen] bounds].size.width);
    CGPoint pointOfInterest = CGPointMake(.5f, .5f);
    CGSize frameSize = [[self preview] frame].size;
    AVCaptureVideoPreviewLayer *videoPreviewLayer = [self captureVideoPreviewLayer];
    if ([[self captureVideoPreviewLayer] isMirrored]) {
        NSLog(@"in isMirrored");
        
        viewCoordinates.x = frameSize.width - viewCoordinates.x;
    }
    
    if ( [[videoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResize] ) {
        pointOfInterest = CGPointMake(viewCoordinates.y / frameSize.height, 1.f - (viewCoordinates.x / frameSize.width));
    } else {
        CGRect cleanAperture;
        for (AVCaptureInputPort *port in [[[[self session] inputs] lastObject] ports]) {
            if ([port mediaType] == AVMediaTypeVideo) {
                cleanAperture = CMVideoFormatDescriptionGetCleanAperture([port formatDescription], YES);
                CGSize apertureSize = cleanAperture.size;
                CGPoint point = viewCoordinates;
                
                CGFloat apertureRatio = apertureSize.height / apertureSize.width;
                CGFloat viewRatio = frameSize.width / frameSize.height;
                CGFloat xc = .5f;
                CGFloat yc = .5f;
                
                if ( [[videoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResizeAspect] ) {
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = frameSize.height;
                        CGFloat x2 = frameSize.height * apertureRatio;
                        CGFloat x1 = frameSize.width;
                        CGFloat blackBar = (x1 - x2) / 2;
                        if (point.x >= blackBar && point.x <= blackBar + x2) {
                            xc = point.y / y2;
                            yc = 1.f - ((point.x - blackBar) / x2);
                        }
                    } else {
                        CGFloat y2 = frameSize.width / apertureRatio;
                        CGFloat y1 = frameSize.height;
                        CGFloat x2 = frameSize.width;
                        CGFloat blackBar = (y1 - y2) / 2;
                        if (point.y >= blackBar && point.y <= blackBar + y2) {
                            xc = ((point.y - blackBar) / y2);
                            yc = 1.f - (point.x / x2);
                        }
                    }
                } else if ([[videoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
                    if (viewRatio > apertureRatio) {
                        NSLog(@"calculating coords2");
                        NSLog(@"%f", apertureSize.height);
                        NSLog(@"%f", apertureSize.width);
                        NSLog(@"%f", frameSize.height);
                        NSLog(@"%f", frameSize.width);
                        NSLog(@"%f", point.x);
                        NSLog(@"%f", point.y);
                        
                        CGFloat y2 = apertureSize.width * (frameSize.width / apertureSize.height);
                        xc = (point.y + ((y2 - frameSize.height) / 2.f)) / y2;
                        yc = (frameSize.width - point.x) / frameSize.width;
                        xc=point.x/[[UIScreen mainScreen] bounds].size.width;
                        yc=1-point.y/[[UIScreen mainScreen] bounds].size.height;
                    } else {
                        NSLog(@"calculating coords");
                        NSLog(@"%f", apertureSize.height);
                        NSLog(@"%f", apertureSize.width);
                        NSLog(@"%f", frameSize.height);
                        NSLog(@"%f", frameSize.width);
                        NSLog(@"%f", point.x);
                        NSLog(@"%f", point.y);
                        CGFloat x2 = apertureSize.height * (frameSize.height / apertureSize.width);
                        yc = 1.f - ((point.x + ((x2 - frameSize.width) / 2)) / x2);
                        xc = point.y / frameSize.height;
                        //@TODO works only on 4/4s, easy fix
                        xc=point.x/[[UIScreen mainScreen] bounds].size.width;
                        yc=1-point.y/[[UIScreen mainScreen] bounds].size.height;
                    }
                }
                
                pointOfInterest = CGPointMake(xc, yc);
                break;
            }
        }
    }
    return pointOfInterest;
}

- (void)flashOn{
    UInt8 buf[3] = {0x01, 0x01, 0x00};
    
    NSLog(@"Flash On");
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [ble write:data];
}




//This could be async potentially

- (IBAction)snap {
    
    AVCaptureConnection *videoConnection = nil; //connection between capture input and capture output
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
    
	NSLog(@"about to request a capture from: %@", stillOutput);
    
    [self flashOn]; //let's turn on the flash
    
    [NSTimer scheduledTimerWithTimeInterval:(float)1.0 target:self selector:@selector(flashTimer:) userInfo:nil repeats:NO];
    
    
	[stillOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         
         
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         UIImage *image = [[UIImage alloc] initWithData:imageData];
         
         
         
    void (^doneSavingInAssetLibrary)(NSURL*,NSError*) =
         ^(NSURL* assetURL, NSError* error)
         {
             if (error) {
                 NSLog(@"Error writing video/image to photo album");
             }
             else {
                 NSLog(@"did save video/image");
                 
                 
                 UIImage* thumbnail = [image thumbnailImage: 160.0
                                          transparentBorder: 1.0
                                               cornerRadius: 10.0
                                       interpolationQuality: kCGInterpolationDefault];
                 
                 
                 
                 Image *newImage = (Image *)[NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext: self.managedObjectContext];
                 
                 newImage.filePath = assetURL.absoluteString;
                 NSLog(@"CameraViewController filePath:");
                 
                 NSLog(newImage.filePath.description);
                 //NSLog(assetURL);
                 
                 
                 newImage.thumbnail = UIImagePNGRepresentation(thumbnail);
                 
                 if (location==1){
                     newImage.eyeLocation = @"right"; //TODO: handle multiple fields
                     NSLog(@"Location is: %u", location);
                 }
                 else if (location== 2){
                     newImage.eyeLocation = @"left"; //TODO: handle multiple fields
                     NSLog(@"Location is: %u", location);
                 }
                 
                 
                 
                 
                 newImage.date = [NSDate date];
                 newImage.patient = self.currentPatient;

                 //Note that edScope never calls newImage.patient
                 //or in their case photo.session
                 
                 [self.currentPatient addPatientImagesObject:newImage];
                 
                 if (![ _managedObjectContext save:&error]) {
                     NSLog(@"Failed to add new picture with error: %@", [error domain]);
                 }
                 
             }
         };
         
         
         
         // Request to save the image to camera roll
         //We have both NSData and UIImage objects at our disposal
         //PReviously Used insertNewObjectForEntityForName
         
         
         ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
         
        
         //writeImageToSavedPhotosAlbum NO WE WANT TO SANDBOX IT INSTEAD
         [library writeImageToSavedPhotosAlbum:image.CGImage
                                   orientation:(ALAssetOrientation)[image imageOrientation]
                               completionBlock: doneSavingInAssetLibrary
          
          
          /*
          ^(NSURL *assetURL, NSError *error){
             //This code gets executed after saving
             if (error) {
                 NSLog(@"Error writing image to photo album");
             }
             else {
                 NSString *myString = [assetURL absoluteString];
                 NSString *myPath = [assetURL path];
                 NSLog(@"%@", myString);
                 NSLog(@"%@", myPath);
           
                 
                 
                 //Re-enable next button
                 
                 //newImage.patient = self.currentPatient.patientID;
                 
             } //end of else
            */
           
         ]; //end of writeImageToSavedPhotosAlbum

     }]; //end of captureStillImage
    
}

-(void) flashTimer:(NSTimer *)timer
{
    UInt8 buf[3] = {0x01, 0x00, 0x00};
    
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [ble write:data];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    // Handle error saving image to camera roll
    if (error != NULL) {
        NSLog(@"Error saving picture");
    }
}

/*
- (IBAction)handlePinch:(UIPinchGestureRecognizer *) recognizer  {
    
    NSLog(@"in pinch ibaction");
    CGSize frameSize = [[self preview] frame].size;
    if (frameSize.width*recognizer.scale>=[[UIScreen mainScreen] bounds].size.width) {
        recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    }
    recognizer.scale = 1;
}
*/

- (IBAction)handleLongPress:(UILongPressGestureRecognizer *)longPress  {
    if (longPress.state == UIGestureRecognizerStateBegan){
        NSLog(@"in longpress ibaction");
        CGPoint tapPoint = [longPress locationInView:longPress.view];
        int tapX = (int) tapPoint.x;
        int tapY = (int) tapPoint.y;
        NSLog(@"TAPPED X:%d Y:%d", tapX, tapY);
        CGPoint  tapPoint2=[self convertToPointOfInterestFromViewCoordinates:(tapPoint)];
        double tapX2 = (double) tapPoint2.x;
        double tapY2 = (double) tapPoint2.y;
        NSLog(@"2!!!TAPPED X:%f Y:%f", tapX2, tapY2);
        CGPoint p; p.x = 1-tapPoint2.x; p.y = 1-tapPoint2.y;
        double px = (double) p.x;
        double py = (double) p.y;
        NSLog(@"3!!!TAPPED X:%f Y:%f", px, py);
        NSError *error2;
        if ([self.device isFocusModeSupported:AVCaptureFocusModeAutoFocus] &&
            [self.device isFocusPointOfInterestSupported])
        {
            if ([self.device lockForConfiguration:&error2]) {
                NSLog(@"focussing on point...");
                [self.device setFocusPointOfInterest:p];
                [self.device setFocusMode:AVCaptureFocusModeAutoFocus];
                
                [self.device unlockForConfiguration];
            } else {
                NSLog(@"Error: %@", error2);
            }
        }
        if ([self.device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure] &&
            [self.device isExposurePointOfInterestSupported] && doubleTapEnabled==0)
        {
            if ([self.device lockForConfiguration:&error2]) {
                NSLog(@"exposing on point...");
                //[self.device setExposurePointOfInterest:p];
                //[self.device setExposureMode:AVCaptureFocusModeAutoFocus];
                [device     addObserver:self
                             forKeyPath:@"adjustingExposure"
                                options:NSKeyValueObservingOptionNew
                                context:nil];
                [device setExposurePointOfInterest:p];
                [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
                //[device setExposureMode:AVCaptureExposureModeLocked];
                
                [self.device unlockForConfiguration];
            } else {
                NSLog(@"Error: %@", error2);
            }
        }
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

/*
- (IBAction)handlePan:(UIPanGestureRecognizer *)panGesture  {
    NSLog(@"in pan ibaction");
    UIView *piece = [panGesture view];
    [self adjustAnchorPointForGestureRecognizer:panGesture];
    
    if ([panGesture state] == UIGestureRecognizerStateBegan || [panGesture state] == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [panGesture translationInView:[piece superview]];
        [piece setCenter:CGPointMake([piece center].x + translation.x, [piece center].y+translation.y)];
        [panGesture setTranslation:CGPointZero inView:[piece superview]];
    }
}
*/

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




- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ImagesViewController* imvc = (ImagesViewController*)[segue destinationViewController];
    imvc.managedObjectContext = self.managedObjectContext;
    imvc.patientToDisplay = self.currentPatient;
    
        
}




@end
