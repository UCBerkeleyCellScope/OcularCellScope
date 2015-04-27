//
//  Random.h
//  OcularCellscope
//
//  Created by PJ Loury on 6/23/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//
//  We use this to generate a unique identifier for images stored in Parse, but I don't think this is necessary anymore.

#import <Foundation/Foundation.h>

@interface Random : NSObject

+(NSString*)randomStringWithLength:(int) len;

@end
