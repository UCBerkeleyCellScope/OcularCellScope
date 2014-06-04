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
@synthesize BLECdelegate = _BLECdelegate;

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
    }
    return self;
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
            NSLog(p.identifier.UUIDString);
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
    
    else if(attempts < 3 && capturing == NO)
    {
        NSLog(@"No peripherals found, initiaiting attempt number %d", attempts);
        [self beginBLEScan];
        attempts++;
    }

    
    else
    {
        UIAlertView *disableAlertView = [[UIAlertView alloc] initWithTitle:@"Bluetooth could not connect."
                                                            message: @"Check that the Ocular CellScope is fully charged and switched on."
                                                           delegate:self
                                                  cancelButtonTitle:@"Try Again"
                                                  otherButtonTitles:@"Disable BLE",nil];
        [disableAlertView show];
        [disableAlertView setTag:2];
        
        
        
        /*
        
        //try connecting again
        if (ble.activePeripheral)
            if(ble.activePeripheral.isConnected)
            {
                [[ble CM] cancelPeripheralConnection:[ble activePeripheral]];
                return;
            }
        
        if (ble.peripherals)
            ble.peripherals = nil;
        
        [ble findBLEPeripherals:2];
        [NSTimer scheduledTimerWithTimeInterval:(float)1.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
        */
    }

    
    
    
    
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
            [_BLECdelegate didReceiveNoBLEConfirmation];
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
        
        NSLog(@"now paired with %@",newUUID);
    }
    
}



 
 
-(void) disconnect{
    if (ble.activePeripheral)
        if(ble.activePeripheral.state == CBPeripheralStateConnected){
            [[ble CM] cancelPeripheralConnection:[ble activePeripheral]];
        }
}

/*
-(void) bleDelay{
    NSNumber *bleDelay = [[NSUserDefaults standardUserDefaults] objectForKey:@"bleDelay"];
    [NSThread sleepForTimeInterval: [bleDelay doubleValue]];
}
*/

- (void)bleDidDisconnect
{
    NSLog(@"->Disconnected");
    //[self btnScanForPeripherals];
    _isConnected = NO;
    debugMode = [_prefs boolForKey:@"debugMode" ];
    if(debugMode==NO){
        [self beginBLEScan];
    }
    NSLog(@"Connected set back to NO");
    
}

-(void) bleDidConnect
{
    NSLog(@"BLE has succesfully connected");
    //[self turnOffAllLights];
    
    _isConnected = YES;
    [_BLECdelegate didReceiveConnectionConfirmation];
    
    [self setIlluminationWhite:0 Red:0];
    [self setFixationLight:FIXATION_LIGHT_NONE Intensity:0];
    
    
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
        
        if (data[i] == 0x0A)
        {

        }
        else if (data[i] == 0x0B)
        {
            UInt16 Value;
            Value = data[i+2] | data[i+1] << 8;
        }
    }
    
    /*
    if(data[0]==0xFF && data[1]==0xFF){
        //id<BLEConnectionDelegate> strongDelegate = self.BLECdelegate;
        [_BLECdelegate didReceiveFlashConfirmation];
    }
     */
    
}

/*
-(void)turnOffAllLights{
    debugMode = [_prefs boolForKey:@"debugMode" ];
    if(debugMode==NO){
        for(Light *l in self.fixationLights){
            l.isOn = NO;
        }
        self.whiteFlashLight.isOn = NO;
        self.redFocusLight.isOn = NO;
        self.remoteLight.isOn = NO;
        self.redFlashLight.isOn = NO;
        self.whiteFocusLight.isOn = NO;
        
        UInt8 buf[] = {0xFF, 0x00, 0x00};
        NSData *data = [[NSData alloc] initWithBytes:buf length:3];
        [ble write:data];
    }
}

-(void)turnOffAllLightsExceptFixation{
    debugMode = [_prefs boolForKey:@"debugMode" ];
    if(debugMode==NO){
        self.whiteFlashLight.isOn = NO;
        self.redFocusLight.isOn = NO;
        self.remoteLight.isOn = NO;
        self.redFlashLight.isOn = NO;
        self.whiteFocusLight.isOn = NO;
        
        UInt8 buf[] = {0xEE, 0x00, 0x00};
        NSData *data = [[NSData alloc] initWithBytes:buf length:3];
        [ble write:data];
        
        
    }
}


-(void)timedFlash{
    if(debugMode == NO){
        [self turnOffAllLights];
        [self.whiteFlashLight turnOn];
        [self.redFlashLight turnOn];
        NSNumber *duration = [[NSUserDefaults standardUserDefaults] objectForKey:@"flashDuration"];
        [NSTimer scheduledTimerWithTimeInterval:[duration doubleValue] target:self.whiteFlashLight selector:@selector(turnOff) userInfo:nil repeats:NO];
        [NSTimer scheduledTimerWithTimeInterval:[duration doubleValue] target:self.redFlashLight selector:@selector(turnOff) userInfo:nil repeats:NO];
    }
}

-(void)arduinoFlash{
    if(debugMode == NO){
        [self turnOffAllLights];
        [self.whiteFlashLight turnOnWithDelay];
        [self.redFlashLight turnOnWithDelay];
    }
}


-(void)activatePinForLight:(Light *)light {
    UInt8 buf[] = {light.pin, 0x01, light.intensity};
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    int i = 0;
    NSLog(@"0x%02X, 0x%02X, 0x%02X", buf[i], buf[i+1], buf[i+2]);
    [ble write:data];
}

-(void)deactivatePinForLight:(Light *)light{
    UInt8 buf[] = {light.pin, 0x00, 0x00};
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    int i = 0;
    NSLog(@"0x%02X, 0x%02X, 0x%02X", buf[i], buf[i+1], buf[i+2]);
    [ble write:data];
}

-(void)activatePinForLightForDelay:(Light *)light{
    UInt8 arduinoDelay = [[[NSUserDefaults standardUserDefaults] objectForKey:@"arduinoDelay"]intValue];
    UInt8 buf[] = {light.pin, arduinoDelay, light.intensity};
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    int i = 0;
    NSLog(@"0x%02X, 0x%02X, 0x%02X", buf[i], buf[i+1], buf[i+2]);
    [ble write:data];
}
*/

//FBM
-(void)setIlluminationWhite:(int)whiteIntensity Red:(int)redIntensity {
    UInt8 buf[] = {0x01, whiteIntensity, redIntensity};
    [ble write:[NSData dataWithBytes:buf length:3]];
    //[NSThread sleepForTimeInterval:0.1];
}

-(void)setIlluminationWithCallbackWhite:(int)whiteIntensity Red:(int)redIntensity {
    UInt8 buf[] = {0x02, whiteIntensity, redIntensity};
    [ble write:[NSData dataWithBytes:buf length:3]];
    //[NSThread sleepForTimeInterval:0.1];
}

-(void)setFlashIntensityWhite:(int)whiteIntensity Red:(int)redIntensity {
    UInt8 buf[] = {0x03, whiteIntensity, redIntensity};
    [ble write:[NSData dataWithBytes:buf length:3]];
    //[NSThread sleepForTimeInterval:0.1];
}

-(void)doFlashWithDuration:(int)flashDuration {
    UInt8 buf[] = {0x04, flashDuration, 0x00};
    [ble write:[NSData dataWithBytes:buf length:3]];
    //[NSThread sleepForTimeInterval:0.1];
}

-(void)setFixationLight:(int)fixationLight Intensity:(int)intensity {
    UInt8 buf[] = {0x05, fixationLight, intensity};
    [ble write:[NSData dataWithBytes:buf length:3]];
    //[NSThread sleepForTimeInterval:0.1];
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
