//
//  Logs.h
//  Ocular Cellscope
//
//  Created by Frankie Myers on 12/15/14.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Logs : NSManagedObject

@property (nonatomic, retain) NSDate* date;
@property (nonatomic, retain) NSString * entry;
@property (nonatomic, retain) NSNumber* synced;
@property (nonatomic, retain) NSString * category;

@end

