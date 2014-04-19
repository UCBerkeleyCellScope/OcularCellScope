//
//  SettingsViewController.m
//  OcularCellscope
//
//  Created by PJ Loury on 3/21/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import "SettingsViewController.h"
#import "CameraAppDelegate.h"

#include <assert.h>
//#include <CoreServices/CoreServices.h>
#include <mach/mach.h>
#include <mach/mach_time.h>
#include <unistd.h>


@interface SettingsViewController ()
@property(nonatomic, strong) NSUserDefaults *prefs;

@end

@implementation SettingsViewController
@synthesize prefs = _prefs;

@synthesize flashLightSlider, redLightSlider, flashLightValue, redLightValue, flashLightLabel, redLightLabel, multiText, debugToggle,bleDelay,captureDelay,flashDuration,multiShot, timedFlashSwitch;

BOOL debugMode;
int flash2=0;
int red2=0;

uint64_t        start;
uint64_t        end;
uint64_t        elapsed;

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
    /*UINavigationBar *naviBarObj = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 65)];
    [self.view addSubview:naviBarObj];
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(didPressDone:)];
    UINavigationItem *navigItem = [[UINavigationItem alloc] initWithTitle:@"Settings"];
    navigItem.rightBarButtonItem = doneItem;
    naviBarObj.items = [NSArray arrayWithObjects: navigItem,nil];
    */
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped)];
    [self.tableView addGestureRecognizer:gestureRecognizer];
    
}

-(void) viewWillAppear:(BOOL)animated{
    
    _prefs = [NSUserDefaults standardUserDefaults];
    
    debugMode = [_prefs boolForKey: @"debugMode"] ;
    
    [ debugToggle setOn: debugMode animated: NO];
    
    BOOL timedFlash = [_prefs boolForKey: @"timedFlash"];
    [ timedFlashSwitch setOn: timedFlash animated: NO];
    
    if(debugMode == YES){
        [timedFlashSwitch setEnabled:NO];
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
    
    if(debugMode == NO){
    [[[CellScopeContext sharedContext]cvc]toggleAuxilaryLight:flashNumber toggleON:NO
                                                    ];
    }
       
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
        debugMode = YES;
        [_prefs setValue: @YES forKey:@"debugMode" ];
        [[[CellScopeContext sharedContext]cvc]toggleAuxilaryLight:0x0B toggleON:NO
                                                        ]; //0x0B means with no pingback
        [[[CellScopeContext sharedContext]cvc]toggleAuxilaryLight:farRedLight toggleON:NO
                                                        ];
        [[[CellScopeContext sharedContext]cvc]toggleAuxilaryLight: [[CellScopeContext sharedContext]cvc].selectedLight toggleON:NO
         ];
        
        BLE* ble = [[CellScopeContext sharedContext]ble];
        
        if (ble.activePeripheral)
            if(ble.activePeripheral.state == CBPeripheralStateConnected){
                [[ble CM] cancelPeripheralConnection:[ble activePeripheral]];
            }
    }
    else if(debugToggle.on == NO){
        debugMode = NO;
        [_prefs setValue: @NO forKey:@"debugMode" ];
        [timedFlashSwitch setEnabled:YES];
        
        CameraAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        [appDelegate btnScanForPeripherals];
    }
    
    NSLog(@"ToggleChange to %d",debugToggle.on);
    
}


- (IBAction)flashSliderDidChange:(id)sender {
    flashLightLabel.text = [NSString stringWithFormat: @"%d", (int)flashLightSlider.value];
    
    //int power = (255-self.flashLightSlider.value);
    
    //int hi = CACurrentMediaTime();
    
    [[[CellScopeContext sharedContext]cvc]toggleAuxilaryLight:flashNoPingBack toggleON:YES
                                                        analogVal:self.flashLightSlider.value];
 
    //self.flashLightSlider.value
}

- (IBAction)redSliderDidChange:(id)sender {
       redLightLabel.text = [NSString stringWithFormat: @"%d", (int)redLightSlider.value];
    
    //int power = (255-self.redLightSlider.value);
    
    start = mach_absolute_time();

    
    if(start-end>=1000){
    
    [[[CellScopeContext sharedContext]cvc]toggleAuxilaryLight:farRedLight toggleON:YES
                                                    analogVal:self.redLightSlider.value];
       end = start;
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
