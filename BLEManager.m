//
//  IlluminationSystem.m
//  OcularCellscope
//
//  Created by Chris Echanique on 4/17/14.
//  Copyright (c) 2014 UC Berkeley Ocular CellScope. All rights reserved.
//

#import "BLEManager.h"


@implementation BLEManager

/*
@synthesize redFocusLight = _redFocusLight;
@synthesize whiteFlashLight = _whiteFlashLight;

@synthesize whiteFocusLight = _whiteFocusLight;
@synthesize redFlashLight = _redFlashLight;
@synthesize remoteLight = _remoteLight;
@synthesize fixationLights = _fixationLights;
 */
@synthesize ble;
@synthesize prefs = _prefs;
@synthesize debugMode;
@synthesize isConnected = _isConnected;
//@synthesize selectedLight = _selectedLight;


//@synthesize whitePing = _whitePing;

//has a FocusingLight
//has a FlashLight
//which on the FocusingLight
//if is not zero then send

int attempts = 0;
BOOL capturing = NO;

-(id)init{
    self = [super init];
    if(self){
        ble = [[BLE alloc] init];
        [ble controlSetup];
        ble.delegate = self;
                
        NSLog(@"MADE THE BLEM");
        
        _prefs = [NSUserDefaults standardUserDefaults];
/*
        int r_i = (int)[_prefs integerForKey:@"redFocusValue"];
        int w_i = (int)[_prefs integerForKey:@"whiteFlashValue"];
        
        int redFlash_i = (int)[_prefs integerForKey:@"redFlashValue"];
        int whiteFocus_i = (int)[_prefs integerForKey:@"whiteFocusValue"];
        
        int fixationLightValue = (int)[_prefs integerForKey:@"fixationLightValue"];
        */
        /*
        if (r_i<3){
            [_prefs setInteger: 5 forKey:@"redLightValue"];
            r_i = 5;
        }
        */
         /*
        _redFocusLight = [[Light alloc] initWithBLE:self pin:RED_LIGHT intensity: r_i ];
        _whiteFlashLight = [[Light alloc] initWithBLE:self pin:WHITE_LIGHT intensity: w_i ];
        
        _whiteFocusLight = [[Light alloc] initWithBLE:self pin:WHITE_LIGHT intensity: whiteFocus_i ];
        _redFlashLight = [[Light alloc] initWithBLE:self pin:RED_LIGHT intensity: redFlash_i ];
        
        //_whitePing = [[Light alloc] initWithBLE:self pin:WHITE_PING intensity: w_i];
        
        _remoteLight = [[Light alloc] initWithBLE:self pin:REMOTE_LIGHT intensity: 255];
        
*/
        
        /*
        NSMutableArray *lights = [[NSMutableArray alloc] init];
        for(int i = 0; i <= 5; ++i){
            [lights addObject:[[Light alloc] initWithBLE:self pin: i intensity: fixationLightValue]];
        }
        _fixationLights = lights;
         */
        
        self.batteryQueryTimer = [NSTimer scheduledTimerWithTimeInterval:(float)1.0 target:self selector:@selector(checkBattery) userInfo:nil repeats:YES];
    }
    return self;
}

//send battery voltage request
- (void)checkBattery
{
    if (ble.activePeripheral)
        if(ble.activePeripheral.state == CBPeripheralStateConnected) {
            UInt8 buf[] = {0xFC, 0x00, 0x00};
            [ble write:[NSData dataWithBytes:buf length:3]];
        }
}

- (void)beginBLEScan
{
    if (ble.activePeripheral)
        if(ble.activePeripheral.state == CBPeripheralStateConnected){
            [[ble CM] cancelPeripheralConnection:[ble activePeripheral]];
        }
    
    if (ble.peripherals)
        ble.peripherals = nil;
    
    [ble findBLEPeripherals:2];  //WHY IS THIS 2?
    
    [NSTimer scheduledTimerWithTimeInterval:(float)2.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
    
}

- (void) connectionTimer:(NSTimer *)timer
{
    if (ble.peripherals.count > 0)
    {
        for (CBPeripheral* p in ble.peripherals)
        {
            NSLog(@"%@",p.identifier.UUIDString);
            if ([p.identifier.UUIDString isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:@"CellScopeBTUUID"]])
            {
                [ble connectPeripheral:p];
                return;
            }
        }
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Bluetooth Connection", nil)
                                                         message:NSLocalizedString(@"A new CellScope has been detected. Pair this iPhone with this CellScope?",nil)
                                                        delegate:self
                                               cancelButtonTitle:NSLocalizedString(@"No",nil)
                                               otherButtonTitles:NSLocalizedString(@"Yes",nil),nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        alert.tag = 1;
        [alert show];
    }
    
    else //if(attempts < 3 && capturing == NO)
    {
        //NSLog(@"No peripherals found, initiaiting attempt number %d", attempts);
        [self beginBLEScan];
        //attempts++;
    }

    /*
    else
    {
        UIAlertView *disableAlertView = [[UIAlertView alloc] initWithTitle:@"Bluetooth could not connect."
                                                            message: @"Check that the Ocular CellScope is fully charged and switched on."
                                                           delegate:self
                                                  cancelButtonTitle:@"Try Again"
                                                  otherButtonTitles:@"Disable BLE",nil];
        [disableAlertView show];
        [disableAlertView setTag:2];
        
        
        
    }
    */
    
    
    
    /*
    if (ble.peripherals.count > 0)
    {
        [ble connectPeripheral:[ble.peripherals objectAtIndex:0]];
        NSLog(@"At least attempting connection");
        
    }
    else if(attempts < 2 && capturing == NO)
    {
        NSLog(@"No peripherals found, initiaiting attempt number %d", attempts);
        [self btnScanForPeripherals];
        attempts++;
    }
    else{
        NSLog(@"Why didn't we exit??");
        
        
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Bluetooth could not connect."
                                                            message: @"Check that the Ocular CellScope is fully charged and switched on."
                                                           delegate:self
                                                  cancelButtonTitle:@"Try Again"
                                                  otherButtonTitles:@"Disable BLE",nil];
        [alertView show];
        
    }
    */
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==1) //this is the title prompt for new photo/video
    {
        if (buttonIndex==1) {
            [self pairBLECellScope];
        }
    }
    
    if (alertView.tag==2){
        if (buttonIndex == 0){
            NSLog(@"user pressed Try Again");
            attempts = 0;
            [self beginBLEScan];
        }
        else { //TODO: might not be necessary
            _prefs = [NSUserDefaults standardUserDefaults];
            [_prefs setValue: @YES forKey:@"debugMode" ];
            //[_BLECdelegate didReceiveNoBLEConfirmation];
        }
    }
}

/*
 - (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
 if (buttonIndex == 0){
 NSLog(@"user pressed Try Again");
 attempts = 0;
 [self btnScanForPeripherals];
 }
 else {
 _prefs = [NSUserDefaults standardUserDefaults];
 [_prefs setValue: @YES forKey:@"debugMode" ];
 [_BLECdelegate didReceiveNoBLEConfirmation];
 }
 }
 */


-(void) pairBLECellScope
{
    if (ble.peripherals.count > 0)
    {
        NSString* newUUID = ((CBPeripheral*)ble.peripherals[0]).identifier.UUIDString;
        
        [[NSUserDefaults standardUserDefaults] setObject:newUUID forKey:@"CellScopeBTUUID"];
        
        [ble connectPeripheral:[ble.peripherals objectAtIndex:0]];
        
        NSString* logstr = [NSString stringWithFormat:@"Bluetooth now paired with %@",newUUID];
        CSLog(logstr, @"HARDWARE");
        
    }
    
}



 
 
-(void) disconnect{
    if (ble.activePeripheral)
        if(ble.activePeripheral.state == CBPeripheralStateConnected){
            [[ble CM] cancelPeripheralConnection:[ble activePeripheral]];
        }
}



- (void)bleDidDisconnect
{
    CSLog(@"Bluetooth disconnected.", @"HARDWARE");
    [self beginBLEScan];
    //[self btnScanForPeripherals];
    _isConnected = NO;
    debugMode = [_prefs boolForKey:@"debugMode" ];
    if(debugMode==NO){

    }
    
    
    
}

-(void) bleDidConnect
{
    CSLog(@"Bluetooth connected.", @"HARDWARE");
    //[self turnOffAllLights];
    
    _isConnected = YES;
    [self.BLECdelegate didReceiveConnectionConfirmation];
    
    [self setIlluminationWhite:0 Red:0];
    [self setFixationLight:FIXATION_LIGHT_NONE forEye:1 withIntensity:0];
    
    
    /*
    if([[CellScopeContext sharedContext]camViewLoaded]==YES){
        [self.redFocusLight turnOn];
        [self.whiteFocusLight turnOn];
        
        [[self.fixationLights objectAtIndex: _selectedLight] turnOn];

    }
     */
    
}


-(void) bleDidReceiveData:(unsigned char *)data length:(int)length
{
    //NSLog(@"Length: %d", length);
    // parse data, all commands are in 3-byte
    for (int i = 0; i < length; i+=3) //incrementing by 3
    {
        NSLog(@"RECEIVED: 0x%02X, 0x%02X, 0x%02X", data[i], data[i+1], data[i+2]);
        
         //display attached/detached message
         if(data[0]==0xFD){
             NSDictionary* state;
             switch (data[2]) {
                 case 0:
                     //display removed
                     state = @{@"displayState":@"NONE"};
                     break;
                 case 1:
                     //display inserted for OD (right eye imaging, display on left eye)
                     state = @{@"displayState":@"OD"};
                     break;
                 case 2:
                     //display inserted for OS (imaging left eye, display on right)
                     state = @{@"displayState":@"OS"};
                     break;
                 default:
                     break;
             }
             [[NSNotificationCenter defaultCenter] postNotificationName:@"FixationDisplayChangeNotification" object:self userInfo:state];
         }
         else if (data[0]==0xFC) {
             unsigned int digitalVoltage = ((((UInt16)data[i+1])<<8) | data[i+2]);
             float analogVoltage = digitalVoltage*5.0/1024;
             NSLog(@"voltage = %f",analogVoltage);
             NSDictionary* state = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:analogVoltage] forKey:@"voltage"];
             [[NSNotificationCenter defaultCenter] postNotificationName:@"CellScopeVoltageNotification" object:self userInfo:state];
         }
        
        
    }
    

    
}



//FBM
-(void)setIlluminationWhite:(UInt8)whiteIntensity Red:(UInt8)redIntensity {
    UInt8 buf[] = {0x01, whiteIntensity, redIntensity};
    [ble write:[NSData dataWithBytes:buf length:3]];
    //[NSThread sleepForTimeInterval:0.1];
}

-(void)setIlluminationWithCallbackWhite:(UInt8)whiteIntensity Red:(UInt8)redIntensity {
    UInt8 buf[] = {0x02, whiteIntensity, redIntensity};
    [ble write:[NSData dataWithBytes:buf length:3]];
    //[NSThread sleepForTimeInterval:0.1];
}

-(void)setFlashIntensityWhite:(UInt8)whiteIntensity Red:(UInt8)redIntensity {
    UInt8 buf[] = {0x03, whiteIntensity, redIntensity};
    [ble write:[NSData dataWithBytes:buf length:3]];
    //[NSThread sleepForTimeInterval:0.1];
}

-(void)setFlashTimingDelay:(UInt16)flashDelay Duration:(UInt16)flashDuration {

    UInt8 upperByte; UInt8 lowerByte;
    
    upperByte = ((flashDelay & 0xFF00) >> 8);
    lowerByte = (flashDelay & 0x00FF);
    UInt8 buf1[] = {0x07, upperByte, lowerByte};
    [ble write:[NSData dataWithBytes:buf1 length:3]];
    
    upperByte = ((flashDuration & 0xFF00) >> 8);
    lowerByte = (flashDuration & 0x00FF);
    UInt8 buf2[] = {0x08, upperByte, lowerByte};
    [ble write:[NSData dataWithBytes:buf2 length:3]];
    //[NSThread sleepForTimeInterval:0.1];
}

-(void)doFlash {
    UInt8 buf[] = {0x04, 0x00, 0x00};
    [ble write:[NSData dataWithBytes:buf length:3]];
    //[NSThread sleepForTimeInterval:0.1];
}
//1: center, 2: top, 3:
-(void)setFixationLight:(int)fixationLight forEye:(int)eye withIntensity:(int)intensity {
    int lightCommand;
    if (eye==OD_EYE) {
        switch (fixationLight) {
            case 1: //center
                lightCommand = 1;
                break;
            case 2:
                lightCommand = 3;
                break;
            case 3:
                lightCommand = 2;
                break;
            case 4:
                lightCommand = 4;
                break;
            case 5:
                lightCommand = 5;
                break;
            default:
                lightCommand = 0;
                break;
        }
    }
    else {
        switch (fixationLight) {
            case 1:
                lightCommand = 1;
                break;
            case 2:
                lightCommand = 2;
                break;
            case 3:
                lightCommand = 3;
                break;
            case 4:
                lightCommand = 5;
                break;
            case 5:
                lightCommand = 4;
                break;
            default:
                lightCommand = 0;
                break;
        }
    }
    
    UInt8 buf[] = {0x05, lightCommand, intensity};
    [ble write:[NSData dataWithBytes:buf length:3]];

    
}

-(void)setDisplayCoordinatesToX:(int)x Y:(int)y {
    UInt8 buf[] = {0x06, x, y};
    [ble write:[NSData dataWithBytes:buf length:3]];
    //[NSThread sleepForTimeInterval:0.1];
}

-(void)doSelfTest {
    UInt8 buf[] = {0xFF, 0x00, 0x00};
    [ble write:[NSData dataWithBytes:buf length:3]];
    //[NSThread sleepForTimeInterval:0.1];
}

@end
