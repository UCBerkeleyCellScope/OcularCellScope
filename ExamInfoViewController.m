//
//  ExamInfoViewController.m
//  OcularCellscope
//
//  Created by PJ Loury on 3/20/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import "ExamInfoViewController.h"

@interface ExamInfoViewController ()

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
    [[UITabBar appearance] setTintColor: [UIColor colorWithR:26 G:188 B:156 A:1]];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (self.currentExam == nil){
        
        [super viewDidLoad];
        Exam* newExam = (Exam*)[NSEntityDescription insertNewObjectForEntityForName:@"Exam" inManagedObjectContext:[[CellScopeContext sharedContext] managedObjectContext]];
        newExam.patientID = @"";
        newExam.patientName = @"";
        
        [[CellScopeContext sharedContext] setCurrentExam:newExam];
    
    }
    
    firstnameField.text = self.currentExam.firstName;
    lastnameField.text = self.currentExam.lastName;
    patientIDField.text = self.currentExam.patientID;

}


- (void)viewWillDisappear:(BOOL)animated
{
    if ([self isMovingFromParentViewController])
    {
        //user pressed back, so roll back changes
        [[[CellScopeContext sharedContext] managedObjectContext] rollback];
    }
    else
    {
        //save changes to core data
        self.currentExam.firstName = firstnameField.text;
        self.currentExam.lastName = lastnameField.text;
        self.currentExam.patientID = patientIDField.text;
        
        
        // Commit to core data
        NSError *error;
        if (![[[CellScopeContext sharedContext] managedObjectContext] save:&error])
            NSLog(@"Failed to commit to core data: %@", [error domain]);
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
