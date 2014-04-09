//
//  SettingsViewController.h
//  OcularCellscope
//
//  Created by PJ Loury on 3/21/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
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

@property (weak, nonatomic) IBOutlet UISwitch *debugToggle;
- (IBAction)toggleDidChange:(id)sender;
- (IBAction)didPressDone:(id)sender;
- (IBAction)flashSliderDidChange:(id)sender;
- (IBAction)redSliderDidChange:(id)sender;
- (IBAction)multiShotValueChanged:(id)sender;

@end
