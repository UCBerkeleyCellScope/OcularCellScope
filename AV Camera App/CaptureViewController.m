//
//  CaptureViewController.m
//  OcularCellscope
//
//  Created by Chris Echanique on 2/21/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import "CaptureViewController.h"
#import "ImageSelectionViewController.h"
#import "UIImage+Resize.h"

#define topLightHack 2

@interface CaptureViewController ()

@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) AVCaptureDevice *device;
@property (strong, nonatomic) AVCaptureDeviceInput *deviceInput;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (strong, nonatomic) AVCaptureStillImageOutput *stillOutput;
@property (strong, nonatomic) NSMutableArray *imageArray;
@property (assign, nonatomic) int numberOfImages;
@property (assign, nonatomic) float bleDelay;
@property (assign, nonatomic) float captureDelay;
@property (assign, nonatomic) float flashDuration;
@property (nonatomic) BOOL debugMode;
@property (nonatomic) BOOL timedFlash;

@property (nonatomic, strong) NSUserDefaults *prefs;

@property (nonatomic) NSTimer *timer;

@end

@implementation CaptureViewController

@synthesize session = _session;
@synthesize device = _device;
@synthesize deviceInput = _deviceInput;
@synthesize previewLayer = _previewLayer;
@synthesize stillOutput = _stillOutput;
@synthesize imageArray = _imageArray;

@synthesize numberOfImages = _numberOfImages;
@synthesize captureDelay = _captureDelay;
@synthesize counterLabel = _counterLabel;
@synthesize selectedEye = _selectedEye;
@synthesize selectedLight = _selectedLight;

@synthesize debugMode = _debugMode;
@synthesize timedFlash = _timedFlash;

@synthesize currentExam = _currentExam;
@synthesize captureButton;
@synthesize aiv;
@synthesize prefs = _prefs;

@synthesize ble;

@synthesize alreadyLoaded;
@synthesize swDigitalOut;

@synthesize bleDelay, flashDuration, timer;

BOOL alreadyLoaded = NO;
//BOOL capturing = NO;

BOOL withCallBack = NO;


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
	// Do any additional setup after loading the view, typically from a nib.
    
      ble = [[CellScopeContext sharedContext] ble];
    
//    ble = [[BLE alloc] init];
//    [ble controlSetup];
//    ble.delegate = self;
    
    [self setViewControllerElements];
    [self videoSetup];
    
}

-(void) viewWillDisappear:(BOOL)animated{
    
    [self toggleAuxilaryLight:self.selectedLight toggleON:NO];
    [self toggleAuxilaryLight: farRedLight toggleON:NO];

    [self lockFocus:NO];
    /*
    if (ble.activePeripheral)
        if(ble.activePeripheral.state == CBPeripheralStateConnected){
            [[ble CM] cancelPeripheralConnection:[ble activePeripheral]];
        }
    */
}

-(void)viewWillAppear:(BOOL)animated{
    
    _prefs = [NSUserDefaults standardUserDefaults];
    _debugMode = [_prefs boolForKey:@"debugMode" ];
    _captureDelay = [_prefs floatForKey:@"captureDelay" ];
    _numberOfImages = [_prefs integerForKey:@"numberOfImages"];
    _timedFlash = [_prefs boolForKey:@"timedFlash"];
    
    NSLog(@"Debug Mode is: %d",_debugMode);
    
    bleDelay=[_prefs floatForKey: @"bleDelay"];
    flashDuration=[_prefs floatForKey: @"flashDuration"];
    
    
    if(_debugMode == YES){
        [captureButton setEnabled:YES];
        alreadyLoaded = YES;
    }
    else if ( [[CellScopeContext sharedContext] connected] == NO){
        [aiv startAnimating];
        [captureButton setEnabled:NO];
        //[self btnScanForPeripherals];
    }
    else{
        //[_aiv stopAnimating];
        
        [captureButton setEnabled:YES];
        //The Code comes here if there is already a connection! CURRENTLY We are preventing this from being possible
        [self toggleAuxilaryLight:self.selectedLight toggleON:YES];
        [self toggleAuxilaryLight: farRedLight toggleON:YES];
        alreadyLoaded = YES;
    }
    
}

-(void)setViewControllerElements{
    //NSString *path = [[NSBundle mainBundle] pathForResource:@"CaptureSettings" ofType:@"plist"];
    //NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    NSLog(@"Number of Images: %d", _numberOfImages);
    
    _counterLabel.hidden = YES;
    _counterLabel.text = nil;//@"";//[NSString stringWithFormat:@"",_numberOfImages];
    _imageArray = [[NSMutableArray alloc] init];    
}

/*
- (void)btnScanForPeripherals
{
    
        if (ble.activePeripheral)
            if(ble.activePeripheral.state == CBPeripheralStateConnected){
                [[ble CM] cancelPeripheralConnection:[ble activePeripheral]];
            //[bleConnect setTitle:@"Connect"];
            }
    
    if (ble.peripherals)
        ble.peripherals = nil;
    
    //[bleConnect setEnabled:false];
    [ble findBLEPeripherals:2];  //WHY IS THIS 2?
    
    [NSTimer scheduledTimerWithTimeInterval:(float)2.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
    
}

-(void) connectionTimer:(NSTimer *)timer
{
    //[bleConnect setEnabled:true];
    //[bleConnect setTitle: @"Disconnect"];
    
    if (ble.peripherals.count > 0)
    {
        [ble connectPeripheral:[ble.peripherals objectAtIndex:0]];
        NSLog(@"At least attempting connection");
        
    }
    else if(attempts < 2 && capturing == NO)
    {
        //[bleConnect setTitle:@"Connect"];
        NSLog(@"No peripherals found, initiaiting attempt number %d", attempts);
        [self btnScanForPeripherals];
        attempts++;
    }
    else{
        NSLog(@"Why didn't we exit??");
        [_aiv stopAnimating];
        [captureButton setEnabled:YES];
    }
}

- (void)bleDidDisconnect
{
    NSLog(@"->Disconnected");
    [self btnScanForPeripherals];
    [[CellScopeContext sharedContext] setConnected: NO];
    NSLog(@"Connected set back to NO");
    swDigitalOut.enabled = false;
}

-(void) bleDidConnect
{
    [_aiv stopAnimating];
    [captureButton setEnabled:YES];
    UInt8 buf[] = {0x04, 0x00, 0x00}; //IDEA: Could have a corresponding LED blink to
    //acknowledge reset on Arduino side (but this is done successfully in SimpleControls)
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    //[ble write:data];
    NSLog(@"BLE has succesfully connected");

    [[CellScopeContext sharedContext] setConnected: YES];
    
    //[self toggleAuxilaryLight:self.selectedLight toggleON:YES];
    //[self toggleAuxilaryLight: farRedLight toggleON:YES];

    swDigitalOut.enabled = true;
    swDigitalOut.on = false;
}

// When data is comming, this will be called
// Note that this will be multiple unsigned chars
-(void) bleDidReceiveData:(unsigned char *)data length:(int)length
{
    NSLog(@"Length: %d", length);
    
    // parse data, all commands are in 3-byte
    for (int i = 0; i < length; i+=3) //incrementing by 3
    {
        NSLog(@"0x%02X, 0x%02X, 0x%02X", data[i], data[i+1], data[i+2]);
        
        if (data[i] == 0x0A)
        {
 
//             if (data[i+1] == 0x01)
//             swDigitalIn.on = true;
//             else
//             swDigitalIn.on = false;
 
        }
        else if (data[i] == 0x0B)
        {
            UInt16 Value;
            Value = data[i+2] | data[i+1] << 8;
            //lblAnalogIn.text = [NSString stringWithFormat:@"%d", Value];
        }
    }
}
*/
- (void)timedFlash {
    //flashDuration;
    [self toggleAuxilaryLight:flashNumber toggleON:YES];
   
    
   dispatch_async(dispatch_get_main_queue(), ^{
        //timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(tick:) userInfo:nil repeats:YES];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:flashDuration
                                         target:self
                                       selector:@selector(flashTimer:)
                                       userInfo:nil
                                        repeats:NO];
        //[[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    });
    
}

-(void) flashTimer: (NSTimer *) timer{
    [self toggleAuxilaryLight:flashNumber toggleON:NO];
    NSLog(@"YODEL");
    /*
    UInt8 passedHex = [[theTimer userInfo] intValue];
    
    NSLog(@"Hex Value to Turn Off Flash %d",passedHex);
    UInt8 buf[3] = {passedHex, 0x00, 0x00};
    NSLog(@"Flash Turned Off by timer");
    
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [ble write:data];
     */
}


- (void)flashOn:(float) duration {
    
    
    withCallBack = YES;
    NSLog(@"Big Flash");
    /*
    NSNumber *n = [[NSNumber alloc] initWithInteger: flashNumber ];
    
    UInt8 hex = [n intValue];

    
    UInt8 buf[3] = {hex, 0x01, 0x00};
    
    int i = 0;
    NSLog(@"0x%02X, 0x%02X, 0x%02X", buf[i], buf[i+1], buf[i+2]);

    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [ble write:data];
    
    [NSTimer scheduledTimerWithTimeInterval:(float)duration
                                     target:self
                                   selector:@selector(flashTimer:)
                                   userInfo:n  repeats:NO];
    */
    
    [self toggleAuxilaryLight:flashNumber toggleON:YES];
    
    /*
    dispatch_async(dispatch_get_main_queue(), ^{
        //timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(tick:) userInfo:nil repeats:YES];
     
    });
    */
    
}



-(void) toggleAuxilaryLight: (NSInteger) light toggleON: (BOOL) switchON {
    
    NSNumber *n = [[NSNumber alloc] initWithInteger:light];
   
    
    UInt8 hex = [n intValue];
    if (switchON == YES)
        NSLog(@"Switched Fixation Light %d ON", hex);
    else
        NSLog(@"Switched Fixation Light %d OFF", hex);
    
    
    UInt8 sw;
    if(switchON == YES){
        sw = 0x01;
    }
    else{
        sw = 0x00;
    }
    
    UInt8 callBack;
    if(withCallBack==YES){
        callBack = 0x01;
    }
    else{
        callBack = 0x00;
    }
    
    UInt8 bufZ[3] = {hex, sw, callBack};
    
    /*
    UInt8 bufZ[3] = {0x0A, 0x00, 0x00}; //Left Light, Pin4
    if(switchON ==YES){
        bufZ[1] = 0x01; //turn on
    }
    else{
        bufZ[1] = 0x00;
    }
     */
     
    int i = 0;
    NSLog(@"0x%02X, 0x%02X, 0x%02X", bufZ[i], bufZ[i+1], bufZ[i+2]);
    
    NSData *data = [[NSData alloc] initWithBytes:bufZ length:3];
    
    //NSLog(data.description);
    //[ble write:data];
    
}

-(IBAction)sendDigitalOut:(id)sender
{
    
    if (swDigitalOut.on){
        [self toggleAuxilaryLight:self.selectedLight toggleON:YES];
        [self toggleAuxilaryLight: farRedLight toggleON:YES];
        
        NSLog(@"Sending Digital Out!");

    }
    else{

        [self toggleAuxilaryLight:self.selectedLight toggleON:NO];
        [self toggleAuxilaryLight: farRedLight toggleON:NO];
        
    }
    
}


-(void)videoSetup
{
    _session = [[AVCaptureSession alloc] init];
    [_session setSessionPreset:AVCaptureSessionPresetPhoto];
    
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    _deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_device error:Nil];
    if ( [_session canAddInput:_deviceInput] )
        [_session addInput:_deviceInput];
    
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
    [_previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    _stillOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [_stillOutput setOutputSettings:outputSettings];
    [_session addOutput:_stillOutput];
    [_session startRunning];
    
    CALayer *rootLayer = [[self view] layer];
    [rootLayer setMasksToBounds:YES];
    [_previewLayer setFrame:CGRectMake(-70, 0, rootLayer.bounds.size.height, rootLayer.bounds.size.height)];
    [rootLayer insertSublayer:_previewLayer atIndex:0];
    
    //previewLayer.affineTransform = CGAffineTransformInvert(CGAffineTransformMakeRotation(M_PI));
    
    [_session startRunning];
}


-(AVCaptureConnection*)getVideoConnection{
    AVCaptureConnection *videoConnection = nil;
	for (AVCaptureConnection *connection in _stillOutput.connections)
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
    return videoConnection;
}

- (void)takeStillFromConnection:(AVCaptureConnection*)videoConnection{
    
	NSLog(@"Saving Image...");

	[_stillOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         
         // Turn off flash
         [self lockFocus:YES];
         if (_debugMode == NO)
             [self toggleAuxilaryLight:flashNumber toggleON:NO];
         
         
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         EImage *image = [[EImage alloc] initWithData: imageData
                                                 date: [NSDate date]
                                                  eye: [[CellScopeContext sharedContext] selectedEye]
                                        fixationLight: _selectedLight];
         NSLog(@"Capture selected Eye %@",_selectedEye);
         
         
         float scaleFactor = [[NSUserDefaults standardUserDefaults] floatForKey:@"ImageScaleFactor"];
         CGSize smallSize = [image size];
         smallSize.height = smallSize.height/scaleFactor;
         smallSize.width = smallSize.width/scaleFactor;
         image.thumbnail = [image resizedImage:smallSize interpolationQuality:kCGInterpolationDefault];
         
         // Add the capture image to the image array
         
         [_imageArray addObject:image];
         
         NSLog(@"Saved Image %lu!",[_imageArray count]);
         
         // Update the counter label
         if([_imageArray count]<_numberOfImages)
             _counterLabel.text = [NSString stringWithFormat:@"0%lu",(unsigned long)[_imageArray count]];
         else
             _counterLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)[_imageArray count]];
         
         NSLog(@"Image %lu of %d",(unsigned long)[_imageArray count],_numberOfImages);
         
         // Once all images are captured, segue to the Image Selection View
         if([_imageArray count] >= _numberOfImages){
             NSLog(@"About to segue to ImageSelectionView");
             [self performSegueWithIdentifier:@"ImageSelectionSegue" sender:self];
             
         }
         
     }];

}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    [aiv stopAnimating];
    [self toggleAuxilaryLight: 9 toggleON:NO];
    self.navigationController.navigationBar.alpha = 1;
    ImageSelectionViewController* isvc = (ImageSelectionViewController*)[segue destinationViewController];
    isvc.images = _imageArray;
    isvc.reviewMode = NO;

}

- (void) lockFocus: (bool) on {
    
    // check if flashlight available
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        [device lockForConfiguration:nil];
        
        if ([device isFocusModeSupported:AVCaptureFocusModeLocked] && on == YES) {
        
            NSLog(@"changing focus to locked");
            
            [device setFocusMode:AVCaptureFocusModeLocked];
        }
        
        else if([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus] && on == NO){
            CGPoint autofocusPoint = CGPointMake(0.5f, 0.5f);
            [self.device setFocusPointOfInterest:autofocusPoint];
            [self.device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            NSLog(@"continuous auto focus on");
        }
        
        [device unlockForConfiguration];

        /*
        if ([device hasTorch] && [device hasFlash]){
            
            [device lockForConfiguration:nil];
            if (on) {
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
                
                //torchIsOn = YES; //define as a variable/property if you need to know status
            } else {
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
                //torchIsOn = NO;
            }
            [device unlockForConfiguration];
        }
         */
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didPressCapture:(id)sender {
    /*
    NSError *error2;
    if ([self.device lockForConfiguration:&error2]){
        //if (focus==1) {
        //  focus=0;
        if ([self.device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            
            CGPoint autofocusPoint = CGPointMake(0.5f, 0.5f);
            
            [self.device setFocusPointOfInterest:autofocusPoint];
            
            [self.device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            NSLog(@"continuous auto focus on");
        }
        //change button title to lock
        //     [sender setTitle:@"Lock Focus" forState:UIControlStateNormal];
        // }
        
     
//         else if (focus==0){
//         focus=1;
//         if ([self.device isFocusModeSupported:AVCaptureFocusModeLocked]) {
//         [self.device setFocusMode:AVCaptureFocusModeLocked];
//         NSLog(@"changing focus to locked");
//         }
//         //change button title to unlock
//         [sender setTitle:@"Unlock Focus" forState:UIControlStateNormal];
//         }
     
        [self.device unlockForConfiguration];
    }
    */
    
    
    //swDigitalOut.enabled = false;
    [captureButton setEnabled:NO];
    
    /*
    [self toggleAuxilaryLight: flashNumber toggleON:NO];

    [self toggleAuxilaryLight:self.selectedLight toggleON:NO];
    [self toggleAuxilaryLight:farRedLight toggleON:NO];
     */
    
    //capturing = YES;
    
    // Reveal counter label to display image count
    _counterLabel.hidden = NO;
    [self.navigationItem setHidesBackButton:YES animated:YES];
    
    AVCaptureConnection *videoConnection = [self getVideoConnection];
    
    // Capture images on a background thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        for(int index = 1; index <= _numberOfImages; ++index){
            
            NSLog(@"Spawned a thread.");
            
             [[NSOperationQueue mainQueue] addOperationWithBlock:^{
             
             _counterLabel.text = [NSString stringWithFormat:@"%d/%d",index,_numberOfImages];
             NSLog(@"Image %d of %d",index,_numberOfImages);
             
             }];
            
            //NSLog(@"Before sleep");
            [NSThread sleepForTimeInterval:_captureDelay];//_captureDelay];
            //NSLog(@"After sleep");
            
            if(_timedFlash == NO){
                [self flashOn: 0.1];
            //[self takeStillFromConnection:videoConnection];
            }
            else{
                [self timedFlash];
                [self takeStillFromConnection:videoConnection];
            }
        }
    });
    
    NSLog(@"didPressCapture Completed");
}
@end
