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

@property(nonatomic) CGFloat initialTVHeight;
@property(nonatomic, strong) NSUserDefaults *prefs;
@property(nonatomic, strong)UIAlertView *flashTooLong;
@property(nonatomic, strong)UIAlertView *bleDelayTooLong;

@end

@implementation SettingsViewController
@synthesize prefs = _prefs;

@synthesize initialTVHeight;

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

@synthesize flashDelay,captureDelay,multiShot, flashDuration;

//flashDuration, //timedFlashSwitch,

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
    /*
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped)];
    [self.tableView addGestureRecognizer:gestureRecognizer];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHidden:) name:UIKeyboardDidHideNotification object:nil];

*/
    
}

-(void) viewWillAppear:(BOOL)animated{
    
    _prefs = [NSUserDefaults standardUserDefaults];
    
    //[[_bleManager whiteFlashLight]toggleLight];
    
    debugMode = [_prefs boolForKey: @"debugMode"];
    [ debugToggle setOn: debugMode animated: NO];
    
    mirroredView = [_prefs boolForKey: @"mirroredView"]; //gonna be yes
    [ mirrorToggle setOn: mirroredView animated: NO];
    
    //BOOL timedFlash = [_prefs boolForKey: @"timedFlash"];
    //[ timedFlashSwitch setOn: timedFlash animated: NO];
    
    if(debugMode == YES){
        //[timedFlashSwitch setEnabled:NO];
    }
    
    /*
    if(timedFlash == NO){
        [flashDuration setEnabled: NO];
    }
    else{
        [flashDuration setEnabled:YES];
    }
    */
     
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

    flashDelay.text = [ NSString stringWithFormat:@"%3.2f",[_prefs floatForKey: @"flashDelay"]];

    flashDuration.text =  [ NSString stringWithFormat:@"%ld",[_prefs integerForKey: @"flashDuration"]];
    
    captureDelay.text = [NSString stringWithFormat:@"%3.2f",[_prefs floatForKey:@"captureDelay"]];
    
    
    
}

-(void) viewWillDisappear:(BOOL)animated{
    
    [_prefs setInteger: whiteFlashSlider.value forKey:@"whiteFlashValue"];
    [_prefs setInteger: redFocusSlider.value forKey:@"redFocusValue"];

    [_prefs setInteger: redFlashSlider.value forKey:@"redFlashValue"];
    [_prefs setInteger: whiteFocusSlider.value forKey:@"whiteFocusValue"];
    
    [_prefs setInteger: remoteLightSlider.value forKey:@"fixationLightValue"];
    
    
    [_prefs setFloat: flashDelay.text.floatValue forKey:@"flashDelay"];
       
    [_prefs setInteger: flashDuration.text.intValue forKey:@"flashDuration"];
    
    [_prefs setInteger: captureDelay.text.intValue forKey:@"captureDelay"];
    
}

/*
-(void) keyboardShown:(NSNotification*) notification {
    initialTVHeight = self.tableView.frame.size.height;
    
    CGRect initialFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect convertedFrame = [self.view convertRect:initialFrame fromView:nil];
    CGRect tvFrame = self.tableView.frame;
    tvFrame.size.height = convertedFrame.origin.y;
    self.tableView.frame = tvFrame;
}

-(void) keyboardHidden:(NSNotification*) notification {
    CGRect tvFrame = self.tableView.frame;
    tvFrame.size.height = self.tableView.frame.size.height;
    [UIView beginAnimations:@"TableViewDown" context:NULL];
    [UIView setAnimationDuration:0.3f];
    self.tableView.frame = tvFrame;
    [UIView commitAnimations];
}
*/
/*
-(void) scrollToCell:(NSIndexPath*) path {
    [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionNone animated:YES];
}

-(void) textFieldDidBeginEditing:(UITextField *)textField {
    NSIndexPath* path = [NSIndexPath indexPathForRow:6 inSection:1];
    [self performSelector:@selector(scrollToCell:) withObject:path afterDelay:0.5f];
}
*/
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//- (void)backgroundTapped {
//    NSLog(@"Background Tapped");
    
    /*
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
    */
    
    //[[self tableView] endEditing:YES];
    
    
//}


/*
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    
    if (alertView == bleDelayTooLong && buttonIndex == 0){
        [bleDelay becomeFirstResponder];
    }
    if (alertView == flashTooLong && buttonIndex == 0){
        [flashDuration becomeFirstResponder];
    }
}
*/
 
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


- (IBAction)whiteFlashSliderDidChange:(id)sender {
    whiteFlashLabel.text = [NSString stringWithFormat: @"%d", (int)whiteFlashSlider.value];
    whiteFlashStart = CACurrentMediaTime();
    if(whiteFlashStart-whiteFlashEnd>=.05){
        //[[_bleManager whiteFlashLight] changeIntensity:whiteFlashSlider.value];
        whiteFlashEnd = whiteFlashStart;
        //NSLog(@"%f",whiteFlashEnd);
    }
}


- (IBAction)redFocusSliderDidChange:(id)sender {
    redFocusLabel.text = [NSString stringWithFormat: @"%d", (int)redFocusSlider.value];
    redFocusStart = CACurrentMediaTime();
    if(redFocusStart-redFocusEnd>=.05){
        //[[_bleManager redFocusLight] changeIntensity:redFocusSlider.value];
        redFocusEnd = redFocusStart;
        //NSLog(@"%f",redFocusEnd);
    }
}

- (IBAction)whiteFocusSliderDidChange:(id)sender {
    whiteFocusLabel.text = [NSString stringWithFormat: @"%d", (int)whiteFocusSlider.value];
    whiteFocusStart = CACurrentMediaTime();
    if(whiteFocusStart-whiteFocusEnd>=.05){
        //[[_bleManager whiteFocusLight] changeIntensity:whiteFocusSlider.value];
        whiteFocusEnd = whiteFocusStart;
        //NSLog(@"%f",whiteFocusEnd);
    }
    
}

- (IBAction)redFlashSliderDidChange:(id)sender {
    redFlashLabel.text = [NSString stringWithFormat: @"%d", (int)redFlashSlider.value];
    redFlashStart = CACurrentMediaTime();
    if(redFlashStart-redFlashEnd>=.05){
        //[[_bleManager redFlashLight] changeIntensity:redFlashSlider.value];
        redFlashEnd = redFlashStart;
        //NSLog(@"%f",redFlashEnd);
    }
}

- (IBAction)remoteLightSliderDidChange:(id)sender {
    remoteLightLabel.text = [NSString stringWithFormat: @"%d", (int)remoteLightSlider.value];
    remoteLightStart = CACurrentMediaTime();
    if(remoteLightStart-remoteLightEnd>=.05){
        //[[[_bleManager fixationLights]objectAtIndex:[_bleManager selectedLight]]changeIntensity:remoteLightSlider.value];
        
        //[[_bleManager remoteLight] changeIntensity:remoteLightSlider.value];
        remoteLightEnd = remoteLightStart;
    }
}


- (IBAction)multiShotValueChanged:(id)sender {
    //self.multiText = [multiShot titleForSegmentAtIndex:multiShot.selectedSegmentIndex];
}

/*
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
*/
 
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
        /*
    for (int i=0; i< multiShot.numberOfSegments; i++){
        
        if( [self.multiText isEqualToString:[multiShot titleForSegmentAtIndex:i]] ){
            [multiShot setSelectedSegmentIndex:i];
            break;
        }
    }
         */
}

/*
- (void) textFieldDidBeginEditing:(UITextField *)textField {
    
    UITableViewCell *cell;
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        // Load resources for iOS 6.1 or earlier
        cell = (UITableViewCell *) textField.superview.superview;
        
    } else {
        // Load resources for iOS 7 or later
        cell = (UITableViewCell *) textField.superview.superview.superview;
        // TextField -> UITableVieCellContentView -> (in iOS 7!)ScrollView -> Cell!
    }
    [self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell:cell] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}
 */

@end
