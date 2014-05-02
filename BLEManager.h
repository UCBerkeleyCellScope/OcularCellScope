//
//  BLEManager.m
//  OcularCellscope
//
//  Created by PJ Loury on 4/22/14.
//  Copyright (c) 2014 UC Berkeley Ocular CellScope. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CellScopeContext.h"
#import "Light.h"

@protocol BLEConnectionDelegate
-(void)didReceiveConnectionConfirmation;
-(void)didReceiveFlashConfirmation;
-(void) didReceiveNoBLEConfirmation;
@end

@interface BLEManager : BLE<BLEDelegate>

@property (strong, nonatomic) Light *redLight;
@property (strong, nonatomic) Light *whiteLight;
@property (strong, nonatomic) Light *whitePing;
@property (strong, nonatomic) Light *remoteLight;
@property (strong, nonatomic) NSArray *fixationLights;

@property(nonatomic, strong) NSUserDefaults *prefs;
@property (assign, nonatomic) BOOL isConnected;
@property (nonatomic) NSInteger selectedLight;
@property BOOL debugMode;
@property (strong, nonatomic) BLE *ble;
@property (weak, nonatomic) id <BLEConnectionDelegate> BLECdelegate;

-(void)turnOffAllLights;
-(void)timedFlash;
-(void)arduinoFlash;
-(void)activatePinForLight:(Light *)light;
-(void)deactivatePinForLight:(Light *)light;
-(void)btnScanForPeripherals;
-(void) disconnect;
-(void) bleDelay;
-(void)activatePinForLightForDelay:(Light *)light;
@end
