//
//  Image.m
//  OcularCellscope
//
//  Created by Chris Echanique on 3/14/14.
//  Copyright (c) 2014 UC Berkeley Ocular CellScope. All rights reserved.
//

#import "SelectableUIEyeImage.h"
#import "EyeImage.h"
#import "CellScopeContext.h"
#import "Exam+Methods.h"
@import AssetsLibrary;

@implementation SelectableUIEyeImage

@synthesize eyeImage = _eyeImage;
@synthesize selected = _selected;

-(id)initWithData:(NSData*)imageData
         EyeImage:(EyeImage*)eyeImage{
    self = [super initWithData:imageData];
    
    if (self) {
        // initialize instance variables here
        _eyeImage = eyeImage;
        _selected = NO;
    }
    
    return self;
}

- (id) initWithCGImage:(CGImageRef)imageRef EyeImage:(EyeImage*)eyeImage{
    self = [super initWithCGImage:imageRef];
    
    if(self){
        _eyeImage = eyeImage;
        _selected = NO;
        
    }
    
    return self;
}

-(void)toggleSelected{
    self.selected = !self.selected;
}

+(SelectableUIEyeImage*) imageFromEyeImage:(EyeImage*) eyeImage{
    
    __block SelectableUIEyeImage *newImage = [[SelectableUIEyeImage alloc] init];
    
    NSURL *aURL = [NSURL URLWithString: eyeImage.filePath];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:aURL resultBlock:^(ALAsset *asset)
     {
         ALAssetRepresentation* rep = [asset defaultRepresentation];
         CGImageRef iref = [rep fullResolutionImage];
         newImage = [[SelectableUIEyeImage alloc] initWithCGImage:iref EyeImage:eyeImage];
     }
            failureBlock:^(NSError *error)
     {
         NSLog(@"Failed to load image from AssetLibrary");
     }];
    
    return newImage;
}

+(BOOL) containsSelectedImageInArray:(NSArray*) imageArray{
    for(SelectableUIEyeImage *image in imageArray){
        if([image isSelected]){
            return YES;
        }
    }
    return NO;
}

+(NSMutableArray*) selectedUIImagesFromArray:(NSArray*) imageArray{
    NSMutableArray *selectedImages = [[NSMutableArray alloc] init];
    for(SelectableUIEyeImage *image in imageArray){
        if([image isSelected]){
            [selectedImages addObject:image];
        }
    }
    return selectedImages;
}

+(NSMutableArray*) unselectedUIImagesFromArray:(NSArray*) imageArray{
    NSMutableArray *unselectedImages = [[NSMutableArray alloc] init];
    for(SelectableUIEyeImage *image in imageArray){
        if(!image.isSelected){
            [unselectedImages addObject:image];
        }
    }
    return unselectedImages;
}

-(void)saveImageToCameraRoll{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeImageToSavedPhotosAlbum:self.CGImage orientation:(ALAssetOrientation)[self imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error){
        if (error) {
            NSLog(@"Error writing image to photo album");
        }
        else {
            NSString *myString = [assetURL absoluteString];
            NSString *myPath = [assetURL path];
            NSLog(@"Super important! This is the file path!");
            NSLog(@"%@", myString);
            NSLog(@"%@", myPath);
            
            NSLog(@"Added image to asset library");
            
            self.eyeImage.filePath = [assetURL absoluteString];
            
            [self.delegate didSaveImageToLibrary:self];
        }
    }]; // end of completion block
    //Consider an NSNotification that you may now Segue
}

+(void)saveUnselectedImagesWithImageArray:(NSArray*) images{
    NSArray *unselectedImages = [SelectableUIEyeImage unselectedUIImagesFromArray:images];
    for(SelectableUIEyeImage *im in unselectedImages){
        EyeImage *eyeImage = im.eyeImage;
        Exam* e = [[CellScopeContext sharedContext ]currentExam ];
        [e addEyeImagesObject:eyeImage];
        [im saveImageToCameraRoll];
    }
}

@end
