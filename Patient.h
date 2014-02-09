//
//  Patient.h
//  OcularCellscope
//
//  Created by PJ Loury on 2/8/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Image;

@interface Patient : NSManagedObject

@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * patientID;
@property (nonatomic, retain) NSString * patientName;
@property (nonatomic, retain) NSOrderedSet *patientImages;
@end

@interface Patient (CoreDataGeneratedAccessors)

- (void)insertObject:(Image *)value inPatientImagesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromPatientImagesAtIndex:(NSUInteger)idx;
- (void)insertPatientImages:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removePatientImagesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInPatientImagesAtIndex:(NSUInteger)idx withObject:(Image *)value;
- (void)replacePatientImagesAtIndexes:(NSIndexSet *)indexes withPatientImages:(NSArray *)values;
- (void)addPatientImagesObject:(Image *)value;
- (void)removePatientImagesObject:(Image *)value;
- (void)addPatientImages:(NSOrderedSet *)values;
- (void)removePatientImages:(NSOrderedSet *)values;
@end
