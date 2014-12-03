//
//  CameraAppDelegate.m
//  AV Camera App
//
//  Created by NAYA LOUMOU on 11/11/13.
//  Copyright (c) 2013 UC Berkeley Ocular CellScope. All rights reserved.
//

#import "CameraAppDelegate.h"
#import <Parse/Parse.h>
#import "PopupMessage.h"

@import AVFoundation;

@implementation CameraAppDelegate
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

@synthesize prefs = _prefs;
@synthesize debugMode;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    NSString* defaultPrefsFile = [[NSBundle mainBundle] pathForResource:@"default-configuration" ofType:@"plist"];
    NSDictionary* defaultPreferences = [NSDictionary dictionaryWithContentsOfFile:defaultPrefsFile];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultPreferences];
    

    [Parse setApplicationId:@"kj1p0NcAg3KwmTebw5N4MtbZCkx2WASRWSxTWuto"
                  clientKey:@"Pf88GrjkeE9rp7QJulrKxxOc7sDDOnQmOIw8WMpO"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    // Wipe out old user defaults
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"objectIDArray"]){
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"objectIDArray"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Simple way to create a user or log in the existing user
    // For your app, you will probably want to present your own login screen
    PFUser *currentUser = [PFUser currentUser];
    
    if (!currentUser) {
        // Dummy username and password
        PFUser *user = [PFUser user];
        user.username = @"Hermione";
        user.password = @"password";
        user.email = @"PotterLuv@example.com";
        
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                // Assume the error is because the user already existed.
                [PFUser logInWithUsername:@"Hermione" password:@"password"];
            }
        }];
    }
    
    [[CellScopeContext sharedContext] setManagedObjectContext:self.managedObjectContext];
    
    [[[CellScopeContext sharedContext] bleManager] beginBLEScan];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fixationDisplayChange:) name:@"FixationDisplayChangeNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(voltageNotification:) name:@"CellScopeVoltageNotification" object:nil];
    
    
    return YES;
}

- (void)fixationDisplayChange:(NSNotification *)notification
{
    
    NSDictionary *ui = [notification userInfo];
    NSString* newDisplayState = ui[@"displayState"];
    NSString* alertString;
    NSLog(@"%@",newDisplayState);
    
    if ([newDisplayState isEqualToString:@"NONE"]) {
        alertString = @"Display Removed";
    }
    else if ([newDisplayState isEqualToString:@"OD"]) {
        alertString = @"Display Attached (OD)";
    }
    else if ([newDisplayState isEqualToString:@"OS"]) {
        alertString = @"Display Attached (OS)";
    }
    
    
    [PopupMessage showPopup:alertString];
    

}

- (void)voltageNotification:(NSNotification *)notification
{
    NSDictionary *ui = [notification userInfo];
    float newVoltage = ((NSNumber*)ui[@"voltage"]).floatValue;
    
    static BOOL lowBatteryWarning = NO;
    
    if (lowBatteryWarning==NO && (newVoltage<[[NSUserDefaults standardUserDefaults] floatForKey:@"batteryWarningThreshold"])) {
        lowBatteryWarning = YES;
        [PopupMessage showPopup:@"CellScope Low Battery"];
    }
    else if (lowBatteryWarning==YES && (newVoltage<[[NSUserDefaults standardUserDefaults] floatForKey:@"batteryOKThreshold"]) ){
        lowBatteryWarning = NO;
    }
    
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    /*
    if(  [[CellScopeContext sharedContext] ble].activePeripheral.state == CBPeripheralStateConnected)
    {
        [[ [[CellScopeContext sharedContext] ble] CM] cancelPeripheralConnection:[[[CellScopeContext sharedContext] ble] activePeripheral]];
        
    }
     */
    
    
    [self saveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CameraModel" withExtension:@"momd"];
    NSLog(@"Model started %@", modelURL);
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CameraModel.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end

