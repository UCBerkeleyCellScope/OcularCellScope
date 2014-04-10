//
//  SettingsViewController.m
//  OcularCellscope
//
//  Created by PJ Loury on 3/21/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()
@property(nonatomic, strong) NSUserDefaults *prefs;

@end

@implementation SettingsViewController
@synthesize prefs = _prefs;

@synthesize flashLightSlider, redLightSlider, flashLightValue, redLightValue, flashLightLabel, redLightLabel, multiText, debugToggle,bleDelay,captureDelay,flashDuration,multiShot, timedFlashSwitch;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped)];
    [self.tableView addGestureRecognizer:gestureRecognizer];
    
}

-(void) viewWillAppear:(BOOL)animated{
    
    _prefs = [NSUserDefaults standardUserDefaults];
    
    [ debugToggle setOn: [_prefs boolForKey: @"debugMode"] animated: NO];
    
    [ timedFlashSwitch setOn: [_prefs boolForKey: @"timedFlash"] animated: NO];
    
    flashLightValue =  [_prefs integerForKey: @"flashLightValue"];
    redLightValue =  [_prefs integerForKey: @"redLightValue"];
    
    flashLightSlider.value = flashLightValue;
    redLightSlider.value = redLightValue;
    
    flashLightLabel.text = [NSString stringWithFormat: @"%d", (int)flashLightValue];
    redLightLabel.text = [NSString stringWithFormat: @"%d", (int)redLightValue];
    
    NSString *bleText =  [ NSString stringWithFormat:@"%f",[_prefs floatForKey: @"bleDelay"]];
    bleText = [bleText substringToIndex:4];
    [bleDelay setText: bleText];

    NSString *captureText =  [ NSString stringWithFormat:@"%f",[_prefs floatForKey: @"captureDelay"]];
    captureText = [captureText substringToIndex:4];
    [captureDelay setText: captureText];
    
    NSString *flashText =  [ NSString stringWithFormat:@"%f",[_prefs floatForKey: @"flashDuration"]];
    flashText = [flashText substringToIndex:4];
    [flashDuration setText: flashText];
    
    self.multiText =  [ NSString stringWithFormat:@"%ld",[_prefs integerForKey: @"numberOfImages"]];
    [self selectUISegment: self.multiText];

    
    
}

-(void) viewDidAppear:(BOOL)animated{
        }

-(void) viewWillDisappear:(BOOL)animated{
    
    
    [_prefs setInteger: flashLightSlider.value forKey:@"flashLightValue"];
    [_prefs setInteger: redLightSlider.value forKey:@"redLightValue"];
    
    NSNumberFormatter * f1 = [[NSNumberFormatter alloc] init];
    [f1 setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *prefNum1 = [f1 numberFromString:bleDelay.text];
    [_prefs setObject: prefNum1 forKey:@"bleDelay"];

    NSNumberFormatter * f2 = [[NSNumberFormatter alloc] init];
    [f2 setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *prefNum2 = [f2 numberFromString:captureDelay.text];
    [_prefs setObject: prefNum2 forKey:@"captureDelay"];

    NSNumberFormatter * f3 = [[NSNumberFormatter alloc] init];
    [f3 setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *prefNum3 = [f3 numberFromString:flashDuration.text];
    [_prefs setObject: prefNum3 forKey:@"flashDuration"];

    NSNumberFormatter * f4 = [[NSNumberFormatter alloc] init];
    [f4 setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *prefNum4 = [f4 numberFromString:self.multiText];
    [_prefs setObject: prefNum4 forKey:@"numberOfImages"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backgroundTapped {
    NSLog(@"Background Tapped");
    [[self tableView] endEditing:YES];
}

- (IBAction)toggleDidChange:(id)sender {

    if(debugToggle.on == YES){
        [_prefs setValue: @YES forKey:@"debugMode" ];

    }
    else if(debugToggle.on == NO){
        [_prefs setValue: @NO forKey:@"debugMode" ];
    }
    
    NSLog(@"ToggleChange to %d",debugToggle.on);
    
}

- (IBAction)didPressDone:(id)sender {

    [self.navigationController popToRootViewControllerAnimated:YES];

}

- (IBAction)flashSliderDidChange:(id)sender {
    flashLightLabel.text = [NSString stringWithFormat: @"%d", (int)flashLightSlider.value];
}

- (IBAction)redSliderDidChange:(id)sender {
       redLightLabel.text = [NSString stringWithFormat: @"%d", (int)redLightSlider.value];
}

- (IBAction)multiShotValueChanged:(id)sender {
    self.multiText = [multiShot titleForSegmentAtIndex:multiShot.selectedSegmentIndex];
    
}

- (IBAction)timedFlashToggleDidChange:(id)sender {
    if(timedFlashSwitch.on == YES){
        [_prefs setValue: @YES forKey:@"timedFlash" ];
        
    }
    else if(timedFlashSwitch.on == NO){
        [_prefs setValue: @NO forKey:@"timedFlash" ];
    }
    
    NSLog(@"ToggleChange to %d",timedFlashSwitch.on);
}

- (void)selectUISegment:(NSString *)segmentString{
        
    for (int i=0; i< multiShot.numberOfSegments; i++){
        
        if( [self.multiText isEqualToString:[multiShot titleForSegmentAtIndex:i]] ){
            [multiShot setSelectedSegmentIndex:i];
            break;
        }
    }
}


@end
