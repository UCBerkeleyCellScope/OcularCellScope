//
//  EyePhotoViewController.h
//  OcularCellscope
//
//  Created by Chris Echanique on 5/1/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EyePhotoViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property BOOL reviewMode;
@property (strong, nonatomic) NSMutableArray *imagesArray;
- (IBAction)didPressSave:(id)sender;
- (IBAction)didPressCancel:(id)sender;

@end
