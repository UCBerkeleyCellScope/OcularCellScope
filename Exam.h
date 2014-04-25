//
//  Exam.h
//  OcularCellscope
//
//  Created by PJ Loury on 3/18/14.
//  Copyright (c) 2014 UC Berkeley Ocular CellScope. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EyeImage;

@interface Exam : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * patientID;
@property (nonatomic, retain) NSString * patientName;
@property (nonatomic, retain) NSOrderedSet *eyeImages;
@end

@interface Exam (CoreDataGeneratedAccessors)

- (void)insertObject:(EyeImage *)value inEyeImagesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromEyeImagesAtIndex:(NSUInteger)idx;
- (void)insertEyeImages:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeEyeImagesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInEyeImagesAtIndex:(NSUInteger)idx withObject:(EyeImage *)value;
- (void)replaceEyeImagesAtIndexes:(NSIndexSet *)indexes withEyeImages:(NSArray *)values;

- (void)addEyeImagesObject:(EyeImage *)value;
- (void)removeEyeImagesObject:(EyeImage *)value;

- (void)addEyeImages:(NSOrderedSet *)values;
- (void)removeEyeImages:(NSOrderedSet *)values;

@end
