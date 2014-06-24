//
//  UIFont+OCSFont.m
//  OcularCellscope
//
//  Created by PJ Loury on 6/21/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import "UIFont+OCSFont.h"

@implementation UIFont (OCSFont)

+ (UIFont *)ocsFont{
    
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:17];
    return font;
}

+ (NSDictionary *)ocsFontTextAttributes{
    NSDictionary *dic =  [NSDictionary dictionaryWithObjectsAndKeys:
             [UIFont fontWithName:@"Chalkduster" size:15], NSFontAttributeName,
             [UIColor yellowColor], NSForegroundColorAttributeName,
             nil];
    return dic;
}

@end
