//
//  ExamInfoViewController.h
//  OcularCellscope
//
//  Created by PJ Loury on 3/20/14.
//  Copyright (c) 2014 UC Berkeley Ocular CellScope. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Exam.h"
#import "CellScopeContext.h"
#import "BSKeyboardControls.h"
#import "TabViewController.h"

@interface ExamInfoViewController : UIViewController<UITextFieldDelegate, UITextViewDelegate, BSKeyboardControlsDelegate>
@property (strong, nonatomic) IBOutlet UITextField *firstnameField;
@property (strong, nonatomic) IBOutlet UITextField *lastnameField;
@property (strong, nonatomic) IBOutlet UITextField *patientIDField;
@property (strong, nonatomic) IBOutlet UITextField *physicianField;

@end
