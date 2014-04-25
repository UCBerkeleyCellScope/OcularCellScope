//
//  SettingsViewController.m
//  OcularCellscope
//
//  Created by PJ Loury on 3/21/14.
//  Copyright (c) 2014 UC Berkeley Ocular CellScope. All rights reserved.
//

#import "SettingsViewController.h"
#import "CameraAppDelegate.h"

@interface SettingsViewController ()

@property(nonatomic, strong) NSUserDefaults *prefs;
@property(nonatomic, strong)UIAlertView *flashTooLong;
@property(nonatomic, strong)UIAlertView *bleDelayTooLong;

@end

@implementation SettingsViewController
@synthesize prefs = _prefs;

@synthesize flashLightSlider, redLightSlider, flashLightValue, redLightValue, flashLightLabel, redLightLabel, multiText, debugToggle,bleDelay,captureDelay,flashDuration,multiShot, timedFlashSwitch;
@synthesize remoteLightSlider, remoteLightLabel;
@synthesize flashTooLong, bleDelayTooLong;
@synthesize bleManager = _bleManager;

BOOL debugMode;

double fs,fe,rs,re, rems, reme;

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
    
    _bleManager = [[CellScopeContext sharedContext]bleManager];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped)];
    [self.tableView addGestureRecognizer:gestureRecognizer];
    
}

-(void) viewWillAppear:(BOOL)animated{
    
    _prefs = [NSUserDefaults standardUserDefaults];
    
    [[_bleManager whiteLight]toggleLight];
    
    debugMode = [_prefs boolForKey: @"debugMode"] ;
    
    [ debugToggle setOn: debugMode animated: NO];
    
    BOOL timedFlash = [_prefs boolForKey: @"timedFlash"];
    [ timedFlashSwitch setOn: timedFlash animated: NO];
    
    if(debugMode == YES){
        //[timedFlashSwitch setEnabled:NO];
    }
    
    if(timedFlash == NO){
        [flashDuration setEnabled: NO];
    }
    else{
        [flashDuration setEnabled:YES];
    }
    
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

-(void) viewWillDisappear:(BOOL)animated{
    
    if(debugMode == NO)
        [_bleManager.whiteLight turnOff];
       
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
    
    if(captureDelay.text.doubleValue<flashDuration.text.doubleValue){
        flashTooLong = [[UIAlertView alloc] initWithTitle:@"Flash Duration must be shorter than Capture Delay"
                                                            message:nil                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [flashTooLong show];
    }
    
    if(captureDelay.text.doubleValue<bleDelay.text.doubleValue){
        bleDelayTooLong = [[UIAlertView alloc] initWithTitle:@"BLE Delay must be shorter than Capture Delay"
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [bleDelayTooLong show];
    }
    
    
    [[self tableView] endEditing:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    
    if (alertView == bleDelayTooLong && buttonIndex == 0){
        [bleDelay becomeFirstResponder];
    }
    if (alertView == flashTooLong && buttonIndex == 0){
        [flashDuration becomeFirstResponder];
    }
}

- (IBAction)toggleDidChange:(id)sender {

    if(debugToggle.on == YES){
        debugMode = YES;
        [_prefs setValue: @YES forKey:@"debugMode" ];
        
        [_bleManager setDebugMode:YES];
        [_bleManager turnOffAllLights];
        [_bleManager disconnect];
    }
    else if(debugToggle.on == NO){
        debugMode = NO;
        [_prefs setValue: @NO forKey:@"debugMode" ];
        [_bleManager btnScanForPeripherals];
    }
    NSLog(@"ToggleChange to %d",debugToggle.on);
}


- (IBAction)flashSliderDidChange:(id)sender {
    flashLightLabel.text = [NSString stringWithFormat: @"%d", (int)flashLightSlider.value];
    fs = CACurrentMediaTime();
    if(fs-fe>=.05){
        [[_bleManager whiteLight] changeIntensity:flashLightSlider.value];
        fe = fs;
        //NSLog(@"%f",fe);
    }
}


- (IBAction)redSliderDidChange:(id)sender {
    redLightLabel.text = [NSString stringWithFormat: @"%d", (int)redLightSlider.value];
    rs = CACurrentMediaTime();
    if(rs-re>=.05){
        [[_bleManager redLight] changeIntensity:redLightSlider.value];
        re = rs;
        //NSLog(@"%f",re);
    }
}

- (IBAction)remoteLightSliderDidChange:(id)sender {
    remoteLightLabel.text = [NSString stringWithFormat: @"%d", (int)remoteLightSlider.value];
    rems = CACurrentMediaTime();
    if(rems-reme>=.05){
        [[_bleManager remoteLight] changeIntensity:remoteLightSlider.value];
        reme = rems;
    }
}


- (IBAction)multiShotValueChanged:(id)sender {
    self.multiText = [multiShot titleForSegmentAtIndex:multiShot.selectedSegmentIndex];
    
}

- (IBAction)timedFlashToggleDidChange:(id)sender {
    if(timedFlashSwitch.on == YES){
        [_prefs setValue: @YES forKey:@"timedFlash" ];
        [flashDuration setEnabled:YES];
    }
    else if(timedFlashSwitch.on == NO){
        [_prefs setValue: @NO forKey:@"timedFlash" ];
        [flashDuration setEnabled:NO];
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
