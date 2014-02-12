//
//  Patient.m
//  OcularCellscope
//
//  Created by PJ Loury on 2/8/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import "Patient.h"
#import "Image.h"


@implementation Patient

@dynamic firstName;
@dynamic lastName;
@dynamic notes;
@dynamic patientID;
@dynamic patientName;
@dynamic patientImages;

- (void)addPatientImagesObject:(Image *)value{
    
    NSMutableOrderedSet* tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.patientImages];
    [tempSet addObject:value];
    self.patientImages = tempSet;
}


@end
