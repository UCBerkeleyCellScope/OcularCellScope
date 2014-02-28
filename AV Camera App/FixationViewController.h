//
//  FixationViewController.h
//  OcularCellscope
//
//  Created by PJ Loury on 2/27/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FixationViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *centerFixationButton;
@property (weak, nonatomic) IBOutlet UIButton *leftFixationButton;
@property (weak, nonatomic) IBOutlet UIButton *rightFixationButton;
@property (weak, nonatomic) IBOutlet UIButton *bottomFixationButton;
@property (weak, nonatomic) IBOutlet UIButton *topFixationButton;
@property (weak, nonatomic) IBOutlet UIButton *noFixationButton;

@property (copy, nonatomic) NSString *currentEye;


@end
