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

@property (weak, nonatomic) IBOutlet UISwitch *debugToggle;
@property (weak, nonatomic) IBOutlet UISegmentedControl *multiShot;

@property (weak, nonatomic) IBOutlet UITextField *bleDelay;
@property (weak, nonatomic) IBOutlet UISwitch *mirrorToggle;

@property (weak, nonatomic) IBOutlet UISlider *redFocusSlider;
@property (weak, nonatomic) IBOutlet UILabel *redFocusLabel;
@property (weak, nonatomic) IBOutlet UISlider *whiteFocusSlider;
@property (weak, nonatomic) IBOutlet UILabel *whiteFocusLabel;

@property (weak, nonatomic) IBOutlet UISlider *whiteFlashSlider;
@property (weak, nonatomic) IBOutlet UILabel *whiteFlashLabel;
@property (weak, nonatomic) IBOutlet UISlider *redFlashSlider;
@property (weak, nonatomic) IBOutlet UILabel *redFlashLabel;

@property (nonatomic) NSInteger whiteFlashValue;
@property (nonatomic) NSInteger redFocusValue;

@property (nonatomic) NSInteger redFlashValue;
@property (nonatomic) NSInteger whiteFocusValue;

@property (weak, nonatomic) NSString *multiText;

@property (weak, nonatomic) IBOutlet UITextField *captureDelay;
//@property (weak, nonatomic) IBOutlet UITextField *flashDuration;
@property (weak, nonatomic) IBOutlet UITextField *arduinoDelay;

//@property (weak, nonatomic) IBOutlet UISwitch *timedFlashSwitch;

@property(strong, nonatomic) BLEManager *bleManager;


- (IBAction)toggleDidChange:(id)sender;

- (IBAction)redFocusSliderDidChange:(id)sender;
- (IBAction)whiteFocusSliderDidChange:(id)sender;

- (IBAction)whiteFlashSliderDidChange:(id)sender;
- (IBAction)redFlashSliderDidChange:(id)sender;

- (IBAction)multiShotValueChanged:(id)sender;
//- (IBAction)timedFlashToggleDidChange:(id)sender;

@property (weak, nonatomic) IBOutlet UISlider *remoteLightSlider;
- (IBAction)remoteLightSliderDidChange:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *remoteLightLabel;

@end
