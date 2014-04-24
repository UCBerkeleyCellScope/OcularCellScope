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

-(id)initWithBLE:(BLEManager *)bluetooth pin:(int)p intensity:(int)i{
    self = [super init];
    if(self){
        self.bluetoothSystem = bluetooth;
        self.pin = p;
        self.intensity = i;
        self.isOn = NO;
    }
    return self;
}

-(void) changeIntensity: (int) i{
    self.intensity = i;
    [self.bluetoothSystem activatePinForLight:self];
}


-(void) toggleLight{
    self.isOn = !self.isOn;
}

-(void) turnOff{
    //if(self.isOn){
        [self.bluetoothSystem deactivatePinForLight:self];
        NSLog(@"Let's turn a light ON!");
    //}
    self.isOn = NO;
}

-(void) turnOn{
    if(!self.isOn){
        [self.bluetoothSystem activatePinForLight:self];
        NSLog(@"Let's turn a light ON!");
    }
    self.isOn = YES;
}

@end
