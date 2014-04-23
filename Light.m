//
//  Light.m
//  OcularCellscope
//
//  Created by Chris Echanique on 4/17/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import "Light.h"
#import "BLEManager.h"

@implementation Light

@synthesize isOn = _isOn;
@synthesize intensity = _intensity;
@synthesize bluetoothSystem = _bluetoothSystem;
@synthesize pin = _pin;

-(id)initWithBLE:(BLEManager *)bluetooth pin:(int)p{
    self = [super init];
    if(self){
        self.bluetoothSystem = bluetooth;
        self.pin = p;
    }
    return self;
}

-(void) setIntensity: (int) i{
    [self.bluetoothSystem activatePinForLight:self];
}


-(void) toggleLight{
    self.isOn = !self.isOn;
}

-(void) turnOff{
    if(self.isOn){
        [self.bluetoothSystem deactivatePinForLight:self];
    }
    self.isOn = NO;
}

-(void) turnOn{
    if(!self.isOn){
        [self.bluetoothSystem activatePinForLight:self];
    }
    self.isOn = YES;
}

@end
