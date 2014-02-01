//
//  DetailViewController.h
//  AV Camera App
//
//  Created by Chris Echanique on 12/8/13.
//  Copyright (c) 2013 NAYA LOUMOU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Images.h"
#import "Patients.h"

@interface DetailViewController : UIViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Patients* currentPatient;
@property (strong, nonatomic) IBOutlet UITextField *firstnameField;
@property (strong, nonatomic) IBOutlet UITextField *lastnameField;
@property (strong, nonatomic) IBOutlet UITextField *patientIDField;
@property (strong, nonatomic) IBOutlet UITextField *physicianField;
@property (strong, nonatomic) IBOutlet UITextView *notesField;
@property (strong, nonatomic) IBOutlet UIImageView *lefteyeView;
@property (strong, nonatomic) IBOutlet UIImageView *righteyeView;


@end
