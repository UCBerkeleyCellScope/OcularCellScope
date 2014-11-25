//
//  Exam+Methods.h
//  OcularCellscope
//
//  Created by PJ Loury on 5/2/14.
//  Copyright (c) 2014 UC Berkeley Ocular CellScope. All rights reserved.
//

#import "Exam.h"

@interface Exam (Methods)

//-(NSString*)randomExamStringWithLength:(int) len;
-(NSString*)randomExamString;

- (void)addEyeImagesObject:(EyeImage *)image;
- (NSString*)fullName;
- (EyeImage*)getFirstImage;
-(NSString*)dateString;
- (int) numberOfImagesUploaded;

@end
