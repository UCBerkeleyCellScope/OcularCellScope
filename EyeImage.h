//
//  Images.h
//  OcularCellscope
//
//  Created by PJ Loury on 2/28/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface EyeImage : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * drName;
@property (nonatomic, retain) NSString * eye;
@property (nonatomic, retain) NSString * filePath;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) NSString * fixationLight;

@end
