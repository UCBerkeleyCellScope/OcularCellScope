//
//  LeftLightViewController.h
//  AV Camera App
//
//  Created by NAYA LOUMOU on 11/24/13.
//  Copyright (c) 2013 NAYA LOUMOU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Exam.h"
#import "EyeImage.h"
#import "BLE.h"

@interface CameraViewController : UIViewController
{
    
}
@property (weak, nonatomic) IBOutlet UIView *preview;


- (IBAction)didPressCapture:(id)sender;
- (IBAction)didPressNext:(id)sender;


- (IBAction)controlFocus:(id)sender;
- (IBAction)controlExpo:(id)sender;

@property (weak, nonatomic) IBOutlet UIBarButtonItem* nextButton;
@property (weak, nonatomic) IBOutlet UIButton* captureButton;
@property (weak, nonatomic) IBOutlet UIButton* exposureButton;
@property (weak, nonatomic) IBOutlet UIButton* focusButton;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillOutput;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Exam* currentExam;
@property (strong, nonatomic) EyeImage* currentImage;
@property (strong, nonatomic) BLE* ble;
@property (weak, nonatomic) IBOutlet UIBarButtonItem* camButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *bleConnect;

@end