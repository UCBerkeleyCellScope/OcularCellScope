//
//  FixationViewController.h
//  OcularCellscope
//
//  Created by PJ Loury on 2/27/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EyeImage.h"
#import "EImage.h"

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
@property (nonatomic) int selectedLight;

//Delete this later
@property (strong, nonatomic) NSArray* imageArray;

@property (nonatomic, assign ) NSInteger oldSegmentedIndex;
@property (nonatomic, assign ) NSInteger actualSegmentedIndex;

@property (strong, nonatomic) EyeImage * currentEyeImage;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property NSMutableArray *fixationButtons;

@property NSMutableArray *eyeImages;

@property (strong, nonatomic) EImage* currentEImage;

@property(nonatomic, readonly, retain) UIImage *uim;



@end
