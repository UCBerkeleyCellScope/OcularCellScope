//
//  PatientInfoViewController.m
//  AV Camera App
//
//  Created by NAYA LOUMOU on 11/24/13.
//  Copyright (c) 2013 NAYA LOUMOU. All rights reserved.
//

#import "PatientInfoViewController.h"
#import "CameraAppDelegate.h"

@implementation PatientInfoViewController


@synthesize managedObjectContext= _managedObjectContext;
@synthesize currentPatient, currentImage;
@synthesize firstnameField, lastnameField, patientIDField, physicianField, notesTextView;

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
    self.title = @"New Light Exam";
    CameraAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    _managedObjectContext = [appDelegate managedObjectContext];
	// Do any additional setup after loading the view.
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    //NSLog(@"we made it!");
    if (self.currentPatient==nil){
        // Set up a Patient entry to store in Core Data
        Exam* newPatient = (Exam*)[NSEntityDescription insertNewObjectForEntityForName:@"Patients" inManagedObjectContext:self.managedObjectContext];
        newPatient.patientID = @"";
        newPatient.patientName = @"";
        self.currentPatient = newPatient;
    }
    
    if (self.currentImage==nil)
    {
        // Set up an Image entry to store in Core Data
        EyeImage* newImage = (EyeImage*)[NSEntityDescription insertNewObjectForEntityForName:@"Images" inManagedObjectContext:self.managedObjectContext];
        newImage.drName = @"";
        self.currentImage = newImage;
    }
    
    //populate the form with data from currentPatient
    //note that we include this in viewWillAppear rather than viewDidLoad just in case downstream forms edit things
    firstnameField.text = self.currentPatient.firstName;
    lastnameField.text = self.currentPatient.lastName;
    patientIDField.text = self.currentPatient.patientID;
    physicianField.text = self.currentImage.drName;
    notesTextView.text = self.currentPatient.notes;
    
    //bring up keyboard and set focus on patient name field
    //[firstnameField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if ([self isMovingFromParentViewController])
    {
        //user pressed back, so roll back changes
        [self.managedObjectContext rollback];
    }
    else
    {
        //save changes to core data
        self.currentPatient.firstName = firstnameField.text;
        self.currentPatient.lastName = lastnameField.text;
        self.currentPatient.patientID = patientIDField.text;
        self.currentImage.drName = physicianField.text;
        self.currentPatient.notes = notesTextView.text;
        
        //save relationship
        self.currentImage.patient = self.currentPatient;
        NSLog(@"Info saved");
        
        // Commit to core data
        NSError *error;
        if (![self.managedObjectContext save:&error])
            NSLog(@"Failed to commit to core data: %@", [error domain]);
    }
}

- (BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    /*
    
    //perform final data validation before transitioning to image capture
    NSString* alertMessage = @"";
    
    if (firstnameField.text.length==0)
    {
        alertMessage = @"First name field cannot be blank.";
        [firstnameField becomeFirstResponder];
    }
    else if (lastnameField.text.length==0)
    {
        alertMessage = @"Last name field cannot be blank.";
        [lastnameField becomeFirstResponder];
    }
    else if (patientIDField.text.length==0)
    {
        alertMessage = @"Patient ID cannot be blank.";
        [patientIDField becomeFirstResponder];
    }
    else if (physicianField.text.length==0)
    {
        alertMessage = @"Physician field cannot be blank.";
        [physicianField becomeFirstResponder];
    }


    
    if ([alertMessage isEqualToString:@""])
        return YES;
    else
    {
        //throw up a popup and tell the user what's wrong
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Input Error" message:alertMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        [alert show];
        return NO;
    }
 
    */
    return YES;
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    CameraViewController* levc = (CameraViewController*)[segue destinationViewController];
    levc.managedObjectContext = self.managedObjectContext;
    levc.currentPatient = self.currentPatient;
    levc.currentImage = self.currentImage;
}
/*
//this will get called when return/next is pressed on any of the textfields
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    //get the next field (based on tag) and set focus on it
    int nextTag = [textField tag] + 1;
    UIView* nextField = [textField.superview viewWithTag:nextTag];
    if (nextField)
        [nextField becomeFirstResponder];

    return NO;
}
*/
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textViewShouldReturn:(UITextView *)textView {
    [textView resignFirstResponder];
    return NO;
}

@end
