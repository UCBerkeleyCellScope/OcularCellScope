//
//  Image.h
//  OcularCellscope
//
//  Created by Chris Echanique on 3/14/14.
//  Copyright (c) 2014 UC Berkeley Ocular CellScope. All rights reserved.
//
//  This object represents an image that has been captured but not yet committed to core data and the camera roll.
//  It's also used during image review. This needs to be rewritten, as too many of these objects in memory will
//  crash the app. Both SelectableEyeImage and SelectableUIEyeImage need to be rethought.


#import <UIKit/UIKit.h>
@class EyeImage;

@interface SelectableEyeImage : UIImage

@property (nonatomic, strong) NSDate * date;
@property (nonatomic, strong) NSString * eye;
@property (nonatomic, strong) NSString * filePath;
@property (nonatomic) int fixationLight;
@property (nonatomic, weak) EyeImage *coreDataImage;
@property (nonatomic, strong) UIImage * thumbnail;
@property (nonatomic, strong) NSString * uuid;
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
