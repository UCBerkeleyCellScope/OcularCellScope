//
//  IlluminationSystem.h
//  OcularCellscope
//
//  Created by Chris Echanique on 4/17/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Light.h"
#import "BLE.h"

@interface OCSBluetooth : BLE

@property (strong, nonatomic) Light *redLight;
@property (strong, nonatomic) Light *whiteLight;
@property (strong, nonatomic) NSArray *fixationLights;
@property (assign, nonatomic) BOOL isConnected;

-(void)turnOffAllLights;
-(void)timedFlash;
-(void)activatePinForLight:(Light *)light;
-(void)deactivatePinForLight:(Light *)light;

@end
