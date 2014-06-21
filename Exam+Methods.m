//
//  Exam+Methods.m
//  OcularCellscope
//
//  Created by PJ Loury on 5/2/14.
//  Copyright (c) 2014 UC Berkeley Ocular CellScope. All rights reserved.
//

#import "Exam+Methods.h"
#import "CellScopeContext.h"

@implementation Exam (Methods)


- (void)addEyeImagesObject:(EyeImage *)image {
    NSMutableOrderedSet* tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.eyeImages];
    [tempSet addObject:image];
    self.eyeImages = tempSet;
}

-(NSString*)fullName{
    NSString* fullName = [self.firstName stringByAppendingString:self.lastName];
    
    return fullName;
}

-(EyeImage*)getFirstImage{
    return [self.eyeImages firstObject];
}

-(NSString*)dateString{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *formattedDateString = [dateFormatter stringFromDate: [[CellScopeContext sharedContext]currentExam].date];
    NSLog(@"NewDateString %@",formattedDateString);
    
    return formattedDateString;
}


@end
