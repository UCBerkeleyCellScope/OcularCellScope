//
//  SettingsViewController.m
//  OcularCellscope
//
//  Created by PJ Loury on 3/21/14.
//  Copyright (c) 2014 UC Berkeley Ocular CellScope. All rights reserved.
//

#import "SettingsViewController.h"
#import "CameraAppDelegate.h"
#import "CameraAppDelegate.h"
#import "FixationViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

double whiteFlashStart,whiteFlashEnd,redFocusStart,redFocusEnd;
double redFlashStart,redFlashEnd,whiteFocusStart,whiteFocusEnd;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _bleManager = [[CellScopeContext sharedContext]bleManager];
    
    //register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
}

-(void) viewWillAppear:(BOOL)animated{
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
     
    int whiteFlashValue =  [prefs integerForKey: @"whiteFlashValue"];
    int redFocusValue =  [prefs integerForKey: @"redFocusValue"];
    int whiteFocusValue =  [prefs integerForKey: @"whiteFocusValue"];
    int redFlashValue =  [prefs integerForKey: @"redFlashValue"];
    
    self.whiteFlashSlider.value = whiteFlashValue;
    self.redFocusSlider.value = redFocusValue;
    self.whiteFocusSlider.value = whiteFocusValue;
    self.redFlashSlider.value = redFlashValue;
    self.whiteFlashLabel.text = [NSString stringWithFormat: @"%d", whiteFlashValue];
    self.redFocusLabel.text = [NSString stringWithFormat: @"%d", redFocusValue];
    self.redFlashLabel.text = [NSString stringWithFormat: @"%d", redFlashValue];
    self.whiteFocusLabel.text = [NSString stringWithFormat: @"%d", whiteFocusValue];

    
    self.focalPositionTextField.text = [NSString stringWithFormat:@"%1.2f",[prefs floatForKey:@"focusPosition"]];
    self.previewExposureTextField.text = [NSString stringWithFormat:@"%ld",[prefs integerForKey:@"previewExposureDuration"]];
    self.previewFlashRatioTextField.text = [NSString stringWithFormat:@"%1.1f",[prefs floatForKey:@"previewFlashRatio"]];
    self.previewISOTextField.text = [NSString stringWithFormat:@"%ld",[prefs integerForKey:@"previewISO"]];
    self.flashISOTextField.text = [NSString stringWithFormat:@"%ld",[prefs integerForKey:@"captureISO"]];
    self.previewWBRedTextField.text = [NSString stringWithFormat:@"%1.2f",[prefs floatForKey:@"previewRedGain"]];
    self.previewWBGreenTextField.text = [NSString stringWithFormat:@"%1.2f",[prefs floatForKey:@"previewGreenGain"]];
    self.previewWBBlueTextField.text = [NSString stringWithFormat:@"%1.2f",[prefs floatForKey:@"previewBlueGain"]];
    self.flashWBRedTextField.text = [NSString stringWithFormat:@"%1.2f",[prefs floatForKey:@"captureRedGain"]];
    self.flashWBGreenTextField.text = [NSString stringWithFormat:@"%1.2f",[prefs floatForKey:@"captureGreenGain"]];
    self.flashWBBlueTextField.text = [NSString stringWithFormat:@"%1.2f",[prefs floatForKey:@"captureBlueGain"]];
    self.flashDelay.text = [ NSString stringWithFormat:@"%ld",[prefs integerForKey: @"flashDelay"]];
    self.flashDurationMultiplier.text =  [ NSString stringWithFormat:@"%1.2f",[prefs floatForKey:@"flashDurationMultiplier"]];
    self.captureInterval.text = [NSString stringWithFormat:@"%3.2f",[prefs floatForKey:@"captureInterval"]];
    
    self.multiShot.selectedSegmentIndex = [prefs integerForKey:@"numberOfImages"]-1;
    
    self.cellscopeIDTextField.text = [prefs stringForKey:@"cellscopeID"];
    
}

-(void) viewWillDisappear:(BOOL)animated {

    //validation
    if (self.focalPositionTextField.text.floatValue<0.0)    self.focalPositionTextField.text = @"0.0";
    if (self.focalPositionTextField.text.floatValue>1.0)    self.focalPositionTextField.text = @"1.0";
    
    if (self.previewExposureTextField.text.intValue<25)      self.previewExposureTextField.text = @"25";
    if (self.previewExposureTextField.text.intValue>200)    self.previewExposureTextField.text = @"200";
    if (self.previewFlashRatioTextField.text.floatValue<1.0)  self.previewFlashRatioTextField.text = @"1.0";
    if (self.previewFlashRatioTextField.text.floatValue>10.0) self.previewFlashRatioTextField.text = @"10.0";
    
    if (self.previewISOTextField.text.intValue<64)          self.previewISOTextField.text = @"64";
    if (self.previewISOTextField.text.intValue>400)         self.previewISOTextField.text = @"400";
    if (self.flashISOTextField.text.intValue<64)            self.flashISOTextField.text = @"64";
    if (self.flashISOTextField.text.intValue>400)           self.flashISOTextField.text = @"400";
    
    if (self.previewWBRedTextField.text.floatValue<1.0)       self.previewWBRedTextField.text = @"1.0";
    if (self.previewWBRedTextField.text.floatValue>4.0)       self.previewWBRedTextField.text = @"4.0";
    if (self.previewWBGreenTextField.text.floatValue<1.0)           self.previewWBGreenTextField.text = @"1.0";
    if (self.previewWBGreenTextField.text.floatValue>4.0)           self.previewWBGreenTextField.text = @"4.0";
    if (self.previewWBBlueTextField.text.floatValue<1.0)           self.previewWBBlueTextField.text = @"1.0";
    if (self.previewWBBlueTextField.text.floatValue>4.0)           self.previewWBBlueTextField.text = @"4.0";
    if (self.flashWBRedTextField.text.floatValue<1.0)           self.flashWBRedTextField.text = @"1.0";
    if (self.flashWBRedTextField.text.floatValue>4.0)           self.flashWBRedTextField.text = @"4.0";
    if (self.flashWBGreenTextField.text.floatValue<1.0)           self.flashWBGreenTextField.text = @"1.0";
    if (self.flashWBGreenTextField.text.floatValue>4.0)           self.flashWBGreenTextField.text = @"4.0";
    if (self.flashWBBlueTextField.text.floatValue<1.0)           self.flashWBBlueTextField.text = @"1.0";
    if (self.flashWBBlueTextField.text.floatValue>4.0)           self.flashWBBlueTextField.text = @"4.0";
    
    if (self.flashDelay.text.intValue<0)           self.flashDelay.text = @"0";
    if (self.flashDelay.text.intValue>1023)           self.flashDelay.text = @"1023";

    if (self.flashDurationMultiplier.text.floatValue<1)           self.flashDurationMultiplier.text = @"1.0";
    if (self.flashDurationMultiplier.text.floatValue>5)           self.flashDurationMultiplier.text = @"5.0";
    
    if (self.captureInterval.text.floatValue<0.2)           self.captureInterval.text = @"0.2";
    if (self.captureInterval.text.floatValue>10.0)           self.captureInterval.text = @"10.0";

    //store settings
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs setInteger: self.whiteFlashSlider.value      forKey:@"whiteFlashValue"];
    [prefs setInteger: self.redFocusSlider.value     forKey:@"redFocusValue"];
    [prefs setInteger: self.redFlashSlider.value     forKey:@"redFlashValue"];
    [prefs setInteger: self.whiteFocusSlider.value      forKey:@"whiteFocusValue"];
    [prefs setFloat:   self.focalPositionTextField.text.floatValue  forKey:@"focusPosition"];
    [prefs setInteger: self.previewExposureTextField.text.intValue  forKey:@"previewExposureDuration"];
    [prefs setFloat:   self.previewFlashRatioTextField.text.floatValue  forKey:@"previewFlashRatio"];
    [prefs setInteger: self.previewISOTextField.text.intValue  forKey:@"previewISO"];
    [prefs setInteger: self.flashISOTextField.text.intValue  forKey:@"captureISO"];
    [prefs setFloat:   self.previewWBRedTextField.text.floatValue  forKey:@"previewRedGain"];
    [prefs setFloat:   self.previewWBGreenTextField.text.floatValue  forKey:@"previewGreenGain"];
    [prefs setFloat:   self.previewWBBlueTextField.text.floatValue  forKey:@"previewBlueGain"];
    [prefs setFloat:   self.flashWBRedTextField.text.floatValue  forKey:@"captureRedGain"];
    [prefs setFloat:   self.flashWBGreenTextField.text.floatValue  forKey:@"captureGreenGain"];
    [prefs setFloat:   self.flashWBBlueTextField.text.floatValue  forKey:@"captureBlueGain"];
    [prefs setInteger: self.flashDelay.text.intValue  forKey:@"flashDelay"];
    [prefs setFloat:   self.flashDurationMultiplier.text.floatValue  forKey:@"flashDurationMultiplier"];
    [prefs setFloat:   self.captureInterval.text.floatValue  forKey:@"captureInterval"];
    
    [prefs setInteger: self.multiShot.selectedSegmentIndex+1 forKey:@"numberOfImages"];
    
    [prefs setObject: self.cellscopeIDTextField.text forKey:@"cellscopeID"];
    
}

- (void)keyboardWasShown:(NSNotification *)sender {
    CGSize kbSize = [[[sender userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    NSTimeInterval duration = [[[sender userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGFloat height = UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation]) ? kbSize.height : kbSize.width;
    
    [UIView animateWithDuration:duration animations:^{
        UIEdgeInsets edgeInsets = [[self tableView] contentInset];
        edgeInsets.bottom = height;
        [[self tableView] setContentInset:edgeInsets];
        edgeInsets = [[self tableView] scrollIndicatorInsets];
        edgeInsets.bottom = height;
        [[self tableView] setScrollIndicatorInsets:edgeInsets];
    }];
}


/*
- (IBAction)toggleDidChange:(id)sender {

    if(debugToggle.on == YES){
        debugMode = YES;
        [_prefs setValue: @YES forKey:@"debugMode" ];
        
        [_bleManager setDebugMode:YES];
        //[_bleManager turnOffAllLights];
        [_bleManager disconnect];
    }
    else if(debugToggle.on == NO){
        debugMode = NO;
        [_prefs setValue: @NO forKey:@"debugMode" ];
        [_bleManager beginBLEScan];
    }
    NSLog(@"ToggleChange to %d",debugToggle.on);

}
*/

- (IBAction)whiteFlashSliderDidChange:(id)sender {
    self.whiteFlashLabel.text = [NSString stringWithFormat: @"%d", (int)self.whiteFlashSlider.value];
    whiteFlashStart = CACurrentMediaTime();
    if(whiteFlashStart-whiteFlashEnd>=.05){
        //[[_bleManager whiteFlashLight] changeIntensity:whiteFlashSlider.value];
        whiteFlashEnd = whiteFlashStart;
        //NSLog(@"%f",whiteFlashEnd);
    }
}


- (IBAction)redFocusSliderDidChange:(id)sender {
    self.redFocusLabel.text = [NSString stringWithFormat: @"%d", (int)self.redFocusSlider.value];
    redFocusStart = CACurrentMediaTime();
    if(redFocusStart-redFocusEnd>=.05){
        //[[_bleManager redFocusLight] changeIntensity:redFocusSlider.value];
        redFocusEnd = redFocusStart;
        //NSLog(@"%f",redFocusEnd);
    }
}

- (IBAction)whiteFocusSliderDidChange:(id)sender {
    self.whiteFocusLabel.text = [NSString stringWithFormat: @"%d", (int)self.whiteFocusSlider.value];
    whiteFocusStart = CACurrentMediaTime();
    if(whiteFocusStart-whiteFocusEnd>=.05){
        //[[_bleManager whiteFocusLight] changeIntensity:whiteFocusSlider.value];
        whiteFocusEnd = whiteFocusStart;
        //NSLog(@"%f",whiteFocusEnd);
    }
    
}

- (IBAction)redFlashSliderDidChange:(id)sender {
    self.redFlashLabel.text = [NSString stringWithFormat: @"%d", (int)self.redFlashSlider.value];
    redFlashStart = CACurrentMediaTime();
    if(redFlashStart-redFlashEnd>=.05){
        //[[_bleManager redFlashLight] changeIntensity:redFlashSlider.value];
        redFlashEnd = redFlashStart;
        //NSLog(@"%f",redFlashEnd);
    }
}


@end
