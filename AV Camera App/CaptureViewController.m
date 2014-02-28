//
//  CaptureViewController.m
//  OcularCellscope
//
//  Created by Chris Echanique on 2/21/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import "CaptureViewController.h"

@import AVFoundation;
@import AssetsLibrary;

@interface CaptureViewController ()
@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) AVCaptureDevice *device;
@property (strong, nonatomic) AVCaptureDeviceInput *deviceInput;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (strong, nonatomic) AVCaptureStillImageOutput *stillOutput;


@end

@implementation CaptureViewController

@synthesize session, device, deviceInput, previewLayer, stillOutput;

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
    self.navigationController.navigationBar.alpha = 0;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    self.navigationController.navigationBar.alpha = 1;
}


-(void)videoSetup
{
    session = [[AVCaptureSession alloc] init];
    [session setSessionPreset:AVCaptureSessionPresetPhoto];
    
    device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:Nil];
    if ( [session canAddInput:deviceInput] )
        [session addInput:deviceInput];
    
    previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    stillOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [stillOutput setOutputSettings:outputSettings];
    [session addOutput:stillOutput];
    [session startRunning];
    
    CALayer *rootLayer = [[self view] layer];
    [rootLayer setMasksToBounds:YES];
    [previewLayer setFrame:CGRectMake(-70, 0, rootLayer.bounds.size.height, rootLayer.bounds.size.height)];
    [rootLayer insertSublayer:previewLayer atIndex:0];
    
    //previewLayer.affineTransform = CGAffineTransformInvert(CGAffineTransformMakeRotation(M_PI));
    
    [session startRunning];
}

- (IBAction)didPressCapture:(id)sender {
    
    AVCaptureConnection *videoConnection = [self getVideoConnection];
    
    [self takeStillFromConnection:videoConnection];
    
    NSLog(@"did get image");
}

-(AVCaptureConnection*)getVideoConnection{
    AVCaptureConnection *videoConnection = nil;
	for (AVCaptureConnection *connection in self.stillOutput.connections)
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

- (void)takeStillFromConnection:(AVCaptureConnection*)videoConnection {
    
    
	NSLog(@"about to request a capture from: %@", stillOutput);
    
    [self.activityIndicator startAnimating];
    
	[stillOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         [self.activityIndicator stopAnimating];
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         UIImage *image = [[UIImage alloc] initWithData:imageData];
         
     }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
