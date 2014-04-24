//
//  AVCaptureManager.m
//  OcularCellscope
//
//  Created by Chris Echanique on 4/17/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import "AVCaptureManager.h"

@implementation AVCaptureManager

@synthesize session = _session;
@synthesize device = _device;
@synthesize deviceInput = _deviceInput;
@synthesize previewLayer = _previewLayer;
@synthesize stillOutput = _stillOutput;
@synthesize delegate = _delegate;

-(void)setupVideoForView:(UIView*)view{
    self.view = view;
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    [self.view addGestureRecognizer:gestureRecognizer];
    
    
    // Create a new photo session
    self.session = [[AVCaptureSession alloc] init];
    [self.session setSessionPreset:AVCaptureSessionPresetPhoto];
    
    // Set device to video
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Add device to session
    self.deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:Nil];
    if ( [self.session canAddInput:self.deviceInput] )
        [self.session addInput:self.deviceInput];
    
    // Set preview layer
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    // Add still image output
    self.stillOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [self.stillOutput setOutputSettings:outputSettings];
    [self.session addOutput:self.stillOutput];
    
    // Set the preview layer to the bounds of the screen
    CALayer *rootLayer = [self.view layer];
    [rootLayer setMasksToBounds:YES];
    [self.previewLayer setFrame:CGRectMake(-70, 0, rootLayer.bounds.size.height, rootLayer.bounds.size.height)];
    [rootLayer insertSublayer:self.previewLayer atIndex:0];
    
    // Invert the screen for optics
    //self.previewLayer.affineTransform = CGAffineTransformInvert(CGAffineTransformMakeRotation(M_PI));
    
    [self.session startRunning];
    [self lockFocus];
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
    
    AVCaptureConnection *videoConnection = [self getVideoConnection];
	[_stillOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         
         
         [self.delegate didCaptureImageWithData:imageData];
     }];
}

-(void)lockFocus{
    if ([self.device isFocusModeSupported:AVCaptureFocusModeLocked]) {
        CGPoint autofocusPoint = CGPointMake(0.5f, 0.5f);
        [self.device lockForConfiguration:nil];
        [self.device setFocusPointOfInterest:autofocusPoint];
        [self.device setFocusMode:AVCaptureFocusModeLocked];
        [self.device unlockForConfiguration];
    }
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
    if ([self.device isFocusModeSupported:AVCaptureFocusModeLocked]) {
        [self.device lockForConfiguration:nil];
        [self.device setFocusPointOfInterest:focusPoint];
        [self.device setFocusMode:AVCaptureFocusModeLocked];
        [self.device unlockForConfiguration];
    }
}

- (IBAction)viewTapped:(id)sender {
    CGPoint tapPoint = [sender locationInView:self.view];
    
    CGPoint focusPoint = CGPointMake(tapPoint.x/self.view.bounds.size.width, tapPoint.y/self.view.bounds.size.height);
    NSLog(@"x = %f, y = %f",focusPoint.x,focusPoint.y);
    [self setFocusWithPoint:focusPoint];
}

/*
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer  fromConnection:(AVCaptureConnection *)connection
*/

@end
