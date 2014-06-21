//
//  EyeImage+EyeImage_Methods.m
//  OcularCellscope
//
//  Created by PJ Loury on 6/12/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

@class Exam;

#import "Exam.h"
#import "EyeImage+Methods.h"

@implementation EyeImage (Methods)

-(NSString*)fileName{
    
    //self.exam.firstName

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSString *textDate = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:self.date]];
    NSLog(@"Date %@",textDate);

    return [NSString stringWithFormat:@"%@-%@-%@-%@",textDate,self.eye,self.fixationLight,self.uuid];
    
}


@end
