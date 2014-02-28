//
//  Exam.h
//  OcularCellscope
//
//  Created by PJ Loury on 2/28/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Exam : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * patientID;
@property (nonatomic, retain) NSString * patientName;
@property (nonatomic, retain) NSManagedObject *relationship;

@end
