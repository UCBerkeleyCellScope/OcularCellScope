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
#import "Constants.h"
#import "AFNetworking.h"
#import "BLEManager.h"

@class BLEManager;

@interface CellScopeContext : NSObject

@property (nonatomic, retain) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, retain) NSString* selectedEye;
@property (nonatomic, strong) BLE* ble;
@property (nonatomic, retain) Exam* currentExam;
@property (nonatomic) BOOL connected;
@property(nonatomic,strong) BLEManager* bleManager;
@property (nonatomic) BOOL camViewLoaded;

+ (id)sharedContext;

@end
