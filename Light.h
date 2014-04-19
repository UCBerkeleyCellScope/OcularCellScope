//
//  Light.h
//  OcularCellscope
//
//  Created by Chris Echanique on 4/17/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import <Foundation/Foundation.h>
@class OCSBluetooth;

@interface Light : NSObject

@property (assign, nonatomic) BOOL isOn;
@property (assign, nonatomic) int intensity;
@property (assign, nonatomic) int pin;
@property (weak, nonatomic) OCSBluetooth *bluetoothSystem;

-(void)toggleLight;
-(void)turnOff;
-(void)turnOn;
-(id)initWithBLE:(OCSBluetooth *)bluetooth;

@end
