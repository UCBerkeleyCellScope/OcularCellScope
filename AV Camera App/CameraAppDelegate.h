//
//  CameraAppDelegate.h
//  AV Camera App
//
//  Created by NAYA LOUMOU on 11/11/13.
//  Copyright (c) 2013 NAYA LOUMOU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CellScopeContext.h"
#import "PatientInfoViewController.h"
#import "PatientsTableViewController.h"
#import "MainMenuViewController.h"
#import "CaptureViewController.h"
#import "BLEManager.h"

@interface CameraAppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong,nonatomic) Exam *currentExam;
@property (strong, nonatomic) BLE *ble;
@property (strong, nonatomic) CaptureViewController *cvc;
@property(nonatomic, strong) NSUserDefaults *prefs;
@property BOOL debugMode;


- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end



