//
//  ExamInfoViewController.m
//  OcularCellscope
//
//  Created by PJ Loury on 3/20/14.
//  Copyright (c) 2014 UC Berkeley Ocular CellScope. All rights reserved.
//

#import "ExamInfoViewController.h"
#define SYSTEM_VERSION_LESS_THAN(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@interface ExamInfoViewController ()
@property (nonatomic, strong) BSKeyboardControls *keyboardControls;
@end

@implementation ExamInfoViewController

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
    
    //CameraAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    
    
    firstnameField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    lastnameField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    physicianField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    
    [[UITabBar appearance] setTintColor: [UIColor colorWithR:26 G:188 B:156 A:1]];
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([[CellScopeContext sharedContext] currentExam]==nil){
        
        NSLog(@"New Exam Object Created");
        self.tabBarController.title = @"New Exam";
        
        Exam* newExam = (Exam*)[NSEntityDescription insertNewObjectForEntityForName:@"Exam" inManagedObjectContext:[[CellScopeContext sharedContext] managedObjectContext]];
        newExam.firstName =@"FIRST";
        newExam.lastName = @"LAST";
        newExam.patientID = @"11111";
        newExam.patientName = @"AAA";
        
        [[CellScopeContext sharedContext] setCurrentExam:newExam];
    
    }
    
    else {
        //self.title = @"@% @%", currentExam.firstName, currentExam.lastName;
        if([[CellScopeContext sharedContext]currentExam].firstName != nil &&
           [[CellScopeContext sharedContext]currentExam].lastName != nil){
            self.tabBarController.title = [NSString stringWithFormat:@"%@ %@",
            [[CellScopeContext sharedContext]currentExam].firstName,
            [[CellScopeContext sharedContext]currentExam].lastName];
        }
        
        
        self.firstnameField.text = [[CellScopeContext sharedContext]currentExam].firstName;
        self.lastnameField.text = [[CellScopeContext sharedContext]currentExam].lastName;
        self.patientIDField.text = [[CellScopeContext sharedContext]currentExam].patientID;

        
        
    }

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
    //save changes to core data
    //self.currentExam.firstName = firstnameField.text;
    //self.currentExam.lastName = lastnameField.text;
    //self.currentExam.patientID = patientIDField.text;
    if(![firstnameField.text isEqualToString: @""])
    [[CellScopeContext sharedContext]currentExam].firstName = firstnameField.text;
    if(![lastnameField.text isEqualToString: @""])
    [[CellScopeContext sharedContext]currentExam].lastName = lastnameField.text;
    if(![patientIDField.text isEqualToString: @""])
    [[CellScopeContext sharedContext]currentExam].patientID = patientIDField.text;
    
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
