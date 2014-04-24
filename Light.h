//
//  Light.h
//  OcularCellscope
//
//  Created by Chris Echanique on 4/17/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import <Foundation/Foundation.h>
#define CENTER_LIGHT 0
#define TOP_LIGHT 1
#define BOTTOM_LIGHT 2
#define LEFT_LIGHT 3
#define RIGHT_LIGHT 4
#define RED_LIGHT 9
#define WHITE_LIGHT 10
#define WHITE_PING 11
#define REMOTE_LIGHT 12

@class BLEManager;

@interface Light : NSObject

@property (assign, nonatomic) BOOL isOn;
@property (assign, nonatomic) int intensity;
@property (assign, nonatomic) int pin;
@property (weak, nonatomic) BLEManager *bluetoothSystem;

-(void)toggleLight;
-(void)turnOff;
-(void)turnOn;
-(id)initWithBLE:(BLEManager *)bluetooth pin:(int)p intensity:(int)i;
-(void)changeIntensity:(int)i;
@end
