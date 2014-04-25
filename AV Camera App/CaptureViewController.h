//
//  CaptureViewController.h
//  OcularCellscope
//
//  Created by Chris Echanique on 2/21/14.
//  Copyright (c) 2014 UC Berkeley Ocular CellScope. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CellScopeContext.h"

@import AVFoundation;
@import AssetsLibrary;
@import UIKit;

@interface CaptureViewController : UIViewController<BLEDelegate>

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *aiv;
@property (strong, nonatomic) IBOutlet UIButton *captureButton;
@property (strong, nonatomic) IBOutlet UILabel *counterLabel;
@property (assign, nonatomic) int selectedLight;
@property (copy, nonatomic) NSString *selectedEye;
@property (strong, nonatomic) IBOutlet UISwitch *swDigitalOut;
@property (strong, nonatomic) BLE *ble;
@property (assign, nonatomic) BOOL alreadyLoaded;
@property (strong, nonatomic) Exam *currentExam;

- (IBAction)didPressCapture:(id)sender;
-(void) toggleAuxilaryLight: (NSInteger) light toggleON: (BOOL) switchON;
-(AVCaptureConnection*)getVideoConnection;
- (void)takeStillFromConnection:(AVCaptureConnection*)videoConnection;

@end
