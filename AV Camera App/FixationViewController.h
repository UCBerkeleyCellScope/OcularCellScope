//
//  FixationViewController.h
//  OcularCellscope
//
//  Created by PJ Loury on 2/27/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CellScopeContext.h"
#import "CameraAppDelegate.h"

@interface FixationViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIView *fixView;
@property (weak, nonatomic) IBOutlet UIButton *centerFixationButton;
@property (weak, nonatomic) IBOutlet UIButton *leftFixationButton;
@property (weak, nonatomic) IBOutlet UIButton *rightFixationButton;
@property (weak, nonatomic) IBOutlet UIButton *bottomFixationButton;
@property (weak, nonatomic) IBOutlet UIButton *topFixationButton;
@property (weak, nonatomic) IBOutlet UIButton *noFixationButton;

@property (strong, nonatomic) BLEManager *bleManager;

@property (copy,nonatomic) NSString *selectedEye;
@property (nonatomic) int selectedLight;

//Delete this later
@property (strong, nonatomic) NSArray* imageArray;

@property (nonatomic, assign ) NSInteger oldSegmentedIndex;
@property (nonatomic, assign ) NSInteger actualSegmentedIndex;

@property (strong, nonatomic) EyeImage * currentEyeImage;

@property NSMutableArray *fixationButtons;

@property NSMutableArray *eyeImages;

@property (strong, nonatomic) NSMutableArray *passedImages;

@property (strong, nonatomic) EImage* currentEImage;

@property(nonatomic, readonly, retain) UIImage *uim;


@end
