//
//  LoggingManager.h
//  Ocular Cellscope
//
//  Created by Frankie Myers on 12/15/14.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//
//  Defines a quick and easy method for saving log messages, CSLog(). This singleton method maintains
//  its own MOC and saves log messages to core data. These are uploaded to Parse whenever an image is uploaded.

#import <Foundation/Foundation.h>
#import "Logs.h"

#define CSLog(entry,category) [[[CellScopeContext sharedContext] loggingManager] CSLog:entry inCategory:category]


@interface LoggingManager : NSObject

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *coordinator;


@property (readonly, strong, nonatomic) NSManagedObjectContext *logMOC; //this is just used for logging

- (void)setPersistentStoreCoordinator:(NSPersistentStoreCoordinator*)coordinator;

- (void)CSLog:(NSString*)entry inCategory:(NSString*)cat;


@end
