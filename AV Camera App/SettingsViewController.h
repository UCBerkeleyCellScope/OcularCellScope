//
//  SettingsViewController.h
//  OcularCellscope
//
//  Created by PJ Loury on 3/21/14.
//  Copyright (c) 2014 UC Berkeley Ocular CellScope. All rights reserved.
//
//  This view controller allows the user to configure the cellscope.

#import <UIKit/UIKit.h>
#import "CellScopeContext.h"

@interface SettingsViewController : UITableViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *debugToggle;
@property (weak, nonatomic) IBOutlet UISegmentedControl *multiShot;


@property (weak, nonatomic) IBOutlet UISwitch *mirrorToggle;

@property (weak, nonatomic) IBOutlet UISlider *redFocusSlider;
@property (weak, nonatomic) IBOutlet UILabel *redFocusLabel;
@property (weak, nonatomic) IBOutlet UISlider *whiteFocusSlider;
@property (weak, nonatomic) IBOutlet UILabel *whiteFocusLabel;

@property (weak, nonatomic) IBOutlet UISlider *whiteFlashSlider;
@property (weak, nonatomic) IBOutlet UILabel *whiteFlashLabel;
@property (weak, nonatomic) IBOutlet UISlider *redFlashSlider;
@property (weak, nonatomic) IBOutlet UILabel *redFlashLabel;

@property (weak, nonatomic) IBOutlet UILabel *focalPositionLabel;
@property (weak, nonatomic) IBOutlet UITextField *focalPositionTextField;
@property (weak, nonatomic) IBOutlet UILabel *previewExposureLabel;
@property (weak, nonatomic) IBOutlet UITextField *previewExposureTextField;
@property (weak, nonatomic) IBOutlet UILabel *previewFlashRatioLabel;
@property (weak, nonatomic) IBOutlet UITextField *previewFlashRatioTextField;
@property (weak, nonatomic) IBOutlet UILabel *previewISOLabel;
@property (weak, nonatomic) IBOutlet UITextField *previewISOTextField;
@property (weak, nonatomic) IBOutlet UILabel *flashISOLabel;
@property (weak, nonatomic) IBOutlet UITextField *flashISOTextField;
@property (weak, nonatomic) IBOutlet UILabel *previewWBLabel;
@property (weak, nonatomic) IBOutlet UITextField *previewWBRedTextField;
@property (weak, nonatomic) IBOutlet UITextField *previewWBGreenTextField;
@property (weak, nonatomic) IBOutlet UITextField *previewWBBlueTextField;
@property (weak, nonatomic) IBOutlet UILabel *flashWBLabel;
@property (weak, nonatomic) IBOutlet UITextField *flashWBRedTextField;
@property (weak, nonatomic) IBOutlet UITextField *flashWBGreenTextField;
@property (weak, nonatomic) IBOutlet UITextField *flashWBBlueTextField;


@property (weak, nonatomic) IBOutlet UITextField *captureInterval;
@property (weak, nonatomic) IBOutlet UITextField *flashDurationMultiplier;
@property (weak, nonatomic) IBOutlet UITextField *flashDelay;

@property(strong, nonatomic) BLEManager *bleManager;
@property (weak, nonatomic) IBOutlet UITextField *cellscopeIDTextField;


- (IBAction)toggleDidChange:(id)sender;

- (IBAction)redFocusSliderDidChange:(id)sender;
- (IBAction)whiteFocusSliderDidChange:(id)sender;

- (IBAction)whiteFlashSliderDidChange:(id)sender;
- (IBAction)redFlashSliderDidChange:(id)sender;

- (IBAction)multiShotValueChanged:(id)sender;

@end
