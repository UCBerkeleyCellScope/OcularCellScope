//
//  FixationViewController.h
//  OcularCellscope
//
//  Created by PJ Loury on 2/27/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EyeImage.h"

@interface FixationViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *centerFixationButton;
@property (weak, nonatomic) IBOutlet UIButton *leftFixationButton;
@property (weak, nonatomic) IBOutlet UIButton *rightFixationButton;
@property (weak, nonatomic) IBOutlet UIButton *bottomFixationButton;
@property (weak, nonatomic) IBOutlet UIButton *topFixationButton;
@property (weak, nonatomic) IBOutlet UIButton *noFixationButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

//@property (copy, nonatomic) NSString *selectedEye;
@property (copy,nonatomic) NSString *selectedEye;
@property (nonatomic) NSInteger const selectedLight;

//Delete this later
@property (strong, nonatomic) NSArray* imageArray;

@property (nonatomic, assign ) NSInteger oldSegmentedIndex;
@property (nonatomic, assign ) NSInteger actualSegmentedIndex;

@property (strong, nonatomic) EyeImage * leftEyeImage;
@property (strong, nonatomic) EyeImage * rightEyeImage;
@property (strong, nonatomic) EyeImage * topEyeImage;
@property (strong, nonatomic) EyeImage * bottomEyeImage;
@property (strong, nonatomic) EyeImage * centerEyeImage;
@property (strong, nonatomic) EyeImage * noneEyeImage;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property NSMutableArray *fixationButtons;

@property NSMutableArray *eyeImages;

//@property(nonatomic, readonly, retain) UIImage *currentImage;



@end
