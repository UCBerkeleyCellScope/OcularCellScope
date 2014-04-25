//
//  IlluminationSystem.m
//  OcularCellscope
//
//  Created by Chris Echanique on 4/17/14.
//  Copyright (c) 2014 UC Berkeley Ocular CellScope. All rights reserved.
//

#import "BLEManager.h"


@implementation BLEManager

@synthesize redLight = _redLight;
@synthesize whiteLight = _whiteLight;
@synthesize remoteLight = _remoteLight;
@synthesize whitePing = _whitePing;
@synthesize fixationLights = _fixationLights;
@synthesize ble;
@synthesize prefs = _prefs;
@synthesize debugMode;
@synthesize isConnected = _isConnected;
@synthesize selectedLight = _selectedLight;
@synthesize BLECdelegate = _BLECdelegate;

int attempts = 0;
BOOL capturing = NO;

-(id)init{
    self = [super init];
    if(self){
        ble = [[BLE alloc] init];
        [ble controlSetup];
        ble.delegate = self;
     
        [[CellScopeContext sharedContext] setBle: ble];
        
        _prefs = [NSUserDefaults standardUserDefaults];

        int r_i = [_prefs integerForKey:@"redLightValue"];
        int w_i = [_prefs integerForKey:@"flashLightValue"];
        
        if (r_i<10){
            [_prefs setInteger: 50 forKey:@"redLightValue"];
            r_i = 50;
        }
        
        _redLight = [[Light alloc] initWithBLE:self pin:RED_LIGHT intensity: r_i ];
        _whiteLight = [[Light alloc] initWithBLE:self pin:WHITE_LIGHT intensity: w_i ];
        _whitePing = [[Light alloc] initWithBLE:self pin:WHITE_PING intensity: w_i];
        _remoteLight = [[Light alloc] initWithBLE:self pin:REMOTE_LIGHT intensity: 255];
        
        _prefs = [NSUserDefaults standardUserDefaults];
        debugMode = [_prefs boolForKey:@"debugMode" ];
        
        
        NSMutableArray *lights = [[NSMutableArray alloc] init];
        for(int i = 0; i <= 5; ++i){
            [lights addObject:[[Light alloc] initWithBLE:self pin: i intensity: 255]];
        }
        _fixationLights = lights;
    }
    return self;
}


- (void)btnScanForPeripherals
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
}

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

-(void) disconnect{
    if (ble.activePeripheral)
        if(ble.activePeripheral.state == CBPeripheralStateConnected){
            [[ble CM] cancelPeripheralConnection:[ble activePeripheral]];
        }
}

-(void) bleDelay{
    NSNumber *bleDelay = [[NSUserDefaults standardUserDefaults] objectForKey:@"bleDelay"];
    [NSThread sleepForTimeInterval: [bleDelay doubleValue]];
}


- (void)bleDidDisconnect
{
    NSLog(@"->Disconnected");
    //[self btnScanForPeripherals];
    _isConnected = NO;
    if(debugMode==NO){
        [self btnScanForPeripherals];
    }
    NSLog(@"Connected set back to NO");
    
}

-(void) bleDidConnect
{
    NSLog(@"BLE has succesfully connected");
    [self turnOffAllLights];
    
    _isConnected = YES;
    
    if([[CellScopeContext sharedContext]camViewLoaded]==YES){
        [self.redLight turnOn];
        [[self.fixationLights objectAtIndex: _selectedLight] turnOn];
        [_BLECdelegate didReceiveConnectionConfirmation];
    }
}


-(void) bleDidReceiveData:(unsigned char *)data length:(int)length
{
    NSLog(@"Length: %d", length);
    
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
    
    if(data[0]==0xFF && data[1]==0xFF){
        //id<BLEConnectionDelegate> strongDelegate = self.BLECdelegate;
        [_BLECdelegate didReceiveFlashConfirmation];
    }
    
}

-(void)turnOffAllLights{
    
    if(debugMode==NO){
        for(Light *l in self.fixationLights){
            l.isOn = NO;
        }
        self.whiteLight.isOn = NO;
        self.redLight.isOn = NO;
        self.remoteLight.isOn = NO;
        
        UInt8 buf[] = {0xFF, 0x00, 0x00};
        NSData *data = [[NSData alloc] initWithBytes:buf length:3];
        [ble write:data];
    }
}

-(void)timedFlash{
    if(debugMode == NO){
        [self turnOffAllLights];
        [self.whiteLight turnOn];    
        NSNumber *duration = [[NSUserDefaults standardUserDefaults] objectForKey:@"flashDuration"];
        [NSTimer scheduledTimerWithTimeInterval:[duration doubleValue] target:self.whiteLight selector:@selector(turnOff) userInfo:nil repeats:NO];
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

@end
