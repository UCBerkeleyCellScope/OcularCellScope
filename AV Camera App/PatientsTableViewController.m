//
//  PatientsTableViewController.m
//  AV Camera App
//
//  Created by NAYA LOUMOU on 12/1/13.
//  Copyright (c) 2013 NAYA LOUMOU. All rights reserved.
//

#import "PatientsTableViewController.h"
#import "MainMenuViewController.h"
#import "CoreDataController.h"
#import "DetailViewController.h"

@implementation PatientsTableViewController

@synthesize currentExam, patientsArray;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    
    [[CellScopeContext sharedContext] setCurrentExam:nil ];
    [[CellScopeContext sharedContext] setSelectedEye:nil ];

    self.patientsArray = [CoreDataController getObjectsForEntity:@"Exam" withSortKey:@"patientName" andSortAscending:YES andContext:[[CellScopeContext sharedContext] managedObjectContext]];
    //  Force table refresh
    [self.tableView reloadData];
    
    NSLog(@"We have %lu patients in our database", (unsigned long)[self.patientsArray count]);
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [patientsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    // Set up the cell...
    Exam *exam = (Exam *)[patientsArray objectAtIndex:indexPath.row];
    //[PatientInfo objectAtIndex:indexPath.row];
    
    // Fill in the cell contents
    cell.textLabel.text = [NSString stringWithFormat:@"%@, %@",
                           
                           exam.lastName, exam.firstName];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", exam.patientID];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //self.currentExam = ;
    
    [[CellScopeContext sharedContext] setCurrentExam: (Exam *)[patientsArray objectAtIndex:indexPath.row]];
    
    [self performSegueWithIdentifier: @"ExamInfoSegue" sender: self];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

}
 
// Edit the table view
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        Exam* currentCell = [patientsArray objectAtIndex:indexPath.row];
        [[[CellScopeContext sharedContext] managedObjectContext] deleteObject:currentCell];
        
        
        //remove from the in-memory array
        [self.patientsArray removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
     
        // Commit
        [[[CellScopeContext sharedContext] managedObjectContext] save:nil];
        
    }
}
- (IBAction)didPressAddExam:(id)sender {
    
    self.currentExam = nil;
    
    Exam* newExam = (Exam*)[NSEntityDescription insertNewObjectForEntityForName:@"Exam" inManagedObjectContext:[[CellScopeContext sharedContext] managedObjectContext]];
    [[CellScopeContext sharedContext] setCurrentExam:newExam ];

    [self performSegueWithIdentifier: @"AddExamSegue" sender: self];


    
}
@end
