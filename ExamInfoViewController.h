//
//  ExamInfoViewController.h
//  OcularCellscope
//
//  Created by PJ Loury on 3/20/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Exam.h"
#import "CellScopeContext.h"
#import "BSKeyboardControls.h"

@interface ExamInfoViewController : UIViewController<UITextFieldDelegate, UITextViewDelegate, BSKeyboardControlsDelegate>
@property (strong, nonatomic) IBOutlet UITextField *firstnameField;
@property (strong, nonatomic) IBOutlet UITextField *lastnameField;
@property (strong, nonatomic) IBOutlet UITextField *patientIDField;
@property (strong, nonatomic) IBOutlet UITextField *physicianField;

@end

@interface UIColor (JPExtras)
+ (UIColor *)colorWithR:(CGFloat)red G:(CGFloat)green B:(CGFloat)blue A:(CGFloat)alpha;
@end

//.m file
@implementation UIColor (JPExtras)
+ (UIColor *)colorWithR:(CGFloat)red G:(CGFloat)green B:(CGFloat)blue A:(CGFloat)alpha {
    return [UIColor colorWithRed:(red/255.0) green:(green/255.0) blue:(blue/255.0) alpha:alpha];
}
@end
