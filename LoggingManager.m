//
//  LoggingManager.m
//  Ocular Cellscope
//
//  Created by Frankie Myers on 12/15/14.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "LoggingManager.h"

@implementation LoggingManager

@synthesize logMOC = _logMOC;
@synthesize coordinator = _coordinator;

- (void)setPersistentStoreCoordinator:(NSPersistentStoreCoordinator*)coordinator
{
    _logMOC = [[NSManagedObjectContext alloc] init];
    [_logMOC setPersistentStoreCoordinator:coordinator];
    _coordinator = coordinator;
}

- (void)CSLog:(NSString*)entry inCategory:(NSString*)cat
{
    
    NSLog(@"%@",[NSString stringWithFormat:@"%@>> %@",cat,entry]);
    
    Logs* logEntry = (Logs*)[NSEntityDescription insertNewObjectForEntityForName:@"Logs" inManagedObjectContext:_logMOC];
    
    logEntry.entry = entry;
    logEntry.category = cat;
    logEntry.date = [NSDate date];
    logEntry.synced = NO;
    
    dispatch_async(dispatch_get_main_queue(), ^{ //trying this, not sure how to ensure thread safety here
        NSError* err;
        [_logMOC save:&err];
        if (err) {
            NSLog(err);
        }
    });
}


@end
