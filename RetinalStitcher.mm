//
//  RetinalStitcher.m
//  Ocular Cellscope
//
//  Created by Frankie Myers on 3/7/15.
//  Copyright (c) 2015 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "RetinalStitcher.h"
#import <opencv2/opencv.hpp>
#import <opencv2/stitching/stitcher.hpp>

@implementation RetinalStitcher

using namespace cv;

- (UIImage*) stitch:(UIImage*)im1
{
    Mat m1;
    
    vector<Mat> imgs;
    imgs.push_back(m1);
    
    Mat pano;
    Stitcher stitcher = Stitcher::createDefault(true);
    stitcher.stitch(imgs, pano);
    
    UIImage* result;
    
    return result;
    
}

@end
