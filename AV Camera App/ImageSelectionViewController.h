//
//  ImageSelectionViewController.h
//  OcularCellscope
//
//  Created by Chris Echanique on 2/19/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EyeImage.h"

@interface ImageSelectionViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UISlider *slider;
@property (strong, nonatomic) NSMutableArray *images; //THIS IS THE EIMAGEOBJECT
@property (strong, nonatomic) NSMutableArray *thumbnails;
@property (strong, nonatomic) NSMutableSet *selectedImageIndices;
@property (strong, nonatomic) IBOutlet UIButton *imageViewButton;
@property (strong, nonatomic) IBOutlet UIImageView *selectedIcon;


-(IBAction)didMoveSlider:(id)sender;
-(IBAction)didTouchUpFromSlider:(id)sender;
-(IBAction)didSelectImage:(id)sender;
-(IBAction)didPressCancel:(id)sender;
- (IBAction)didPressSave:(id)sender;


@property (nonatomic) int selectedLight;
@property (copy, nonatomic) NSString *selectedEye;
@property (strong, nonatomic) NSMutableArray *eyeImages; //THIS IS FOR REVIEW MODE


@end
