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

#define FIXATION_LIGHT_NONE 0
#define FIXATION_LIGHT_CENTER 1
#define FIXATION_LIGHT_UP 2
#define FIXATION_LIGHT_DOWN 3
#define FIXATION_LIGHT_LEFT 4
#define FIXATION_LIGHT_RIGHT 5

@protocol BLEConnectionDelegate
-(void)didReceiveConnectionConfirmation;
-(void)didReceiveFlashConfirmation;
-(void) didReceiveNoBLEConfirmation;
@end

@interface BLEManager : BLE<BLEDelegate>

/*@property (strong, nonatomic) Light *redFocusLight;
@property (strong, nonatomic) Light *whiteFlashLight;

@property (strong, nonatomic) Light *whiteFocusLight;
@property (strong, nonatomic) Light *redFlashLight;

@property (strong, nonatomic) Light *remoteLight;
@property (strong, nonatomic) NSArray *fixationLights;
*/

@property(nonatomic, strong) NSUserDefaults *prefs;
@property (assign, nonatomic) BOOL isConnected;
//@property (nonatomic) NSInteger selectedLight;
@property BOOL debugMode;
@property (strong, nonatomic) BLE *ble;
@property (weak, nonatomic) id <BLEConnectionDelegate> BLECdelegate;

//@property (strong, nonatomic) Light *whitePing;

/*
-(void)turnOffAllLights;
-(void)timedFlash;
-(void)arduinoFlash;
-(void)activatePinForLight:(Light *)light;
-(void)deactivatePinForLight:(Light *)light;
-(void) bleDelay;
-(void)activatePinForLightForDelay:(Light *)light;
*/

-(void)beginBLEScan;
-(void)disconnect;

-(void)setIlluminationWhite:(int)whiteIntensity Red:(int)redIntensity;
-(void)setIlluminationWithCallbackWhite:(int)whiteIntensity Red:(int)redIntensity;
-(void)setFlashIntensityWhite:(int)whiteIntensity Red:(int)redIntensity;
-(void)doFlashWithDuration:(int)flashDuration;
-(void)setFixationLight:(int)fixationLight Intensity:(int)intensity;
-(void)setDisplayCoordinatesToX:(int)x Y:(int)y;
-(void)doSelfTest;

@end
