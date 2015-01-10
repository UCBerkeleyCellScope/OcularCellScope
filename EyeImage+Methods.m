//
//  EyeImage+EyeImage_Methods.m
//  OcularCellscope
//
//  Created by PJ Loury on 6/12/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import "Exam.h"
#import "EyeImage+Methods.h"

@implementation EyeImage (Methods)

NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";


-(NSString*)randomEyeImageString{
    NSString* rs = [NSString stringWithFormat:@"%d", arc4random_uniform(7)];
    return rs;
}

-(NSString*)fileName{
    
    //self.exam.firstName
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSString *textDate = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:self.date]];
    NSLog(@"Date %@",textDate);

    return [NSString stringWithFormat:@"%@-%@-%@-%@",textDate,self.eye,self.fixationLight,self.uuid];
}

-(NSString*)dateString{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *formattedDateString = [dateFormatter stringFromDate: self.date];
    NSLog(@"NewDateString %@",formattedDateString);
    
    return formattedDateString;
}

-(NSString*)position{
    
    NSString* position;
    
    switch (self.fixationLight.intValue) {
        case 1:
            position = @"Central";
            break;
        case 2:
            position = @"Superior";
            break;
        case 3:
            position = @"Inferior";
            break;
        case 4:
            position = [self.eye isEqualToString:@"OD"]?@"Temporal":@"Nasal";
            break;
        case 5:
            position = [self.eye isEqualToString:@"OD"]?@"Nasal":@"Temporal";
            break;
        default:
            position = @"None";
            break;
    }
    
    return position;

}

@end
