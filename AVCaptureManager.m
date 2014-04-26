//
//  AVCaptureManager.m
//  OcularCellscope
//
//  Created by Chris Echanique on 4/17/14.
//  Copyright (c) 2014 UC Berkeley Ocular CellScope. All rights reserved.
//

#import "AVCaptureManager.h"
#import "NSMutableDictionary+ImageMetadata.h"

@implementation AVCaptureManager

@synthesize session = _session;
@synthesize device = _device;
@synthesize deviceInput = _deviceInput;
@synthesize previewLayer = _previewLayer;
@synthesize stillOutput = _stillOutput;
@synthesize delegate = _delegate;
@synthesize isExposureLocked = _isExposureLocked;
@synthesize isCapturingImages = _isCapturingImages;
@synthesize lastImageMetadata = _lastImageMetadata;


-(id)init{
    self = [super init];
    
    if(self){
        self.isCapturingImages = NO;
        
        // Create a new photo session
        self.session = [[AVCaptureSession alloc] init];
        [self.session setSessionPreset:AVCaptureSessionPresetPhoto];
        
        // Set device to video
        self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        // Add device to session
        self.deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:Nil];
        if ( [self.session canAddInput:self.deviceInput] )
            [self.session addInput:self.deviceInput];
        
        // Add still image output
        self.stillOutput = [[AVCaptureStillImageOutput alloc] init];
        NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
        [self.stillOutput setOutputSettings:outputSettings];
        [self.session addOutput:self.stillOutput];
        
        // Set preview layer
        self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
        //AVLayerVideoGravityResizeAspectFill];
    }
    
    return self;
}

-(void)setupVideoForView:(UIView*)view{
    self.view = view;
    
    // Added gesture recognizer for taps to focus
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    [self.view addGestureRecognizer:gestureRecognizer];
    
    // Set the preview layer to the bounds of the screen
    CALayer *rootLayer = [self.view layer];
    [rootLayer setMasksToBounds:YES];
    [self.previewLayer setFrame:CGRectMake(-70, 0, rootLayer.bounds.size.height, rootLayer.bounds.size.height)];
    [rootLayer insertSublayer:self.previewLayer atIndex:0];
    
    // Invert the screen for optics
    //self.previewLayer.affineTransform = CGAffineTransformInvert(CGAffineTransformMakeRotation(M_PI));
    
    [self.session startRunning];
    [self unlockFocus];
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

-(void)takePicture{
    
    // Set boolean for capturing images
    self.isCapturingImages = YES;
    
    AVCaptureConnection *videoConnection = [self getVideoConnection];
    
    // Asynchronous call to capture image
	[_stillOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         self.lastImageMetadata = [[NSMutableDictionary alloc] initWithImageSampleBuffer:imageSampleBuffer];
         
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         
         // Call to delegate to do something with this image data
         [self.delegate didCaptureImageWithData:imageData];
     }];
}

-(void)lockFocus{
    if ([self.device isFocusModeSupported:AVCaptureFocusModeLocked]) {
        [self.device lockForConfiguration:nil];
        [self.device setFocusMode:AVCaptureFocusModeLocked];
        [self.device unlockForConfiguration];
    }
}

- (void)setExposureLock:(BOOL)locked
{
    NSError* error;
    if ([self.device lockForConfiguration:&error])
    {
        if (locked)
            [self.device setExposureMode:AVCaptureExposureModeLocked];
        else
            [self.device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        self.isExposureLocked = locked;
        [self.device unlockForConfiguration];
    }
    else
        NSLog(@"Error: %@",error);
    
}

-(void)unlockFocus{
    if ([self.device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
        CGPoint autofocusPoint = CGPointMake(0.5f, 0.5f);
        [self.device lockForConfiguration:nil];
        [self.device setFocusPointOfInterest:autofocusPoint];
        [self.device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        [self.device unlockForConfiguration];
    }
}

-(void)setFocusWithPoint:(CGPoint)focusPoint{
    if([self.device isFocusModeSupported:AVCaptureFocusModeAutoFocus] && [self.device isFocusPointOfInterestSupported]){
        [self.device lockForConfiguration:nil];
        [self.device setFocusPointOfInterest:focusPoint];
        [self.device setFocusMode:AVCaptureFocusModeAutoFocus];
        [self.device unlockForConfiguration];
    }
}

- (IBAction)viewTapped:(id)sender {
    // Focuses camera if not currently capturing images
    if(!self.isCapturingImages){
        CGPoint tapPoint = [sender locationInView:self.view];
        CGPoint focusPoint = CGPointMake(tapPoint.x/self.view.bounds.size.width, tapPoint.y/self.view.bounds.size.height);
        NSLog(@"x = %f, y = %f",focusPoint.x,focusPoint.y);
        [self setFocusWithPoint:focusPoint];
    }
}


@end
