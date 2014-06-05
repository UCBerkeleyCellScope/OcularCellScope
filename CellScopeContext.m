//
//  CellScopeContext.m
//  edscope
//
//  Created by Frankie Myers on 11/29/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//


#import "CellScopeContext.h"

//static NSString * const CellScopeAPIKey = @"PASTE YOUR API KEY HERE";
static NSString * const CellScopeURLString = @"http://warm-dawn-6399.herokuapp.com/";
//static NSString * const CellScopeURLString = @"http://localhost:5000/";


@implementation CellScopeContext

@synthesize selectedEye, currentExam, connected, bleManager, camViewLoaded, client, s3manager;

+ (id)sharedContext {
    static CellScopeContext *newContext = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        newContext = [[self alloc] init];
    });
    return newContext;
}

/**
 *  <#Description#>
 *
 *  @return reference to the Singleton Context
 */

- (id)init {
    if (self = [super init]) {
        NSLog(@"STARTED THE SINGLETON");
        selectedEye = @"";
        connected = NO;
        camViewLoaded = NO;
        bleManager = [[BLEManager alloc]init];
        s3manager = [[S3manager alloc]init];
        client = [[CellScopeHTTPClient alloc]initWithBaseURL:[NSURL URLWithString:CellScopeURLString]];
        NSLog(@"MADE THE SINGLETON");
        
    }
    return self;
}

@end

