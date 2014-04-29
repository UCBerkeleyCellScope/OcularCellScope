//
//  UIColorManager.m
//  OcularCellscope
//
//  Created by PJ Loury on 4/28/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import "UIColorManager.h"

@implementation UIColorManager

@synthesize lightGreen, mediumGreen, darkGreen;

-(id) init{
    self = [super init];
    if(self){
        lightGreen = [UIColor colorWithR:(CGFloat)26
                                       G:(CGFloat)188
                                       B:(CGFloat)156
                                       A:(CGFloat)1.0];
        mediumGreen = [UIColor colorWithR:(CGFloat)106
                                       G:(CGFloat)169
                                       B:(CGFloat)160
                                        A:(CGFloat)1.0];
        darkGreen = [UIColor colorWithR:(CGFloat)99
                                       G:(CGFloat)157
                                       B:(CGFloat)149
                                      A:(CGFloat)1.0];
    }
    return self;
}

@end
