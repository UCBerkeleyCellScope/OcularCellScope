//
//  ImageSelectionViewController.h
//  OcularCellscope
//
//  Created by Chris Echanique on 2/19/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CellScopeContext.h"

@interface ImageSelectionViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UISlider *slider;
@property (strong, nonatomic) NSMutableArray *images; //THIS IS THE EIMAGEOBJECT
@property (strong, nonatomic) NSMutableSet *selectedImageIndices;
@property (strong, nonatomic) IBOutlet UIButton *imageViewButton;
@property (strong, nonatomic) IBOutlet UIImageView *selectedIcon;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeRightRecognizer;
@property BOOL reviewMode;
@property (strong, nonatomic) IBOutlet UICollectionView *imageCollectionView;

-(IBAction)didMoveSlider:(id)sender;
-(IBAction)didTouchUpFromSlider:(id)sender;
-(IBAction)didSelectImage:(id)sender;
-(IBAction)didPressCancel:(id)sender;
-(IBAction)didPressSave:(id)sender;
-(IBAction)didSwipeRight:(id)sender;

-(void)didPressDelete;



@end
