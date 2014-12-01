//
//  Constants.h
//  OcularCellscope
//
//  Created by PJ Loury on 2/28/14.
//  Copyright (c) 2014 UC Berkeley Ocular CellScope. All rights reserved.
//

#import <Foundation/Foundation.h>

#define OD_EYE 1
#define OS_EYE 2
#define farRedLight 9
#define flashNumber 10

//static NSString * const BaseURLString = @"http://www.raywenderlich.com/demos/weather_sample/";
//static NSString * const BaseURLString = @"http://ec2-54-186-247-188.us-west-2.compute.amazonaws.com/";
//This needs to be changed

#define ACCESS_KEY_ID          @"BBBBBBBBB"
#define SECRET_KEY             @"CCCCCCCCC"

// Constants for the Bucket and Object name.
#define PICTURE_BUCKET         @"picture-bucket"
#define PICTURE_NAME           @"NameOfThePicture"


#define CREDENTIALS_ERROR_TITLE    @"Missing Credentials"
#define CREDENTIALS_ERROR_MESSAGE  @"AWS Credentials not configured correctly.  Please review the README file."


@interface Constants : NSObject

/**
 * Utility method to create a bucket name using the Access Key Id.  This will help ensure uniqueness.
 */
+(NSString *)pictureBucket;


@end


