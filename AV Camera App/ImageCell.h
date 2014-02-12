//
//  ImageCell.h
//  AV Camera App
//
//  Created by PJ Loury on 1/31/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "Image.h"

@interface ImageCell : UICollectionViewCell //as opposed to UICollectionReusableView

//@property(nonatomic, strong) ALAsset *asset;

@property (nonatomic, strong) Image *image;

@property (nonatomic, strong) IBOutlet UIImageView *imageView;



@end
