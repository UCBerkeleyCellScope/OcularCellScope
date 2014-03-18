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
@property(strong, nonatomic) NSMutableArray *images;
@property(strong, nonatomic) NSMutableArray *thumbnails;
@property(strong, nonatomic) NSMutableArray *eyeImages;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *discardButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;


@property(strong, nonatomic) EyeImage * currentEyeImage;

- (IBAction)didMoveSlider:(id)sender;
- (IBAction)didPressSaveButton:(id)sender;


@property (nonatomic) NSInteger const selectedLight;
@property (copy, nonatomic) NSString *selectedEye;

@end
