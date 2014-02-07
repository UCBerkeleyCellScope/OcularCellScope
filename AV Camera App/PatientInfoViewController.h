//
//  PatientInfoViewController.h
//  AV Camera App
//
//  Created by NAYA LOUMOU on 11/24/13.
//  Copyright (c) 2013 NAYA LOUMOU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataController.h"
#import "Patient.h"
#import "Image.h"
#import "CameraViewController.h"

@interface PatientInfoViewController : UIViewController<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *firstnameField;
@property (strong, nonatomic) IBOutlet UITextField *lastnameField;
@property (strong, nonatomic) IBOutlet UITextField *patientIDField;
@property (strong, nonatomic) IBOutlet UITextField *physicianField;
@property (strong, nonatomic) IBOutlet UITextView *notesTextView;



@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Patient* currentPatient;
@property (strong, nonatomic) Image* currentImage;

//- (IBAction)savePatientData:(id)sender;

@end


