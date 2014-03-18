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
#import "CameraAppDelegate.h"
#import "CoreDataController.h"
#import "EyeImage.h"

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
@property (strong, nonatomic) NSMutableArray *thumbnailArray;
@property (assign, nonatomic) int numberOfImages;
@property (assign, nonatomic) int captureDelay;

@property (strong, nonatomic) NSString *file;
@property (nonatomic) BOOL connected;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation CaptureViewController

@synthesize session = _session;
@synthesize device = _device;
@synthesize deviceInput = _deviceInput;
@synthesize previewLayer = _previewLayer;
@synthesize stillOutput = _stillOutput;
@synthesize imageArray = _imageArray;
@synthesize thumbnailArray = _thumbnailArray;
@synthesize numberOfImages = _numberOfImages;
@synthesize captureDelay = _captureDelay;
@synthesize counterLabel = _counterLabel;
@synthesize selectedEye = _selectedEye;
@synthesize selectedLight = _selectedLight;
@synthesize ble;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize file, connected;
@synthesize currentExam = _currentExam;

@synthesize eyeImages = _eyeImages;

int attempts = 0;

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
    
    ble = [[BLE alloc] init];
    [ble controlSetup];
    ble.delegate = self;
    
    [self setViewControllerElements];
    [self videoSetup];
    
    CameraAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    _managedObjectContext = [appDelegate managedObjectContext];

    
}

-(void)viewDidAppear:(BOOL)animated{
    
    //[self setViewControllerElements];
    //self.navigationController.navigationBar.alpha = 0;
    
    [self btnScanForPeripherals];
    
}

-(void)setViewControllerElements{
    NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
    //NSString *path = [[NSBundle mainBundle] pathForResource:@"CaptureSettings" ofType:@"plist"];
    //NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
    _numberOfImages = [prefs integerForKey:@"numberOfImages"];
    NSLog(@"Number of Images: %d", _numberOfImages);
    //[[dict objectForKey:@"numberOfImages"] intValue];
    _captureDelay = [prefs floatForKey:@"captureDelay"];//[[dict objectForKey:@"captureDelay"] intValue];
    NSLog(@"Capture Delay: %d", _captureDelay);
    _counterLabel.hidden = YES;
    _counterLabel.text = nil;//@"";//[NSString stringWithFormat:@"",_numberOfImages];
    _imageArray = [[NSMutableArray alloc] init];
    _thumbnailArray = [[NSMutableArray alloc] init];
    _eyeImages = [[NSMutableArray alloc] init];
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
    else if(attempts < 3)
    {
        //[bleConnect setTitle:@"Connect"];
        NSLog(@"No peripherals found, initiaiting attemp number %d", attempts);
        [self btnScanForPeripherals];
        attempts++;
    }
}

- (void)bleDidDisconnect
{
    NSLog(@"->Disconnected");
    [self btnScanForPeripherals];
    
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

- (void)flashOn:(float) duration {
    
    //NSLog(@"NSInteger light %d", light);
 
    
    NSNumber *n = [[NSNumber alloc] initWithInteger: 9];
    
    UInt8 tre = [n intValue];
    NSLog(@"Big Flash");
    
    UInt8 buf[3] = {tre, 0x01, 0x00};
    
    NSLog(@"Flash On");
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [ble write:data];
    
    [NSTimer scheduledTimerWithTimeInterval:(float)duration
                                     target:self
                                   selector:@selector(flashTimer:)
                                   userInfo:n  repeats:NO];
    
}

-(void) flashTimer: (NSTimer *) theTimer{
    
    UInt8 foo = [[theTimer userInfo] intValue];
    
    NSLog(@"HI %d",foo);
    UInt8 buf[3] = {foo, 0x00, 0x00};
    NSLog(@"Flash off by timer");
    
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [ble write:data];
}

-(void) turnFixationLightON: (NSInteger) light{
    
    NSNumber *n = [[NSNumber alloc] initWithInteger:light];
    
    UInt8 tre = [n intValue];
    NSLog(@"Fixation Light Number!!!! %d", tre);
    
    UInt8 buf[3] = {tre, 0x01, 0x00};
    
    NSLog(@"Flash On");
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

- (IBAction)didPressCapture:(id)sender {
    
    // Reveal counter label to display image count
    _counterLabel.hidden = NO;
    AVCaptureConnection *videoConnection = [self getVideoConnection];
    
    
    
    
    // Capture images on a background thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        for(int index = 1; index <= _numberOfImages; ++index){
            /*
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                _counterLabel.text = [NSString stringWithFormat:@"%d/%d",index,_numberOfImages];
                NSLog(@"Image %d of %d",index,_numberOfImages);
                
            }];
            */
            //NSLog(@"Before sleep");
            [NSThread sleepForTimeInterval:1];//_captureDelay];
            //NSLog(@"After sleep");
            [self takeStillFromConnection:videoConnection];
            
            if(index == _numberOfImages){
                [_activityIndicator startAnimating];
                NSLog(@"Activity Indicator has started.");
            }
            
        }
    });
    
    NSLog(@"didPressCapture Completed");
  
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

/*
- (void)takeStillFromConnection:(AVCaptureConnection*)videoConnection{
    
	NSLog(@"Saving Image...");
    
	[_stillOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         // Turn off flash
         [self turnTorchOn:NO];
         
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         EImage *image = [[EImage alloc] initWithData:imageData];
         image.eye = self.selectedEye;
         image.fixationLight = self.selectedLight;
         image.date = [NSDate date];
         image.selected = NO;
         
         
         float scaleFactor = [[NSUserDefaults standardUserDefaults] floatForKey:@"ImageScaleFactor"];
         CGSize smallSize = [image size];
         smallSize.height = smallSize.height/scaleFactor;
         smallSize.width = smallSize.width/scaleFactor;
         image.thumbnail = [image resizedImage:smallSize interpolationQuality:kCGInterpolationDefault];
         
         // Add the capture image to the image array
         
         [_imageArray addObject:image];
         
         //[_thumbnailArray addObject:thumbnail];
         
         NSLog(@"Saved Image %lu!",[_imageArray count]);
         
         // Update the counter label
         if([_imageArray count]<10)
             _counterLabel.text = [NSString stringWithFormat:@"0%lu",(unsigned long)[_imageArray count]];
         else
             _counterLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)[_imageArray count]];
         
         NSLog(@"Image %lu of %d",(unsigned long)[_imageArray count],_numberOfImages);
         
         // Once all images are captured, segue to the Image Selection View
         if([_imageArray count] >= _numberOfImages){
             [_activityIndicator stopAnimating];
             [self performSegueWithIdentifier:@"ImageSelectionSegue" sender:self];
         }
         
     }];

}
*/


// PJ LOURYS TAKE ON IT
- (void)takeStillFromConnection:(AVCaptureConnection*)videoConnection{
    
	NSLog(@"Saving Image...");
    
	[_stillOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         UIImage *image = [[UIImage alloc] initWithData:imageData];
         
         // Add the capture image to the image array
         //[_imageArray addObject:image];
         
         float scaleFactor = [[NSUserDefaults standardUserDefaults] floatForKey:@"ImageScaleFactor"];
         CGSize smallSize = [image size];
         smallSize.height = smallSize.height/scaleFactor;
         smallSize.width = smallSize.width/scaleFactor;
         UIImage* thumbnail = [image resizedImage:smallSize interpolationQuality:kCGInterpolationDefault];
         
         [_thumbnailArray addObject:thumbnail];
         
         NSLog(@"Saved Image %lu!",[_imageArray count]);
         
         
         EyeImage* ei = (EyeImage*)[NSEntityDescription insertNewObjectForEntityForName:@"EyeImage" inManagedObjectContext:self.managedObjectContext];
         
         ei.date = [NSDate date];
         //newImage.drName = self.currentImage.drName;
         ei.eye = _selectedEye;
         [self saveImage:image];
         ei.filePath = file;
         NSNumber *myNum = [NSNumber numberWithInteger:_selectedLight];
         ei.fixationLight = myNum;
         ei.thumbnail = UIImagePNGRepresentation(thumbnail);
         ei.exam = _currentExam;
         
         [_eyeImages addObject: ei];
         
         
         // Update the counter label
         if([_thumbnailArray count]<10)
             _counterLabel.text = [NSString stringWithFormat:@"0%lu",(unsigned long)[_thumbnailArray count],_numberOfImages];
         else
             _counterLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)[_thumbnailArray count],_numberOfImages];
         
         NSLog(@"Image %lu of %d",(unsigned long)[_thumbnailArray count],_numberOfImages);
         
         // Once all images are captured, segue to the Image Selection View
         if([_thumbnailArray count] >= _numberOfImages){
             [_activityIndicator stopAnimating];
             [self performSegueWithIdentifier:@"ImageSelectionSegue" sender:self];
         }
         
     }];
    
}



-(void)saveImage:(UIImage*) image{
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
            
            NSLog(@"Added image to asset library");
            //[_imageArray addObject:[assetURL absoluteString]];
            
            file = [assetURL absoluteString];
            
        }
    }]; // end of completion block
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    self.navigationController.navigationBar.alpha = 1;
    ImageSelectionViewController* isvc = (ImageSelectionViewController*)[segue destinationViewController];
    isvc.images = _imageArray;
    isvc.thumbnails = _thumbnailArray;
    isvc.eyeImages = _eyeImages;
    
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

@end
