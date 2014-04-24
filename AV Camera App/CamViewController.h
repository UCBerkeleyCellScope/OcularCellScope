//
//  CamViewController.h
//  OcularCellscope
//
//  Created by Chris Echanique on 4/17/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CellScopeContext.h"
#import "BLEManager.h"
#import "AVCaptureManager.h"


@interface CamViewController : UIViewController<ImageCaptureDelegate, BLEConnectionDelegate>

@property (strong, nonatomic) BLEManager *bleManager;
@property (strong, nonatomic) AVCaptureManager *captureManager;
@property (assign, nonatomic) int currentImageCount;
@property (weak, nonatomic) NSTimer *repeatingTimer;
@property (weak, nonatomic) NSTimer *waitForBle;

@property (strong, nonatomic) NSMutableArray *imageArray;
@property (strong, nonatomic) IBOutlet UILabel *counterLabel;
@property (weak, nonatomic) IBOutlet UILabel *bleDisabledLabel;

@property (strong, nonatomic) IBOutlet UIButton *captureButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *aiv;
@property (strong, nonatomic) IBOutlet UIButton *settingsButton;
@property (strong, nonatomic) IBOutlet UIImageView *capturedImageView;
@property (strong, nonatomic) IBOutlet UIButton *pauseButton;

@property (assign, nonatomic) int selectedLight;
@property (copy, nonatomic) NSString *selectedEye;
@property (strong, nonatomic) NSUserDefaults *prefs;


- (IBAction)didPressCapture:(id)sender;


@end