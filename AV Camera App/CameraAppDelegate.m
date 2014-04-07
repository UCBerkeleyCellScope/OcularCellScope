//
//  CameraAppDelegate.m
//  AV Camera App
//
//  Created by NAYA LOUMOU on 11/11/13.
//  Copyright (c) 2013 NAYA LOUMOU. All rights reserved.
//

#import "CameraAppDelegate.h"
#import "CellScopeContext.h"
#import "CaptureViewController.h"
#import "Constants.h"

@implementation CameraAppDelegate
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

@synthesize currentExam = _currentExam;
@synthesize ble;
@synthesize cvc;

int attempts = 0;
BOOL capturing = NO;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    ble = [[BLE alloc] init];
    [ble controlSetup];
    ble.delegate = self;
    
    NSString* defaultPrefsFile = [[NSBundle mainBundle] pathForResource:@"default-configuration" ofType:@"plist"];
    NSDictionary* defaultPreferences = [NSDictionary dictionaryWithContentsOfFile:defaultPrefsFile];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultPreferences];
    
    [[CellScopeContext sharedContext] setManagedObjectContext:self.managedObjectContext];
    
    [[CellScopeContext sharedContext] setBle: ble];
    
    [self btnScanForPeripherals];
    
    return YES;
}

- (void)btnScanForPeripherals
{
    
    if (ble.activePeripheral)
        if(ble.activePeripheral.state == CBPeripheralStateConnected){
            [[ble CM] cancelPeripheralConnection:[ble activePeripheral]];
            //[bleConnect setTitle:@"Connect"];
        }
    
    if (ble.peripherals)
        ble.peripherals = nil;
    
    //[bleConnect setEnabled:false];
    [ble findBLEPeripherals:2];  //WHY IS THIS 2?
    
    [NSTimer scheduledTimerWithTimeInterval:(float)2.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
    
}

-(void) connectionTimer:(NSTimer *)timer
{
    //[bleConnect setEnabled:true];
    //[bleConnect setTitle: @"Disconnect"];
    
    if (ble.peripherals.count > 0)
    {
        [ble connectPeripheral:[ble.peripherals objectAtIndex:0]];
        NSLog(@"At least attempting connection");
        
    }
    else if(attempts < 2 && capturing == NO)
    {
        //[bleConnect setTitle:@"Connect"];
        NSLog(@"No peripherals found, initiaiting attempt number %d", attempts);
        [self btnScanForPeripherals];
        attempts++;
    }
    else{
        NSLog(@"Why didn't we exit??");
        //[_aiv stopAnimating];
        //[captureButton setEnabled:YES];
    }
}

- (void)bleDidDisconnect
{
    NSLog(@"->Disconnected");
    [self btnScanForPeripherals];
    [[CellScopeContext sharedContext] setConnected: NO];
    NSLog(@"Connected set back to NO");

}

-(void) bleDidConnect
{
//    [_aiv stopAnimating];
//    [captureButton setEnabled:YES];
    UInt8 buf[] = {0xFF, 0x00, 0x00}; //IDEA: Could have a corresponding LED blink to
    //acknowledge reset on Arduino side (but this is done successfully in SimpleControls)
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [ble write:data];
    NSLog(@"BLE has succesfully connected");
    
    [[CellScopeContext sharedContext] setConnected: YES];
    
    cvc = [[CellScopeContext sharedContext] cvc];
    
    //if([cvc alreadyLoaded]== YES){
        [cvc toggleAuxilaryLight:cvc.selectedLight toggleON:YES];
        [cvc toggleAuxilaryLight: farRedLight toggleON:YES];
    //}
//    swDigitalOut.enabled = true;
//    swDigitalOut.on = false;
}

// When data is comming, this will be called
// Note that this will be multiple unsigned chars
-(void) bleDidReceiveData:(unsigned char *)data length:(int)length
{
    NSLog(@"Length: %d", length);
    
    // parse data, all commands are in 3-byte
    for (int i = 0; i < length; i+=3) //incrementing by 3
    {
        NSLog(@"RECEIVED: 0x%02X, 0x%02X, 0x%02X", data[i], data[i+1], data[i+2]);
        
        if (data[i] == 0x0A)
        {
            /*
             if (data[i+1] == 0x01)
             swDigitalIn.on = true;
             else
             swDigitalIn.on = false;
             */
        }
        else if (data[i] == 0x0B)
        {
            UInt16 Value;
            Value = data[i+2] | data[i+1] << 8;
            //lblAnalogIn.text = [NSString stringWithFormat:@"%d", Value];
        }
    }
    
    //if(data[0]==0xFF && data[1]==0xFF){
        [cvc toggleAuxilaryLight:flashNumber toggleON:NO];
    //}
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

