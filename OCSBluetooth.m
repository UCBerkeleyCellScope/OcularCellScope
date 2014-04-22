//
//  IlluminationSystem.m
//  OcularCellscope
//
//  Created by Chris Echanique on 4/17/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import "OCSBluetooth.h"

@implementation OCSBluetooth

@synthesize redLight = _redLight;
@synthesize whiteLight = _whiteLight;
@synthesize fixationLights = _fixationLights;

-(id)init{
    self = [super init];
    if(self){
        self.redLight = [[Light alloc] initWithBLE:self];
        self.whiteLight = [[Light alloc] initWithBLE:self];
        NSMutableArray *lights = [[NSMutableArray alloc] init];
        for(int i = 1; i <= 5; ++i){
            [lights addObject:[[Light alloc] initWithBLE:self]];
        }
        self.fixationLights = lights;
    }
    return self;
}

-(void)turnOffAllLights{
    [self.redLight turnOff];
    [self.whiteLight turnOff];
    for(Light *light in self.fixationLights){
        [light turnOff];
    }
}

-(void)timedFlash{
    [self turnOffAllLights];
    [self.whiteLight turnOn];
    NSNumber *duration = [[NSUserDefaults standardUserDefaults] objectForKey:@"flashDuration"];
    [NSTimer scheduledTimerWithTimeInterval:[duration doubleValue] target:self.whiteLight selector:@selector(turnOff) userInfo:nil repeats:NO];
}

-(void)activatePinForLight:(Light *)light{
    
}

-(void)deactivatePinForLight:(Light *)light{
    //ble write
}

@end
