//
//  PatientsTableViewController.m
//  AV Camera App
//
//  Created by NAYA LOUMOU on 12/1/13.
//  Copyright (c) 2013 NAYA LOUMOU. All rights reserved.
//

#import "PatientsTableViewController.h"
#import "CameraAppDelegate.h"
#import "MainMenuViewController.h"
#import "CoreDataController.h"
#import "DetailViewController.h"

@implementation PatientsTableViewController

@synthesize managedObjectContext = _managedObjectContext;
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
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    CameraAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    _managedObjectContext = [appDelegate managedObjectContext];
    
    //  Grab the data
    self.patientsArray = [CoreDataController getObjectsForEntity:@"Exam" withSortKey:@"patientName" andSortAscending:YES andContext:self.managedObjectContext];
    //  Force table refresh
    [self.tableView reloadData];
    
    NSLog(@"We have %u patients in our database", [patientsArray count]);
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
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
    Exam *patient = (Exam *)[patientsArray objectAtIndex:indexPath.row];
    //[PatientInfo objectAtIndex:indexPath.row];
    
    // Fill in the cell contents
    cell.textLabel.text = [NSString stringWithFormat:@"%@, %@", patient.lastName, patient.firstName];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", patient.patientID];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.currentExam = (Exam *)[patientsArray objectAtIndex:indexPath.row];
    
    [self performSegueWithIdentifier: @"DetailSegue" sender: self];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"DetailSegue"])
    {
        DetailViewController* dvc = (DetailViewController*)[segue destinationViewController];
        
        dvc.managedObjectContext = self.managedObjectContext;
        dvc.currentExam = self.currentExam;
        
    }
}
 
// Edit the table view
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        Exam* currentCell = [patientsArray objectAtIndex:indexPath.row];
        [self.managedObjectContext deleteObject:currentCell];
        
        // Commit
        [self.managedObjectContext save:nil];
        
        //remove from the in-memory array
        [self.patientsArray removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}
@end
