//
//  FixationViewController.h
//  OcularCellscope
//
//  Created by PJ Loury on 2/27/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@interface FixationViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *centerFixationButton;
@property (weak, nonatomic) IBOutlet UIButton *leftFixationButton;
@property (weak, nonatomic) IBOutlet UIButton *rightFixationButton;
@property (weak, nonatomic) IBOutlet UIButton *bottomFixationButton;
@property (weak, nonatomic) IBOutlet UIButton *topFixationButton;
@property (weak, nonatomic) IBOutlet UIButton *noFixationButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (copy, nonatomic) NSString *selectedEye;
@property (copy, nonatomic) NSString *selectedLight;

@property (nonatomic, assign ) NSInteger oldSegmentedIndex;
@property (nonatomic, assign ) NSInteger actualSegmentedIndex;

@end
