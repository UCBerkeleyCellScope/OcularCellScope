//
//  SettingsViewController.h
//  OcularCellscope
//
//  Created by PJ Loury on 3/21/14.
//  Copyright (c) 2014 UC Berkeley Ocular CellScope. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CellScopeContext.h"

@interface SettingsViewController : UITableViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UISlider *flashLightSlider;
@property (weak, nonatomic) IBOutlet UISlider *redLightSlider;
@property (weak, nonatomic) IBOutlet UILabel *flashLightLabel;
@property (weak, nonatomic) IBOutlet UILabel *redLightLabel;

@property (nonatomic) NSInteger flashLightValue;
@property (nonatomic) NSInteger redLightValue;

@property (weak, nonatomic) NSString *multiText;

@property (weak, nonatomic) IBOutlet UITextField *bleDelay;
@property (weak, nonatomic) IBOutlet UITextField *captureDelay;
@property (weak, nonatomic) IBOutlet UITextField *flashDuration;
@property (weak, nonatomic) IBOutlet UISegmentedControl *multiShot;
@property (weak, nonatomic) IBOutlet UISwitch *timedFlashSwitch;

@property(strong, nonatomic) BLEManager *bleManager;

@property (weak, nonatomic) IBOutlet UISwitch *debugToggle;
- (IBAction)toggleDidChange:(id)sender;
- (IBAction)flashSliderDidChange:(id)sender;
- (IBAction)redSliderDidChange:(id)sender;
- (IBAction)multiShotValueChanged:(id)sender;
- (IBAction)timedFlashToggleDidChange:(id)sender;

@property (weak, nonatomic) IBOutlet UISlider *remoteLightSlider;
- (IBAction)remoteLightSliderDidChange:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *remoteLightLabel;

@end
