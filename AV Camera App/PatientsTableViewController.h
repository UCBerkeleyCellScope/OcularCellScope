//
//  PatientsTableViewController.h
//  AV Camera App
//
//  Created by NAYA LOUMOU on 12/1/13.
//  Copyright (c) 2013 UC Berkeley Ocular CellScope. All rights reserved.
//
//  This view controller displays a listing of all the exams currently on the phone.

#import <UIKit/UIKit.h>
#import "CellScopeContext.h"

@interface PatientsTableViewController : UIViewController<NSFetchedResultsControllerDelegate, UITableViewDelegate>

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *patientsArray;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellscopeIDLabel;

@property (nonatomic, strong) Exam *currentExam;

- (IBAction)didPressUpload:(id)sender;
- (IBAction)didPressAddExam:(id)sender;

@end
