//
//  PatientsTableViewController.m
//  AV Camera App
//
//  Created by NAYA LOUMOU on 12/1/13.
//  Copyright (c) 2013 UC Berkeley Ocular CellScope. All rights reserved.
//

#import "PatientsTableViewController.h"
#import "PatientTableViewCell.h"
#import "CoreDataController.h"
#import "DiagnosisViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "Exam+Methods.h"
#import "Random.h"
#import <Parse/Parse.h>

@interface PatientsTableViewController (){

}

@end

@implementation PatientsTableViewController

@synthesize currentExam, patientsArray;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize managedObjectContext;

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    managedObjectContext = [[CellScopeContext sharedContext]managedObjectContext];
    
    self.navigationController.navigationBar.barTintColor = [UIColor mediumGreenColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.tableView.rowHeight = 80;
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor whiteColor],NSForegroundColorAttributeName,
                                               [UIColor blackColor], NSShadowAttributeName,
                                               nil];
    
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
    
    [self updateTable];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadProgressNotificationReceived) name:@"UploadProgressChangeNotification" object:nil];
    
}

//loads data from core data and populates the table
- (void)updateTable
{
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);  // Fail
    }
    
    [self.tableView reloadData];
}

//basic UI setup
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
    
    [[CellScopeContext sharedContext] setCurrentExam:nil];
    [[CellScopeContext sharedContext] setSelectedEye:0];
    
    self.versionLabel.text = [NSBundle mainBundle].infoDictionary[@"CFBundleVersion"];
    self.cellscopeIDLabel.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"cellscopeID"];
    
    CSLog(@"Exam list view presented", @"USER");
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

//during Parse upload, these notifications are periodically fired off. This updates the table (which includes progress indicators in each cell).
- (void) uploadProgressNotificationReceived
{
    NSLog(@"upload progress: %f, exam progress: %f",[[[CellScopeContext sharedContext] uploadManager] overallProgress],[[[CellScopeContext sharedContext] uploadManager] currentExamProgress]);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateTable];
    });
    
}

//fetches records from core data
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Exam" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    //Sort Descriptors are needed
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"date" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:managedObjectContext sectionNameKeyPath:nil
                                                   //cacheName:@"NewGuy"];
                                                    cacheName:nil];
    //a fetchedResultsController takes the REQUEST, MANAGEOBJECTCONTEXT,
    //SECTIONNAMEKEYPATH: could sort by state
    //CACHENAME- name of the cache for sections and ordering
    
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
    
}

- (void)viewDidUnload {
    self.fetchedResultsController = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id  sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

//populates a tableviewcell for a given record index
- (void)configureCell:(PatientTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {

    Exam *exam = (Exam *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSString* fn, *ln;
    

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];

    NSString *stringFromDate = [dateFormatter stringFromDate:exam.date];

    if([exam.firstName isEqualToString: @""]){
        fn = @"N/A";
    }
    else{   fn = exam.firstName;
    }
    
    if([exam.lastName isEqualToString: @""]){
        ln = @"N/A";
    }
    else{
        ln = exam.lastName;
    }
    
    if([exam.patientID isEqualToString: @""]){
        cell.patientIDLabel.text = @"N/A";
    }
    else{
        cell.patientIDLabel.text = [NSString stringWithFormat:@"%@", exam.patientID];
    }
    
    cell.nameLabel.text = [NSString stringWithFormat:@"%@, %@",ln,fn];
    cell.dateLabel.text = [NSString stringWithFormat:@"%@", stringFromDate];
    if([exam.eyeImages count] > 0)
        cell.eyeThumbnail.image = [UIImage imageWithData:[[exam.eyeImages firstObject] thumbnail]];
    else
        cell.eyeThumbnail.image = [UIImage imageNamed:@"fixation_icon_red.png"];
    
    cell.eyeThumbnail.transform = CGAffineTransformMakeRotation(M_PI);
    cell.eyeThumbnail.layer.cornerRadius = cell.eyeThumbnail.frame.size.width / 2;
    cell.eyeThumbnail.clipsToBounds = YES;
    cell.eyeThumbnail.layer.borderWidth = 2.0f;
    cell.eyeThumbnail.layer.borderColor = [UIColor grayColor].CGColor;
    cell.eyeThumbnail.contentMode = UIViewContentModeScaleAspectFill;
    
    if (exam==[[[CellScopeContext sharedContext] uploadManager] currentExam]) {
        //show the progress bar
        cell.uploadProgressBar.hidden = NO;
        cell.uploadProgressBar.progress = [[[CellScopeContext sharedContext] uploadManager] currentExamProgress];
    }
    else {
        cell.uploadProgressBar.hidden = YES;
    }
    
    cell.uploadStatusIcon.layer.cornerRadius = cell.uploadStatusIcon.frame.size.width / 2;
    cell.uploadStatusIcon.clipsToBounds = YES;
    
    if (exam.uploaded.intValue==1)
        cell.uploadStatusIcon.backgroundColor = [UIColor yellowColor];
    else if (exam.uploaded.intValue==2)
        cell.uploadStatusIcon.backgroundColor = [UIColor greenColor];
    else
        cell.uploadStatusIcon.backgroundColor = [UIColor clearColor];
}

//INITIALIZE EXAM CELL
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PatientCell";
    
    PatientTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) {
        cell = [[PatientTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    //FETCH RESULTS CONTROLLER CODE
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
    
}

//SELECT EXAM CELL
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    
    Exam *e = (Exam *)[_fetchedResultsController objectAtIndexPath:indexPath];
    [[CellScopeContext sharedContext] setCurrentExam: e];
    

    [self performSegueWithIdentifier: @"ExamInfoSegue" sender: self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

}
 
// Edit/DELETE Cell in the table view
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source

        Exam* currentCell = [_fetchedResultsController objectAtIndexPath:indexPath];
        
        [[[CellScopeContext sharedContext] managedObjectContext] deleteObject:currentCell];
        
        // Commit
        [[[CellScopeContext sharedContext] managedObjectContext] save:nil];
    }
}

- (IBAction)didPressUpload:(id)sender {
    

}

//adds a new exam and opens this in the ExamInfoTableViewController
- (IBAction)didPressAddExam:(id)sender {
    
    sender = [UIButton buttonWithType:UIButtonTypeCustom];
    [sender setTitleColor:[UIColor redColor]forState:UIControlStateNormal];
    
    self.currentExam = nil;
    Exam* newExam = (Exam*)[NSEntityDescription insertNewObjectForEntityForName:@"Exam" inManagedObjectContext:[[CellScopeContext sharedContext] managedObjectContext]];
    self.currentExam = newExam;
    [[CellScopeContext sharedContext] setCurrentExam:newExam ];
    newExam.date = [NSDate date];
    NSLog(@"Exam.dateString: %@",newExam.dateString);
    NSLog(@"Exam.date: %@",newExam.date);


    newExam.patientIndex = 0;
    newExam.studyName = @"None";
    newExam.uploaded = [NSNumber numberWithBool:NO];
    
    
    [self performSegueWithIdentifier: @"ExamInfoSegue" sender: self];
}


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(PatientTableViewCell*)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}

@end
