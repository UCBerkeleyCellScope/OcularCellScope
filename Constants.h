//
//  Constants.h
//  OcularCellscope
//
//  Created by PJ Loury on 2/28/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LEFT_EYE @"leftEye"
#define RIGHT_EYE @"rightEye"

#define CENTER_LIGHT 1
#define TOP_LIGHT 2
#define BOTTOM_LIGHT 3
#define LEFT_LIGHT 4
#define RIGHT_LIGHT 5
#define NO_LIGHT 6

#define flashNumber 9
#define farRedLight 10
#define flashNoPingBack 11

//static NSString * const BaseURLString = @"http://www.raywenderlich.com/demos/weather_sample/";
//static NSString * const BaseURLString = @"http://ec2-54-186-247-188.us-west-2.compute.amazonaws.com/";
//This needs to be changed
static NSString * const BaseURLString = @"http://warm-dawn-6399.herokuapp.com/";

@interface Constants : NSObject


@end


