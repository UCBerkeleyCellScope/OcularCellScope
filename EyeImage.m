//
//  EyeImage.m
//  OcularCellscope
//
//  Created by PJ Loury on 6/21/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//
//  This represents a single image taken as part of an exam

#import "EyeImage.h"
#import "Exam.h"


@implementation EyeImage

@dynamic date;
@dynamic drName;
@dynamic eye;  //which eye (string "OD" or "OS")
@dynamic filePath;  //the path to the jpeg stored in the asset library
@dynamic fixationLight;  //which fixation light was on when this was taken (numeric, 0-5)
@dynamic thumbnail;  //binary data containing a miniature thumbnail of this image
@dynamic uploaded; //indicates whether this image has been uploaded to parse
@dynamic uuid; //not sure if this is still used
@dynamic exam; //reference to parent exam object

@end
