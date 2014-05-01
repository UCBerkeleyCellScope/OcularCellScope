//
//  ExamInfoTableViewController.h
//  OcularCellscope
//
//  Created by PJ Loury on 4/28/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Exam.h"
#import "CellScopeContext.h"
#import "BSKeyboardControls.h"
#import "TabViewController.h"

@interface ExamInfoTableViewController : UITableViewController<UITextFieldDelegate, UITextViewDelegate, BSKeyboardControlsDelegate>
@property (weak, nonatomic) IBOutlet UITextField *firstnameField;
@property (weak, nonatomic) IBOutlet UITextField *lastnameField;
@property (weak, nonatomic) IBOutlet UITextField *patientIDField;
@property (weak, nonatomic) IBOutlet UITextField *physicianField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberField;

@end

