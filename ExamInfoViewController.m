//
//  ExamInfoViewController.m
//  OcularCellscope
//
//  Created by PJ Loury on 3/20/14.
//  Copyright (c) 2014 UC Berkeley Ocular CellScope. All rights reserved.
//

#import "ExamInfoViewController.h"
#import "CellScopeHTTPClient.h"
#define SYSTEM_VERSION_LESS_THAN(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)


@interface ExamInfoViewController ()
@property (nonatomic, strong) BSKeyboardControls *keyboardControls;
@property Exam* e;
@end

@implementation ExamInfoViewController

@synthesize e;
@synthesize firstnameField, lastnameField, patientIDField, physicianField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    NSArray *fields = @[ self.firstnameField, self.lastnameField,
                         self.patientIDField, self.physicianField];
    
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:fields]];
    [self.keyboardControls setDelegate:self];
    
    
    firstnameField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    lastnameField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    physicianField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    e = [[CellScopeContext sharedContext]currentExam];
    
    if(e.firstName != nil && e.lastName != nil)
    {
        self.tabBarController.title = [NSString stringWithFormat:@"%@ %@",
        e.firstName,
        e.lastName];
    }
    else{
        self.tabBarController.title = @"New Exam";

    }
    
    self.firstnameField.text = [[CellScopeContext sharedContext]currentExam].firstName;
    self.lastnameField.text = [[CellScopeContext sharedContext]currentExam].lastName;
    self.patientIDField.text = [[[CellScopeContext sharedContext]currentExam].patientID stringValue];
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    if (![parent isEqual:self.parentViewController]) {
        NSLog(@"Back pressed");
        
    }
}


- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"Saving Exam Data");

    if(![firstnameField.text isEqualToString: @""])
        e.firstName = firstnameField.text;
    else e.firstName =@"FIRST";
    
    if(![lastnameField.text isEqualToString: @""])
        e.lastName = lastnameField.text;
    else e.lastName = @"LAST";

    if(![patientIDField.text isEqualToString: @""])
        e.patientID = patientIDField.text;
    else e.patientID = @"11111";
    
    // Commit to core data
    NSError *error;
    if (![[[CellScopeContext sharedContext] managedObjectContext] save:&error])
        NSLog(@"Failed to commit to core data: %@", [error domain]);
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"Text Field Should Return!");
    [textField resignFirstResponder];
    return NO;
}

#pragma mark -
#pragma mark Text Field Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.keyboardControls setActiveField:textField];
}

#pragma mark -
#pragma mark Text View Delegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self.keyboardControls setActiveField:textView];
}

#pragma mark -
#pragma mark Keyboard Controls Delegate

- (void)keyboardControls:(BSKeyboardControls *)keyboardControls selectedField:(UIView *)field inDirection:(BSKeyboardControlsDirection)direction
{
    UIView *view;
    
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        view = field.superview.superview;
    } else {
        view = field.superview.superview.superview;
    }
    
    //[self.tableView scrollRectToVisible:view.frame animated:YES];
}

- (void)keyboardControlsDonePressed:(BSKeyboardControls *)keyboardControls
{
    [self.view endEditing:YES];
}




@end
