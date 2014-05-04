//
//  UIColor+Custom.m
//  OcularCellscope
//
//  Created by PJ Loury on 4/28/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import "UIColor+Custom.h"

//.m file
@implementation UIColor (Custom)
+ (UIColor *)colorWithR:(CGFloat)red G:(CGFloat)green B:(CGFloat)blue A:(CGFloat)alpha {
    return [UIColor colorWithRed:(red/255.0) green:(green/255.0) blue:(blue/255.0) alpha:alpha];
}

+ (UIColor *)lightGreenColor{
    UIColor *lightGreenColor = [UIColor colorWithR:(CGFloat)26
                                                 G:(CGFloat)188
                                                 B:(CGFloat)156
                                                 A:(CGFloat)1.0];
    return lightGreenColor;
}

+ (UIColor *)mediumGreenColor{
    UIColor *mediumGreenColor = [UIColor colorWithR:(CGFloat)106
                                                  G:(CGFloat)169
                                                  B:(CGFloat)160
                                                  A:(CGFloat)1.0];
    return mediumGreenColor;
}

+ (UIColor *)darkGreenColor{
    UIColor *darkGreenColor = [UIColor colorWithR:(CGFloat)99
                                                G:(CGFloat)157
                                                B:(CGFloat)149
                                                A:(CGFloat)1.0];
    return darkGreenColor;
}

@end
