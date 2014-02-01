//
//  Patients.h
//  AV Camera App
//
//  Created by Chris Echanique on 12/8/13.
//  Copyright (c) 2013 NAYA LOUMOU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Images;

@interface Patients : NSManagedObject

@property (nonatomic, retain) NSString * patientID;
@property (nonatomic, retain) NSString * patientName;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSSet *patientImages;
@end

@interface Patients (CoreDataGeneratedAccessors)

- (void)addPatientImagesObject:(Images *)value;
- (void)removePatientImagesObject:(Images *)value;
- (void)addPatientImages:(NSSet *)values;
- (void)removePatientImages:(NSSet *)values;

@end
