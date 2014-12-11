//
//  EyeImage.h
//  OcularCellscope
//
//  Created by PJ Loury on 6/21/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Exam;

@interface EyeImage : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * drName;
@property (nonatomic, retain) NSString * eye;
@property (nonatomic, retain) NSString * filePath;
@property (nonatomic, retain) NSNumber * fixationLight;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) NSNumber * uploaded;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSString * illumination;
@property (nonatomic, retain) NSString * focus;
@property (nonatomic, retain) NSString * exposure;
@property (nonatomic, retain) NSString * iso;
@property (nonatomic, retain) NSString * whiteBalance;
@property (nonatomic, retain) NSString * flashDuration;
@property (nonatomic, retain) NSString * flashDelay;
@property (nonatomic, retain) NSString * appVersion;

@property (nonatomic, retain) Exam *exam;

@end
