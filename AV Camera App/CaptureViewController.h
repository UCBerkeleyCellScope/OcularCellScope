//
//  CaptureViewController.h
//  OcularCellscope
//
//  Created by Chris Echanique on 2/21/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CellScopeContext.h"

@import AVFoundation;
@import AssetsLibrary;
@import UIKit;

@interface CaptureViewController : UIViewController<BLEDelegate>

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *aiv;
@property (weak, nonatomic) IBOutlet UIButton *captureButton;
@property (strong, nonatomic) IBOutlet UILabel *counterLabel;
@property (nonatomic) int selectedLight;
@property (copy, nonatomic) NSString *selectedEye;
@property (weak, nonatomic) IBOutlet UISwitch *swDigitalOut;

@property (strong, nonatomic) BLE *ble;

@property BOOL alreadyLoaded;

@property (strong, nonatomic) Exam *currentExam;
- (IBAction)didPressCapture:(id)sender;

-(void) toggleAuxilaryLight: (NSInteger) light toggleON: (BOOL) switchON;
-(AVCaptureConnection*)getVideoConnection;
- (void)takeStillFromConnection:(AVCaptureConnection*)videoConnection;
@end
