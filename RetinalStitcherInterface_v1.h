//
//  RetinalStitcherInterface.h
//  Ocular Cellscope
//
//  Created by Frankie Myers on 3/7/15.
//  Copyright (c) 2015 UC Berkeley Fletcher Lab. All rights reserved.
//

//#import <Foundation/Foundation.h>


@interface RetinalStitcherInterface : NSObject

//set these images before calling stitch:
@property (strong, nonatomic) UIImage* centerImage;
@property (strong, nonatomic) UIImage* topImage;
@property (strong, nonatomic) UIImage* bottomImage;
@property (strong, nonatomic) UIImage* leftImage;
@property (strong, nonatomic) UIImage* rightImage;

// This function returns a stitched image as a UIImage object
// To run, first set all the constituent images (which are properties of the RetinalStitcherInterface class), then call this method.
- (UIImage*) stitch;

@end
