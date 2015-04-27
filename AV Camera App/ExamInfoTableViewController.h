//
//  ExamInfoTableViewController.h
//  OcularCellscope
//
//  Created by PJ Loury on 4/28/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//
//  This view controller displays the info for a single exam.

#import <UIKit/UIKit.h>

#import <MobileCoreServices/MobileCoreServices.h>

#import "Exam.h"
#import "Exam+Methods.h"
#import "CellScopeContext.h"
#import "TabViewController.h"

@interface ExamInfoTableViewController : UITableViewController<UITextFieldDelegate, UITextViewDelegate, UIPopoverControllerDelegate, UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,UIGestureRecognizerDelegate
>
{
        UIPopoverController *profilePicturePopover; //popover messages are displayed for when the fixation display attached, etc.
}

//exam fields
@property (weak, nonatomic) IBOutlet UITextField *firstnameField;
@property (weak, nonatomic) IBOutlet UITextField *lastnameField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberField;
@property (weak, nonatomic) IBOutlet UIButton *profilePicButton;
@property (weak, nonatomic) IBOutlet UILabel *patientIDLabel;
@property (weak, nonatomic) IBOutlet UITextField *birthDayTextField;
@property (weak, nonatomic) IBOutlet UITextField *birthMonthTextField;
@property (weak, nonatomic) IBOutlet UITextField *birthYearTextField;
@property (weak, nonatomic) IBOutlet UITextField *patientIDTextField;
@property (weak, nonatomic) IBOutlet UITableViewCell *nameCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *idCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *phoneCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *dobCell;
@property (weak, nonatomic) IBOutlet UIImageView *uploadStatusIcon;
@property (weak, nonatomic) IBOutlet UITextField *researchStudyTextField;
@property (weak, nonatomic) IBOutlet UITextView *notesTextArea;

@property (nonatomic) UIGestureRecognizer* tapRecognizer;

@end

