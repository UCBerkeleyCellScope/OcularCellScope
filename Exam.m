//
//  Exam.m
//  OcularCellscope
//
//  Created by PJ Loury on 6/21/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import "Exam.h"
#import "EyeImage.h"


@implementation Exam

@dynamic date;
@dynamic firstName;
@dynamic lastName;
@dynamic notes;
@dynamic patientID;  //user-specified ID
@dynamic patientIndex;  //this is an auto-incrementing number, unique to each exam on the phone
@dynamic phoneNumber;  //patient's phone number
@dynamic profilePicData;  //unused
@dynamic studyName;  //string indicating which study this exam is associated with (e.g. "Thailand")
@dynamic uploaded;  //indicates upload state of this exam
@dynamic uuid;
@dynamic birthDate;
@dynamic eyeImages; //collection of EyeImage objects for this exam

@end
