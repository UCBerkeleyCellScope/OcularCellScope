//
//  Image.h
//  OcularCellscope
//
//  Created by Chris Echanique on 3/14/14.
//  Copyright (c) 2014 UC Berkeley Ocular CellScope. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EyeImage, SelectableUIEyeImage;

@protocol AssetsLibraryDelegate
- (void)didSaveImageToLibrary:(SelectableUIEyeImage*)uiImage;
@end

@interface SelectableUIEyeImage : UIImage

@property (assign, nonatomic, getter = isSelected) BOOL selected;
@property (strong, nonatomic) EyeImage *eyeImage;
@property (weak, nonatomic) id <AssetsLibraryDelegate> delegate;

-(id)initWithData:(NSData*)imageData EyeImage:(EyeImage*)eyeImage;
- (id)initWithCGImage:(CGImageRef)imageRef EyeImage:(EyeImage*)eyeImage;
-(void) toggleSelected;
+(SelectableUIEyeImage*) imageFromEyeImage:(EyeImage*) eyeImage;
+(BOOL) containsSelectedImageInArray:(NSArray*) imageArray;
+(NSMutableArray*) selectedUIImagesFromArray:(NSArray*) imageArray;
+(NSMutableArray*) unselectedUIImagesFromArray:(NSArray*) imageArray;
+(void)saveUnselectedImagesWithImageArray:(NSArray*) images;

@end
