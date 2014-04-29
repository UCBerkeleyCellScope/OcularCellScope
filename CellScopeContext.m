//
//  CellScopeContext.m
//  edscope
//
//  Created by Frankie Myers on 11/29/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//


#import "CellScopeContext.h"

@implementation CellScopeContext

@synthesize selectedEye, currentExam, connected, bleManager, camViewLoaded;
@synthesize colorManager;

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
        NSLog(@"STARTED THE SINGLETON");
        selectedEye = @"";
        connected = NO;
        camViewLoaded = NO;
        //colorManager = [[UIColorManager alloc]init];
        bleManager = [[BLEManager alloc]init];
        NSLog(@"MADE THE SINGLETON");
        
    }
    return self;
}

@end

