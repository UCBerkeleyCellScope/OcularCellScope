//
//  Image.h
//  OcularCellscope
//
//  Created by PJ Loury on 2/8/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Patient;

@interface Image : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * drName;
@property (nonatomic, retain) NSString * eyeLocation;
@property (nonatomic, retain) NSString * filePath;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) Patient *patient;

@end
