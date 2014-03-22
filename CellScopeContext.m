//
//  CellScopeContext.m
//  edscope
//
//  Created by Frankie Myers on 11/29/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//


#import "CellScopeContext.h"

@implementation CellScopeContext

@synthesize selectedEye,selectedLight,ble, currentExam;

+ (id)sharedContext {
    static CellScopeContext *newContext = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        newContext = [[self alloc] init];
    });
    return newContext;
}

- (id)init {
    if (self = [super init]) {
        selectedEye = @"";
        selectedLight = 0;
        
        ble = [[BLE alloc] init];
        [ble controlSetup];
        
        
        
    }
    return self;
}

@end

