//
//  PatientsTableViewController.m
//  AV Camera App
//
//  Created by NAYA LOUMOU on 12/1/13.
//  Copyright (c) 2013 UC Berkeley Ocular CellScope. All rights reserved.
//

#import "PatientsTableViewController.h"
#import "CoreDataController.h"
#import "DiagnosisViewController.h"
#import "CellScopeHTTPClient.h"

@interface PatientsTableViewController ()
@property CellScopeHTTPClient *client;
@end

@implementation PatientsTableViewController

@synthesize currentExam, patientsArray,client;

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
    
    client = [[CellScopeContext sharedContext] client];
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

//INITIALIZE EXAM CELL
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
    cell.contentView.backgroundColor = [UIColor darkGreenColor];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@, %@",
                           exam.lastName, exam.firstName];
    cell.textLabel.textColor = [UIColor lightGreenColor];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", exam.patientID];
    cell.textLabel.textColor = [UIColor whiteColor];
    
    //cell.imageView = ;
    
    return cell;
}

//SELECT EXAM CELL
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [[CellScopeContext sharedContext] setCurrentExam: (Exam *)[patientsArray objectAtIndex:indexPath.row]];
    [self performSegueWithIdentifier: @"ExamInfoSegue" sender: self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    DiagnosisViewController *dvc = [[DiagnosisViewController alloc]init];
//    UITabBarController *tbc = [segue destinationViewController];
//    CellScopeHTTPClient *c = [CellScopeHTTPClient sharedCellScopeHTTPClient];
//    c.delegate = dvc;
//    
//    
//    dvc = (DiagnosisViewController*)[[tbc customizableViewControllers] objectAtIndex:1];
}
 
// Edit/DELETE Cell in the table view
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

//ADD EXAM
- (IBAction)didPressUpload:(id)sender {
    Exam* grabbedFirstExam = [patientsArray objectAtIndex:0];
    [[CellScopeContext sharedContext] setCurrentExam:grabbedFirstExam ];
    
    NSArray *images = [CoreDataController getEyeImagesForExam:grabbedFirstExam];
    
    //NSMutableArray *imagesToUpload = [NSMutableArray arrayWithArray:images];
    
    //[client uploadEyeImagesPJ:images];
    [client uploadEyeImagesFromArray:images];
}

-(void)cellScopeHTTPClient:(CellScopeHTTPClient *)client didUploadEyeImage:(id)eyeImage{
    
}


- (IBAction)didPressAddExam:(id)sender {
    self.currentExam = nil;
    Exam* newExam = (Exam*)[NSEntityDescription insertNewObjectForEntityForName:@"Exam" inManagedObjectContext:[[CellScopeContext sharedContext] managedObjectContext]];
    newExam.date = [NSDate date];
    [[CellScopeContext sharedContext] setCurrentExam:newExam ];
    self.currentExam = newExam;
    
    
    [self.patientsArray addObject:newExam];
    
    NSLog(@"B4 TRANSITION We have %lu patients in our database", (unsigned long)[self.patientsArray count]);

    
    [self performSegueWithIdentifier: @"ExamInfoSegue" sender: self];
}
@end
