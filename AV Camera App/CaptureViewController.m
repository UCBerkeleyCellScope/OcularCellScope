//
//  CaptureViewController.m
//  OcularCellscope
//
//  Created by Chris Echanique on 2/21/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import "CaptureViewController.h"
#import "CellScopeContext.h"
#import "ImageSelectionViewController.h"
#import "UIImage+Resize.h"
#import "EImage.h"

#define flashNumber 9
#define farRedLight 10

@import AVFoundation;
@import AssetsLibrary;
@import UIKit;

@interface CaptureViewController ()

@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) AVCaptureDevice *device;
@property (strong, nonatomic) AVCaptureDeviceInput *deviceInput;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (strong, nonatomic) AVCaptureStillImageOutput *stillOutput;
@property (strong, nonatomic) NSMutableArray *imageArray;

@property (assign, nonatomic) int numberOfImages;
@property (assign, nonatomic) int captureDelay;

@property (nonatomic) BOOL connected;
@property (nonatomic) BOOL debugMode;
@property (nonatomic, strong) UIActivityIndicatorView *aiv;

@property (nonatomic, strong) NSUserDefaults *prefs;

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
@synthesize connected;
@synthesize debugMode = _debugMode;
@synthesize currentExam = _currentExam;
@synthesize captureButton;
@synthesize activityIndicator;
@synthesize aiv = _aiv;
@synthesize prefs = _prefs;

@synthesize ble;

int attempts = 0;
BOOL capturing = NO;

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
    
    ble.delegate = self;
    [self setViewControllerElements];
    [self videoSetup];
    

    
}

-(void)viewWillAppear:(BOOL)animated{
    
    _prefs = [NSUserDefaults standardUserDefaults];
    _debugMode = [_prefs boolForKey:@"debugMode" ];
    _aiv = [activityIndicator initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
    
    NSLog(@"Debug Mode is: %d",_debugMode);
    
    if(connected == NO && _debugMode == NO){
        [_aiv startAnimating];
        [captureButton setEnabled:NO];
        [self btnScanForPeripherals];
    }
    else{
        [_aiv stopAnimating];

    }
    
}

-(void)setViewControllerElements{
    //NSString *path = [[NSBundle mainBundle] pathForResource:@"CaptureSettings" ofType:@"plist"];
    //NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
    _numberOfImages = [_prefs integerForKey:@"numberOfImages"];
    _numberOfImages = 4;
    NSLog(@"Number of Images: %d", _numberOfImages);
    //[[dict objectForKey:@"numberOfImages"] intValue];
    
    _captureDelay = [_prefs floatForKey:@"captureDelay"];//[[dict objectForKey:@"captureDelay"] intValue];
    NSLog(@"Capture Delay: %d", _captureDelay);
    _counterLabel.hidden = YES;
    _counterLabel.text = nil;//@"";//[NSString stringWithFormat:@"",_numberOfImages];
    _imageArray = [[NSMutableArray alloc] init];    
}

- (void)btnScanForPeripherals
{
    
        if (ble.activePeripheral)
        if(ble.activePeripheral.state == CBPeripheralStateConnected)
        {
            [[ble CM] cancelPeripheralConnection:[ble activePeripheral]];
            //[bleConnect setTitle:@"Connect"];
            return;
        }
    
    if (ble.peripherals)
        ble.peripherals = nil;
    
    //[bleConnect setEnabled:false];
    [ble findBLEPeripherals:2];
    
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
    connected = NO;
    
}

-(void) bleDidConnect
{
    [_aiv stopAnimating];
    [captureButton setEnabled:YES];
    UInt8 buf[] = {0x04, 0x00, 0x00};
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [ble write:data];
    NSLog(@"BLE has succesfully connected");

    connected = YES;
    
    [self toggleAuxilaryLight:self.selectedLight toggleON:YES];
    [self toggleAuxilaryLight: farRedLight toggleON:YES];

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

- (void)flashOn:(float) duration {
    
    NSNumber *n = [[NSNumber alloc] initWithInteger: flashNumber ];
    
    UInt8 hex = [n intValue];
    NSLog(@"Big Flash");
    
    UInt8 buf[3] = {hex, 0x01, 0x00};
    
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [ble write:data];
    
    [NSTimer scheduledTimerWithTimeInterval:(float)duration
                                     target:self
                                   selector:@selector(flashTimer:)
                                   userInfo:n  repeats:NO];
}

-(void) flashTimer: (NSTimer *) theTimer{
    
    UInt8 passedHex = [[theTimer userInfo] intValue];
    
    NSLog(@"Hex Value to Turn Off Flash %d",passedHex);
    UInt8 buf[3] = {passedHex, 0x00, 0x00};
    NSLog(@"Flash Turned Off by timer");
    
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [ble write:data];
}

-(void) toggleAuxilaryLight: (NSInteger) light toggleON: (BOOL) switchON {
    
    NSNumber *n = [[NSNumber alloc] initWithInteger:light];
    
    UInt8 hex = [n intValue];
    NSLog(@"Turn  switchOn %d, Fixation Light %d", switchON, hex);
    
    UInt8 sw;
    if(switchON == YES){
        sw = 0x01;
    }
    else{
        sw = 0x00;
    }
    
    UInt8 buf[3] = {hex, sw, 0x00};
    
    int i = 0;
    NSLog(@"0x%02X, 0x%02X, 0x%02X", buf[i], buf[i+1], buf[i+2]);
    
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [ble write:data];
    
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
         [self turnTorchOn:NO];
         
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         EImage *image = [[EImage alloc] initWithData: imageData
                                                 date: [NSDate date]
                                                  eye: _selectedEye
                                        fixationLight: _selectedLight];
         
         
         
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

             [self performSegueWithIdentifier:@"ImageSelectionSegue" sender:self];
         }
         
     }];

}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    self.navigationController.navigationBar.alpha = 1;
    ImageSelectionViewController* isvc = (ImageSelectionViewController*)[segue destinationViewController];
    isvc.images = _imageArray;

}

- (void) turnTorchOn: (bool) on {
    
    // check if flashlight available
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
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
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didPressCapture:(id)sender {
    [captureButton setEnabled:NO];
    
    capturing = YES;
    
    // Reveal counter label to display image count
    
    //self.tabBarController.navigationItem.hidesBackButton = YES;
    
    //self.navigationController.navigationItem.backBarButtonItem.enabled = NO;
    
    _counterLabel.hidden = NO;
    AVCaptureConnection *videoConnection = [self getVideoConnection];
    
    // Capture images on a background thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        for(int index = 1; index <= _numberOfImages; ++index){
            
            NSLog(@"Why no execute");
            /*
             [[NSOperationQueue mainQueue] addOperationWithBlock:^{
             
             _counterLabel.text = [NSString stringWithFormat:@"%d/%d",index,_numberOfImages];
             NSLog(@"Image %d of %d",index,_numberOfImages);
             
             }];
             */
            //NSLog(@"Before sleep");
            [NSThread sleepForTimeInterval:1];//_captureDelay];
            //NSLog(@"After sleep");
            
            [self toggleAuxilaryLight:self.selectedLight toggleON:NO];
            [self toggleAuxilaryLight:farRedLight toggleON:NO];
            
            [self flashOn: 0.1];
            [self takeStillFromConnection:videoConnection];
            
            }
    });
    
    NSLog(@"didPressCapture Completed");
    [captureButton setEnabled:YES];
}
@end
