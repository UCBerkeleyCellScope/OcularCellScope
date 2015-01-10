//
//  CellScopeContext.h
//  edscope
//
//  Created by Frankie Myers on 11/29/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "Exam.h"
#import "EyeImage.h"
#import "SelectableEyeImage.h"
#import "BLE.h"
#import "Constants.h"
#import "AFNetworking.h"
#import "BLEManager.h"
#import "UIColor+Custom.h"
#import "CellScopeHTTPClient.h"
#import "ParseUploadManager.h"
#import <CoreText/CoreText.h>
#import <Parse/Parse.h>
#import "LoggingManager.h"

@class BLEManager;
@class CellScopeHTTPClient;
@class ParseUploadManager;

@interface CellScopeContext : NSObject

@property (nonatomic, retain) NSManagedObjectContext* managedObjectContext;


@property (nonatomic) int selectedEye;
//@property (nonatomic, strong) BLE* ble;
@property (nonatomic, retain) Exam* currentExam;
@property (nonatomic) BOOL connected;
@property(nonatomic,strong) BLEManager* bleManager;
@property (nonatomic) BOOL camViewLoaded;
@property (nonatomic) CellScopeHTTPClient* client;

@property (nonatomic) ParseUploadManager *uploadManager;

@property (nonatomic) LoggingManager *loggingManager;


+ (id)sharedContext;

@end
