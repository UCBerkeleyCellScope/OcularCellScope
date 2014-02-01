//
//  ImageCell.h
//  AV Camera App
//
//  Created by PJ Loury on 1/31/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ImageCell : UICollectionViewCell

@property(nonatomic, strong) ALAsset *asset;

@end
