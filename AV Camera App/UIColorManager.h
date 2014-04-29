//
//  UIColorManager.h
//  OcularCellscope
//
//  Created by PJ Loury on 4/28/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIColorManager : NSObject
@property UIColor *lightGreen;
@property UIColor *mediumGreen;
@property UIColor *darkGreen;

@end

@interface UIColor (JPExtras)
+ (UIColor *)colorWithR:(CGFloat)red G:(CGFloat)green B:(CGFloat)blue A:(CGFloat)alpha;
//+ (UIColor *)lightGreen;
//+ (UIColor *)mediumGreen;
//+ (UIColor *)darkGreen;
@end

//.m file
@implementation UIColor (JPExtras)
+ (UIColor *)colorWithR:(CGFloat)red G:(CGFloat)green B:(CGFloat)blue A:(CGFloat)alpha {
    return [UIColor colorWithRed:(red/255.0) green:(green/255.0) blue:(blue/255.0) alpha:alpha];
}

/*
+ (UIColor *)lightGreen{
    return lightGreen;
}
+ (UIColor *)mediumGreen{
    return mediumGreen;
}
+ (UIColor *)darkGreen{
    return darkGreen;
}
*/
@end
