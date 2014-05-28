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

@property(nonatomic, strong) NSUserDefaults *prefs;
@property(nonatomic, strong)UIAlertView *flashTooLong;
@property(nonatomic, strong)UIAlertView *bleDelayTooLong;

@end

@implementation SettingsViewController
@synthesize prefs = _prefs;

@synthesize debugToggle;
@synthesize mirrorToggle;

@synthesize whiteFlashSlider;
@synthesize whiteFlashValue;
@synthesize redFlashSlider;
@synthesize redFlashValue;

@synthesize redFocusSlider;
@synthesize redFocusValue;
@synthesize whiteFocusSlider;
@synthesize whiteFocusValue;

@synthesize redFlashLabel, whiteFlashLabel, redFocusLabel, whiteFocusLabel;

@synthesize multiText,bleDelay,captureDelay,flashDuration,multiShot, timedFlashSwitch, arduinoDelay;

@synthesize remoteLightSlider, remoteLightLabel;
@synthesize flashTooLong, bleDelayTooLong;
@synthesize bleManager = _bleManager;

BOOL debugMode;
BOOL mirroredView;

double whiteFlashStart,whiteFlashEnd,redFocusStart,redFocusEnd, remoteLightStart, remoteLightEnd;
double redFlashStart,redFlashEnd,whiteFocusStart,whiteFocusEnd;

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
    
    [[_bleManager whiteFlashLight]toggleLight];
    
    debugMode = [_prefs boolForKey: @"debugMode"];
    [ debugToggle setOn: debugMode animated: NO];
    
    mirroredView = [_prefs boolForKey: @"mirroredView"]; //gonna be yes
    [ mirrorToggle setOn: mirroredView animated: NO];
    
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
    
    whiteFlashValue =  [_prefs integerForKey: @"whiteFlashValue"];
    redFocusValue =  [_prefs integerForKey: @"redFocusValue"];

    whiteFocusValue =  [_prefs integerForKey: @"whiteFocusValue"];
    redFlashValue =  [_prefs integerForKey: @"redFlashValue"];
    
    
    whiteFlashSlider.value = whiteFlashValue;
    redFocusSlider.value = redFocusValue;
    
    whiteFocusSlider.value = whiteFocusValue;
    redFlashSlider.value = redFlashValue;
    
    whiteFlashLabel.text = [NSString stringWithFormat: @"%d", (int)whiteFlashValue];
    redFocusLabel.text = [NSString stringWithFormat: @"%d", (int)redFocusValue];
    
    redFlashLabel.text = [NSString stringWithFormat: @"%d", (int)redFlashValue];
    whiteFocusLabel.text = [NSString stringWithFormat: @"%d", (int)whiteFocusValue];

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

    NSString *arduinoDelayText =  [ NSString stringWithFormat:@"%f",[_prefs floatForKey: @"arduinoDelay"]];
    arduinoDelayText = [arduinoDelayText substringToIndex:3];
    [arduinoDelay setText: arduinoDelayText];

    
}

-(void) viewWillDisappear:(BOOL)animated{
    
    if(debugMode == NO){
        [_bleManager.whiteFlashLight turnOff];
        [_bleManager.redFlashLight turnOff];
    }
       
    [_prefs setInteger: whiteFlashSlider.value forKey:@"whiteFlashValue"];
    [_prefs setInteger: redFocusSlider.value forKey:@"redFocusValue"];

    [_prefs setInteger: redFlashSlider.value forKey:@"redFlashValue"];
    [_prefs setInteger: whiteFocusSlider.value forKey:@"whiteFocusValue"];
    
    [_prefs setInteger: remoteLightSlider.value forKey:@"fixationLightValue"];
    
    
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
    
    NSNumberFormatter * f5 = [[NSNumberFormatter alloc] init];
    [f5 setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *prefNum5 = [f5 numberFromString:arduinoDelay.text];
    [_prefs setObject: prefNum5 forKey:@"arduinoDelay"];
    
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

/**
 *  <#Description#>
 *
 *  @param sender <#sender description#>
 */
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


- (IBAction)whiteFlashSliderDidChange:(id)sender {
    whiteFlashLabel.text = [NSString stringWithFormat: @"%d", (int)whiteFlashSlider.value];
    whiteFlashStart = CACurrentMediaTime();
    if(whiteFlashStart-whiteFlashEnd>=.05){
        [[_bleManager whiteFlashLight] changeIntensity:whiteFlashSlider.value];
        whiteFlashEnd = whiteFlashStart;
        //NSLog(@"%f",whiteFlashEnd);
    }
}


- (IBAction)redFocusSliderDidChange:(id)sender {
    redFocusLabel.text = [NSString stringWithFormat: @"%d", (int)redFocusSlider.value];
    redFocusStart = CACurrentMediaTime();
    if(redFocusStart-redFocusEnd>=.05){
        [[_bleManager redFocusLight] changeIntensity:redFocusSlider.value];
        redFocusEnd = redFocusStart;
        //NSLog(@"%f",redFocusEnd);
    }
}

- (IBAction)whiteFocusSliderDidChange:(id)sender {
    whiteFocusLabel.text = [NSString stringWithFormat: @"%d", (int)whiteFocusSlider.value];
    whiteFocusStart = CACurrentMediaTime();
    if(whiteFocusStart-whiteFocusEnd>=.05){
        [[_bleManager whiteFocusLight] changeIntensity:whiteFocusSlider.value];
        whiteFocusEnd = whiteFocusStart;
        //NSLog(@"%f",whiteFocusEnd);
    }
    
}

- (IBAction)redFlashSliderDidChange:(id)sender {
    redFlashLabel.text = [NSString stringWithFormat: @"%d", (int)redFlashSlider.value];
    redFlashStart = CACurrentMediaTime();
    if(redFlashStart-redFlashEnd>=.05){
        [[_bleManager redFlashLight] changeIntensity:redFlashSlider.value];
        redFlashEnd = redFlashStart;
        //NSLog(@"%f",redFlashEnd);
    }
}

- (IBAction)remoteLightSliderDidChange:(id)sender {
    remoteLightLabel.text = [NSString stringWithFormat: @"%d", (int)remoteLightSlider.value];
    remoteLightStart = CACurrentMediaTime();
    if(remoteLightStart-remoteLightEnd>=.05){
        [[[_bleManager fixationLights]objectAtIndex:[_bleManager selectedLight]]changeIntensity:remoteLightSlider.value];
        
        //[[_bleManager remoteLight] changeIntensity:remoteLightSlider.value];
        remoteLightEnd = remoteLightStart;
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

- (IBAction)mirrorToggleDidChange:(id)sender {
    
    if(mirrorToggle.on == YES){
        [_prefs setValue: @YES forKey:@"mirroredView" ];
    }
    else if(mirrorToggle.on == NO){
        [_prefs setValue: @NO forKey:@"mirroredView" ];
    }
    
    
    NSLog(@"MirrorToggle changed to %d",mirrorToggle.on);
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
