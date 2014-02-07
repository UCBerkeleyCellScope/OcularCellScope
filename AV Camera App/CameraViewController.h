//
//  LeftEyeViewController.h
//  AV Camera App
//
//  Created by NAYA LOUMOU on 11/24/13.
//  Copyright (c) 2013 NAYA LOUMOU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Patient.h"
#import "Image.h"
#import "BLE.h"

@interface CameraViewController : UIViewController<BLEDelegate>
{
    IBOutlet UIBarButtonItem *bleConnect;
    }
@property (weak, nonatomic) IBOutlet UIView *preview;

- (IBAction)handleLongPress:(UILongPressGestureRecognizer *) longPress;
- (IBAction)handlePinch:(UIPinchGestureRecognizer *)recognizer; //delete that
- (IBAction)handlePan:(UIPanGestureRecognizer *)panGesture;
- (IBAction)didPressCapture:(id)sender;
- (IBAction)didPressNext:(id)sender;





//- (IBAction)didPressRight:(id)sender;
//- (IBAction)didPressLeft:(id)sender;


@property (weak, nonatomic) IBOutlet UIBarButtonItem *camButton;


@property (weak, nonatomic) IBOutlet UIBarButtonItem* nextButton;
@property (weak, nonatomic) IBOutlet UIButton* captureButton;

//@property (weak, nonatomic) IBOutlet UIButton* RightEyeButton;
//@property (weak, nonatomic) IBOutlet UIButton* LeftEyeButton;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoPreviewOutput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoHDOutput;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillOutput;


@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Patient* currentPatient;
@property (strong, nonatomic) Image* currentImage;

@property (strong, nonatomic) BLE *ble;

@end