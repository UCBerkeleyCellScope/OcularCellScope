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
#import "DataGenerator.h"

@interface PatientsTableViewController (){
    NSArray *content;
    NSArray *indices;
}
@property CellScopeHTTPClient *client;

@end

@implementation PatientsTableViewController

@synthesize currentExam, patientsArray,client;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize managedObjectContext;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    client = [[CellScopeContext sharedContext] client];
    
    managedObjectContext = [[CellScopeContext sharedContext]managedObjectContext];
    
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    
    NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
    
    //content = [DataGenerator wordsFromLetters]; //an array containing an A-word array, a B-word array
    //indices = [content valueForKey:@"headerTitle"]; //all letters of the alphabet
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    
    [[CellScopeContext sharedContext] setCurrentExam:nil ];
    [[CellScopeContext sharedContext] setSelectedEye:nil ];

    self.patientsArray = [CoreDataController getObjectsForEntity:@"Exam" withSortKey:@"lastName" andSortAscending:YES andContext:[[CellScopeContext sharedContext] managedObjectContext]];
    //  Force table refresh
    [self.tableView reloadData];
    
    NSLog(@"PatientsArray: %lu", (unsigned long)[self.patientsArray count]);
    //NSLog(@"NSResults: %lu", (unsigned long)[self.fetchedResultsController count]);
    
    
}

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
                              initWithKey:@"lastName" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:managedObjectContext sectionNameKeyPath:@"lastName"
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //From A-Z example
    //return [content count];
    
    return [[self.fetchedResultsController sections] count];
    
    //return 1;

}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    //return [content valueForKey:@"headerTitle"];

    return [self.fetchedResultsController sectionIndexTitles];

}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    
    //return [indices indexOfObject:title];
    
    return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //return [patientsArray count];
    
    //return [[[content objectAtIndex:section] objectForKey:@"rowValues"] count] ;
    
    id  sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
    
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {
	//return [[content objectAtIndex:section] objectForKey:@"headerTitle"];
    if (section < [[self.fetchedResultsController sectionIndexTitles] count])
        return [[self.fetchedResultsController sectionIndexTitles]objectAtIndex:section];
    else
        return @"?";
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Exam *exam = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%@, %@",
                           exam.lastName, exam.firstName];
    cell.textLabel.textColor = [UIColor lightGreenColor];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", exam.patientID];
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


//INITIALIZE EXAM CELL
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    //ORIGINAL CELLSCOPE CODE
 /*
    // Set up the cell...
    Exam *exam = (Exam *)[patientsArray objectAtIndex:indexPath.row];
    
    // Fill in the cell contents
    cell.textLabel.text = [NSString stringWithFormat:@"%@, %@",
                           exam.lastName, exam.firstName];
    cell.textLabel.textColor = [UIColor lightGreenColor];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", exam.patientID];
    //cell.detailTextLabel.textColor = [UIColor blackColor];
    
    //cell.imageView = ;
    
    return cell;
    
*/
    
    //A THROUGH Z CODE
    /*
    cell.textLabel.text = [[[content objectAtIndex:indexPath.section] objectForKey:@"rowValues"]
                           objectAtIndex:indexPath.row];
    cell.textLabel.textColor = [UIColor lightGreenColor];
     */
    
    
    //FETCH RESULTS CONTROLLER CODE
    [self configureCell:cell atIndexPath:indexPath];
    
    
    return cell;
    
}

//SELECT EXAM CELL
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //THIS WAS THE OLD WAY
    //[[CellScopeContext sharedContext] setCurrentExam: (Exam *)[patientsArray objectAtIndex:indexPath.row]];
    
    //This is the New Way
    [[CellScopeContext sharedContext] setCurrentExam: (Exam *)[_fetchedResultsController objectAtIndexPath:indexPath]];
    
    
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

        //The Old Way
        //Exam* currentCell = [patientsArray objectAtIndex:indexPath.row];
        //The New Way
        Exam* currentCell = [_fetchedResultsController objectAtIndexPath:indexPath];
        
        [[[CellScopeContext sharedContext] managedObjectContext] deleteObject:currentCell];
        
        //remove from the in-memory array
        //OLD WAY
        //[self.patientsArray removeObjectAtIndex:indexPath.row];
        //The New Way
        // NOT NEEDED???
        //[[_fetchedResultsController objectAtIndexPath:indexPath] removeObjectAtIndex:indexPath.row];
        
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
     
        // Commit
        [[[CellScopeContext sharedContext] managedObjectContext] save:nil];
    }
}

- (IBAction)didPressUpload:(id)sender {
    
    
    //Exam* grabbedFirstExam = [patientsArray objectAtIndex:0];
    Exam* grabbedFirstExam = [_fetchedResultsController objectAtIndexPath:0];
    
    
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
    newExam.patientIndex = 0;
    
    [self.patientsArray addObject:newExam];
    
    //[self.fetchedResultsController addObject:newExam];
    
    NSLog(@"Before Adding Exam, %lu patients in our database", (unsigned long)[self.patientsArray count]);

    
    [self performSegueWithIdentifier: @"ExamInfoSegue" sender: self];
}

//ADDED FOR FETCHEDRESULTSCONTROLLER

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
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
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
