//
//  CellScopeContext.h
//  edscope
//
//  Created by Frankie Myers on 11/29/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//
//  This singleton class gets instantiated at startup and maintains important program state throughout
//  the app's lifetime


#import "Exam.h"
#import "EyeImage.h"
#import "SelectableEyeImage.h"
#import "BLE.h"
#import "Constants.h"
#import "AFNetworking.h"
#import "BLEManager.h"
#import "UIColor+Custom.h"
#import "ParseUploadManager.h"
#import <CoreText/CoreText.h>
#import <Parse/Parse.h>
#import "LoggingManager.h"

@class BLEManager;
@class ParseUploadManager;

@interface CellScopeContext : NSObject

//Core data MOC used throughout app
@property (nonatomic, retain) NSManagedObjectContext* managedObjectContext;

//Pointer to the current exam
@property (nonatomic, retain) Exam* currentExam;

//communicates with hardware
@property(nonatomic,strong) BLEManager* bleManager;

//this is probably no longer used
//@property (nonatomic) CellScopeHTTPClient* client;

//manages image uploading to parse
@property (nonatomic) ParseUploadManager *uploadManager;

//manages in-app logging
@property (nonatomic) LoggingManager *loggingManager;

//a few state variables, some of which may be vestigal
@property (nonatomic) int selectedEye;
@property (nonatomic) BOOL connected;
@property (nonatomic) BOOL camViewLoaded;

//this class method returns a pointer to the CellScopeContext singleton
+ (id)sharedContext;

@end
