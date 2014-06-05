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
#import "CellScopeHTTPClient.h"
#import "DataGenerator.h"
#import <AssetsLibrary/AssetsLibrary.h>

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
    self.navigationController.navigationBar.hidden = YES;
    
    [[CellScopeContext sharedContext] setCurrentExam:nil ];
    [[CellScopeContext sharedContext] setSelectedEye:nil ];

    self.patientsArray = [CoreDataController getObjectsForEntity:@"Exam" withSortKey:@"lastName" andSortAscending:YES andContext:[[CellScopeContext sharedContext] managedObjectContext]];
    //  Force table refresh
    [self.tableView reloadData];
    
    NSLog(@"PatientsArray: %lu", (unsigned long)[self.patientsArray count]);
    //NSLog(@"NSResults: %lu", (unsigned long)[self.fetchedResultsController count]);
    
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
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


- (void)configureCell:(PatientTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Exam *exam = (Exam *)[self.patientsArray objectAtIndex:indexPath.row];
    
    cell.nameLabel.text = [NSString stringWithFormat:@"%@, %@", exam.lastName, exam.firstName];
    cell.idLabel.text = [NSString stringWithFormat:@"ID: %@", exam.patientID];
}


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
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
    
    /*
    //Exam* grabbedFirstExam = [patientsArray objectAtIndex:0];
    Exam* grabbedFirstExam = [_fetchedResultsController objectAtIndexPath:0];
    
    [[CellScopeContext sharedContext] setCurrentExam:grabbedFirstExam ];
    
    NSArray *images = [CoreDataController getEyeImagesForExam:grabbedFirstExam];
    
    //NSMutableArray *imagesToUpload = [NSMutableArray arrayWithArray:images];
    
    //[client uploadEyeImagesPJ:images];
    [client uploadEyeImagesFromArray:images];
    */
    
    
    //[self uploadAllImages];
    
    NSArray* array = self.fetchedResultsController.fetchedObjects;
    Exam* first = [array firstObject];
    NSArray* filesToUpload = [CoreDataController getEyeImagesForExam:first];
    if([filesToUpload count ]>0){
        client.imagesToUpload = [NSMutableArray arrayWithArray:filesToUpload];
        [client batch];
    }
}

-(void)uploadAllImages{
    
    S3manager* s3manager = [[CellScopeContext sharedContext]s3manager];
    for(Exam* exam in self.fetchedResultsController.fetchedObjects){
        NSString* bucketName = [s3manager createBucketForExam: exam];
        NSArray* eyeImages = [CoreDataController getEyeImagesForExam:exam];
        
        for(EyeImage *eyeImage in eyeImages){
            NSURL *aURL = [NSURL URLWithString: eyeImage.filePath];
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            [library assetForURL:aURL resultBlock:^(ALAsset *asset)
             {
                 ALAssetRepresentation* rep = [asset defaultRepresentation];
                 NSUInteger size = (NSUInteger)rep.size;
                 NSMutableData *imageData = [NSMutableData dataWithLength:size];
                 NSError *error;
                 [rep getBytes:imageData.mutableBytes fromOffset:0 length:size error:&error];
                 
                 NSString* imageName = [[eyeImage.eye stringByAppendingString: [eyeImage.fixationLight stringValue]]lowercaseString];
                 
                 [s3manager processGrandCentralDispatchUpload:imageData forExamBucket:bucketName andImageName:imageName];//imageName;
                 
             } failureBlock:^(NSError *error) {
                 /* handle error */
                 NSLog(@"There was an error in fetching form the Camera Roll");
             }];
        }
    }
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
    
    /**
     *  //////////////////
     */
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
