//
//  ExamInfoTableViewController.h
//  OcularCellscope
//
//  Created by PJ Loury on 4/28/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MobileCoreServices/MobileCoreServices.h>

//#import "GTMOAuth2ViewControllerTouch.h"
//#import "GTLDrive.h"

#import "Exam.h"
#import "CellScopeContext.h"
#import "BSKeyboardControls.h"
#import "TabViewController.h"

@interface ExamInfoTableViewController : UITableViewController<UITextFieldDelegate, UITextViewDelegate, BSKeyboardControlsDelegate, UIPopoverControllerDelegate, UIImagePickerControllerDelegate,
    UINavigationControllerDelegate>
{
        UIPopoverController *profilePicturePopover;
}
@property (weak, nonatomic) IBOutlet UITextField *firstnameField;
@property (weak, nonatomic) IBOutlet UITextField *lastnameField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberField;
@property (weak, nonatomic) IBOutlet UIButton *profilePicButton;
//@property (nonatomic, retain) GTLServiceDrive *driveService;
@property (weak, nonatomic) IBOutlet UILabel *patientIDLabel;
@property (weak, nonatomic) IBOutlet UITextField *birthDayTextField;
@property (weak, nonatomic) IBOutlet UITextField *birthMonthTextField;
@property (weak, nonatomic) IBOutlet UITextField *birthYearTextField;
@property (weak, nonatomic) IBOutlet UITextField *patientIDTextField;


@property (nonatomic) S3manager *s3manager;

@end

