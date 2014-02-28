//
//  CaptureViewController.m
//  OcularCellscope
//
//  Created by Chris Echanique on 2/21/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import "CaptureViewController.h"
#import "Constants.h"
#import "ImageSelectionViewController.h"
@import AVFoundation;
@import AssetsLibrary;

@interface CaptureViewController ()

@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) AVCaptureDevice *device;
@property (strong, nonatomic) AVCaptureDeviceInput *deviceInput;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (strong, nonatomic) AVCaptureStillImageOutput *stillOutput;
@property (strong, atomic) NSMutableArray *imageArray;
@property (assign, nonatomic) int numberOfImages;
@property (assign, nonatomic) int captureDelay;

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
    
    [self videoSetup];
}

-(void)viewWillAppear:(BOOL)animated{
    
    [self setViewControllerElements];
    self.navigationController.navigationBar.alpha = 0;
    
}

-(void)setViewControllerElements{
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"CaptureSettings" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
    _numberOfImages = [[dict objectForKey:@"numberOfImages"] intValue];
    _captureDelay = [[dict objectForKey:@"captureDelay"] intValue];
    
    _counterLabel.hidden = YES;
    _counterLabel.text = [NSString stringWithFormat:@"1/%d",_numberOfImages];
    _imageArray = [[NSMutableArray alloc] init];
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
    
    _counterLabel.hidden = NO;
    AVCaptureConnection *videoConnection = [self getVideoConnection];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        for(int index = 1; index <= _numberOfImages; ++index){
            dispatch_async(dispatch_get_main_queue(), ^{
                // this happens on main thread
                _counterLabel.text = [NSString stringWithFormat:@"%d/%d",index,_numberOfImages];
            });
            [NSThread sleepForTimeInterval:_captureDelay];
            [self turnTorchOn:YES];
            [self takeStillFromConnection:videoConnection];
            [self turnTorchOn:NO];
            if(index == _numberOfImages)
                [_activityIndicator startAnimating];
            
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

- (void)takeStillFromConnection:(AVCaptureConnection*)videoConnection{
    
	NSLog(@"Saving Image...");
    
	[_stillOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         UIImage *image = [[UIImage alloc] initWithData:imageData];
         
         [_imageArray addObject:image];
         
         NSLog(@"Saved Image %lu!",[_imageArray count]);
         
         if([_imageArray count] >= _numberOfImages){
             [_activityIndicator stopAnimating];
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

@end
