//
//  Images.h
//  AV Camera App
//
//  Created by Chris Echanique on 12/8/13.
//  Copyright (c) 2013 NAYA LOUMOU. All rights reserved.
//

//BITCH YOU AIN'T SPECIAL

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Patients;

@interface Images : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * drName;
@property (nonatomic, retain) NSString * eyeLocation;
@property (nonatomic, retain) NSString * filepath;
@property (nonatomic, retain) Patients *patient;

@end
