//
//  EyePhotoCell.h
//  OcularCellscope
//
//  Created by Chris Echanique on 5/1/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SelectableEyeImage;

@interface EyePhotoCell : UICollectionViewCell <UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIButton *selectButton;
@property (strong, nonatomic) IBOutlet UIImageView *eyeImageView;
@property (strong, nonatomic) IBOutlet UIImageView *fixationImageView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) SelectableEyeImage *eyeImage;
- (IBAction)didSelectImage:(id)sender;
- (void)updateCell;

@end
