//
//  Image.h
//  OcularCellscope
//
//  Created by Chris Echanique on 3/14/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import <UIKit/UIKit.h>

#define LEFT_EYE @"leftEye"
#define RIGHT_EYE @"rightEye"

#define CENTER_LIGHT 1
#define TOP_LIGHT 2
#define BOTTOM_LIGHT 3
#define LEFT_LIGHT 4
#define RIGHT_LIGHT 5
#define NO_LIGHT 6

@interface EImage : UIImage

@property (nonatomic, strong) NSDate * date;
@property (nonatomic, strong) NSString * eye;
@property (nonatomic, strong) NSString * filePath;
@property (nonatomic, assign) NSInteger * fixationLight;
@property (nonatomic, strong) UIImage * thumbnail;
@property (assign, nonatomic, getter = isSelected) BOOL selected;

+(BOOL) containsSelectedImageInArray:(NSMutableArray*) imageArray;
+(NSMutableArray*) selectedImagesFromArray:(NSMutableArray*) imageArray;
-(void) toggleSelected;

@end
