//
//  Image.h
//  OcularCellscope
//
//  Created by Chris Echanique on 3/14/14.
//  Copyright (c) 2014 UC Berkeley Ocular CellScope. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EyeImage;

@interface SelectableEyeImage : UIImage

@property (nonatomic, strong) NSDate * date;
@property (nonatomic, strong) NSString * eye;
@property (nonatomic, strong) NSString * filePath;
@property (nonatomic) int fixationLight;
@property (nonatomic, weak) EyeImage *coreDataImage;
@property (nonatomic, strong) UIImage * thumbnail;
@property (assign, nonatomic, getter = isSelected) BOOL selected;

-(id) initWithData:(NSData *)data
              date:(NSDate*) date
               eye:(NSString*) eye
     fixationLight:(int) fixationLight;

- (id) initWithUIImage: (UIImage*) image
                  date:(NSDate*) date
                   eye:(NSString*) eye
         fixationLight: (int) fixationLight
             thumbnail:(UIImage*) thumbnail;

+(BOOL) containsSelectedImageInArray:(NSMutableArray*) imageArray;
+(NSMutableArray*) selectedImagesFromArray:(NSMutableArray*) imageArray;
-(void) toggleSelected;

@end
