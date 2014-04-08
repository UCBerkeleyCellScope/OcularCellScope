//
//  CellScopeContext.h
//  edscope
//
//  Created by Frankie Myers on 11/29/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "Exam.h"
#import "EyeImage.h"
#import "EImage.h"
#import "BLE.h"
#import "CaptureViewController.h"

#import "AFNetworking.h"

//static NSString * const BaseURLString = @"http://www.raywenderlich.com/demos/weather_sample/";
static NSString * const BaseURLString = @"http://ec2-54-186-247-188.us-west-2.compute.amazonaws.com/";
//This needs to be changed

@interface CellScopeContext : NSObject

//TODO: add managed object context, session, etc.
@property (nonatomic, retain) NSManagedObjectContext* managedObjectContext;


@property (nonatomic) NSInteger selectedLight;
@property (nonatomic, retain) NSString* selectedEye;
@property (nonatomic, strong) BLE* ble;
@property (nonatomic, retain) Exam* currentExam;
@property (nonatomic) BOOL connected;

@property CaptureViewController *cvc;

+ (id)sharedContext;

@end
