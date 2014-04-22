//
//  Light.m
//  OcularCellscope
//
//  Created by Chris Echanique on 4/17/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import "Light.h"
#import "OCSBluetooth.h"
#define CENTER_LIGHT 1
#define TOP_LIGHT 2
#define BOTTOM_LIGHT 3
#define LEFT_LIGHT 4
#define RIGHT_LIGHT 5
#define RED_LIGHT 9
#define WHITE_LIGHT 10

@implementation Light

@synthesize isOn = _isOn;
@synthesize intensity = _intensity;
@synthesize bluetoothSystem = _bluetoothSystem;

-(id)initWithBLE:(OCSBluetooth *)bluetooth{
    self = [super init];
    if(self){
        self.bluetoothSystem = bluetooth;
    }
    return self;
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
