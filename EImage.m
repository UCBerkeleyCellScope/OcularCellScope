//
//  Image.m
//  OcularCellscope
//
//  Created by Chris Echanique on 3/14/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import "EImage.h"

@implementation EImage

@synthesize date = _date;
@synthesize eye = _eye;
@synthesize filePath = _filePath;
@synthesize fixationLight = _fixationLight;
@synthesize thumbnail = _thumbnail;
@synthesize selected = _selected;

- (id)initWithData:(NSData*)imageData date:(NSDate*) date eye:(NSString*) eye fixationLight:(NSInteger*) fixationLight{
    self = [super initWithData:imageData];
    
    if (self) {
        // initialize instance variables here
        _date = date;
        _eye = eye;
        _fixationLight = fixationLight;
        _selected = NO;
    }
    
    return self;
}

-(void)toggleSelected{
    self.selected = !self.selected;
}

+(BOOL) containsSelectedImageInArray:(NSMutableArray*) imageArray{
    for(EImage *image in imageArray){
        if([image isSelected]){
            return YES;
        }
    }
    return NO;
}

+(NSMutableArray*) selectedImagesFromArray:(NSMutableArray*) imageArray{
    NSMutableArray *selectedImages = [[NSMutableArray alloc] init];
    for(EImage *image in imageArray){
        if([image isSelected]){
            [selectedImages addObject:image];
        }
    }
    return selectedImages;
}

@end
