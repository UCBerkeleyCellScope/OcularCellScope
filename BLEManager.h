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
@property NSTimer* batteryQueryTimer;

-(void)beginBLEScan;
-(void)disconnect;

-(void)setIlluminationWhite:(UInt8)whiteIntensity Red:(UInt8)redIntensity;
-(void)setIlluminationWithCallbackWhite:(UInt8)whiteIntensity Red:(UInt8)redIntensity;
-(void)setFlashIntensityWhite:(UInt8)whiteIntensity Red:(UInt8)redIntensity;
-(void)setFlashTimingDelay:(UInt16)flashDelay Duration:(UInt16)flashDuration;
-(void)doFlash;
-(void)setFixationLight:(int)fixationLight forEye:(int)eye withIntensity:(int)intensity;
-(void)setDisplayCoordinatesToX:(int)x Y:(int)y;
-(void)doSelfTest;

@end
