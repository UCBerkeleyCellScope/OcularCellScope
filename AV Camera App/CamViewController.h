//
//  CamViewController.h
//  OcularCellscope
//
//  Created by Chris Echanique on 4/17/14.
//  Copyright (c) 2014 UC Berkeley Ocular CellScope. All rights reserved.
//
//  The CamViewController provides a way for the user to preview the camera, adjust focus/exposure,
//  and initiate the capture sequence. During the capture sequence, this view controller automates
//  the flash and fixation lights. The capture sequence may include multiple photos (and a specified delay between each one).

#import <UIKit/UIKit.h>
#import "CellScopeContext.h"
#import "BLEManager.h"
#import "AVCaptureManager.h"


@interface CamViewController : UIViewController<ImageCaptureDelegate, BLEConnectionDelegate>

//manages the camera
@property (strong, nonatomic) AVCaptureManager *captureManager;

//some basic properties for the automated image capture
@property (assign, nonatomic) int currentImageCount;
@property (weak, nonatomic) NSTimer *repeatingTimer;
@property (weak, nonatomic) NSTimer *waitForBle;

//images are stored to this array during acquisition (not ideal)
@property (strong, nonatomic) NSMutableArray *imageArray;

//focus and exposure settings, adjustable from this UI
@property (nonatomic) float currentFocusPosition;
@property (nonatomic) float currentExposureDuration;

//UI elements
@property (strong, nonatomic) IBOutlet UILabel *counterLabel;
@property (weak, nonatomic) IBOutlet UILabel *bleDisabledLabel;
@property (strong, nonatomic) IBOutlet UIButton *captureButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *aiv;
@property (weak, nonatomic) IBOutlet UIImageView *capturedImageView;
@property (strong, nonatomic) IBOutlet UIImageView *fixationImageView;
@property (weak, nonatomic) IBOutlet UIView *exposureBarView;
@property (weak, nonatomic) IBOutlet UIImageView *exposureBarIndicator;
@property (weak, nonatomic) IBOutlet UIView *focusBarView;
@property (weak, nonatomic) IBOutlet UIImageView *focusBarIndicator;
@property (weak, nonatomic) IBOutlet UILabel *focusValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *exposureValueLabel;

@property (strong, nonatomic) IBOutlet UIButton *pauseButton;

@property (strong, nonatomic) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (strong, nonatomic)  UIPanGestureRecognizer *panGestureRecognizer;


@property (assign, nonatomic) BOOL mirroredView;
@property (assign, nonatomic) BOOL fullscreeningMode;

// which fixation light is currently selected?
@property (nonatomic, assign) long selectedLight;


// This function initiates the capture sequence.
- (IBAction)didPressCapture:(id)sender;


@end
