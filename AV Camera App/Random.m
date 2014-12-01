//
//  Random.m
//  OcularCellscope
//
//  Created by PJ Loury on 6/23/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import "Random.h"

@implementation Random

static NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

+(NSString*)randomStringWithLength:(int) len {
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    
    return randomString;
    
}


@end
