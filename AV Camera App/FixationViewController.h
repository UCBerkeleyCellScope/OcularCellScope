//
//  FixationViewController.h
//  OcularCellscope
//
//  Created by PJ Loury on 2/27/14.
//  Copyright (c) 2014 UC Berkeley Ocular CellScope. All rights reserved.
//
//  This view controller displays thumbnails for each of the 5 fixation spots. Clicking
//  on one of these spots allows the user to either take images or review images for that fixation spot.
//  This controller also includes a button to do on-phone stitching. For now, the stitched image is stored
//  just as any other image, but it's given fixationLight 0.
//  Note that there is only one handler for the buttons on this form (didPressBeginExam:). Each button
//  is distinguished by its tag (1-5 being the different fixation lights and 0 being the stitched image)

#import <UIKit/UIKit.h>
#import "CellScopeContext.h"
#import "CameraAppDelegate.h"
#import "ImageSelectionViewController.h"

@interface FixationViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *beginButton;
@property (strong, nonatomic) IBOutlet UIView *fixView;
@property (weak, nonatomic) IBOutlet UIButton *centerFixationButton;
@property (weak, nonatomic) IBOutlet UIButton *leftFixationButton;
@property (weak, nonatomic) IBOutlet UIButton *rightFixationButton;
@property (weak, nonatomic) IBOutlet UIButton *bottomFixationButton;
@property (weak, nonatomic) IBOutlet UIButton *topFixationButton;
@property (weak, nonatomic) IBOutlet UIButton *noFixationButton;
@property NSMutableArray *fixationButtons;
@property (weak, nonatomic) IBOutlet UIButton *autoButton;
@property (weak, nonatomic) IBOutlet UIButton *stitchButton;


@property (nonatomic) int selectedEye;
@property (nonatomic) int selectedLight;

//i'm not sure if these are still used.
@property (strong, nonatomic) EyeImage * currentEyeImage;
@property (strong, nonatomic) SelectableEyeImage* currentEImage;

@property (strong, nonatomic) NSArray* imageArray;
@property NSMutableArray *eyeImages;
@property (strong, nonatomic) NSMutableArray *passedImages;

@property(nonatomic, readonly, retain) UIImage *uim;

@property (weak, nonatomic) IBOutlet UILabel *leftLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;

- (IBAction)didPressBeginExam:(id)sender;

- (void)stitch;


@end
