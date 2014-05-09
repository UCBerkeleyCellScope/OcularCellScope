//
//  ExamInfoTableViewController.m
//  OcularCellscope
//
//  Created by PJ Loury on 4/28/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import "ExamInfoTableViewController.h"
#define SYSTEM_VERSION_LESS_THAN(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@interface ExamInfoTableViewController ()
@property (nonatomic, strong) BSKeyboardControls *keyboardControls;
@property Exam* e;

@end

@implementation ExamInfoTableViewController

@synthesize firstnameField, lastnameField, patientIDField, physicianField;
@synthesize e;

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
    NSArray *fields = @[ self.firstnameField, self.lastnameField,
                         self.patientIDField, self.physicianField];
    
    //[self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:fields]];
    //[self.keyboardControls setDelegate:self];
    
    self.firstnameField.delegate=self;
    self.lastnameField.delegate=self;
    self.patientIDField.delegate=self;
    self.physicianField.delegate=self;
    
    
    //self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    firstnameField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    lastnameField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    physicianField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    e = [[CellScopeContext sharedContext]currentExam];
    
    if(e.firstName != nil && e.lastName != nil)
    {
        self.tabBarController.title = [NSString stringWithFormat:@"%@ %@",
                                       e.firstName,
                                       e.lastName];
    }
    else{
        self.tabBarController.title = @"New Exam";
        
    }
    
    self.firstnameField.text = [[CellScopeContext sharedContext]currentExam].firstName;
    self.lastnameField.text = [[CellScopeContext sharedContext]currentExam].lastName;
    self.patientIDField.text = [[CellScopeContext sharedContext]currentExam].patientID;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"Saving Exam Data");
    
    if(![firstnameField.text isEqualToString: @""])
        e.firstName = firstnameField.text;
    else e.firstName =@"FIRST";
    
    if(![lastnameField.text isEqualToString: @""])
        e.lastName = lastnameField.text;
    else e.lastName = @"LAST";
    
    if(![patientIDField.text isEqualToString: @""])
        e.patientID = patientIDField.text;
    else e.patientID = @"11111";
    
    // Commit to core data
    NSError *error;
    if (![[[CellScopeContext sharedContext] managedObjectContext] save:&error])
        NSLog(@"Failed to commit to core data: %@", [error domain]);
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"Text Field Should Return!");
    [textField resignFirstResponder];
    return NO;
}

#pragma mark -
#pragma mark Text Field Delegate

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    
    [self.keyboardControls setActiveField:textField];

    UITableViewCell *cell;
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        // Load resources for iOS 6.1 or earlier
        cell = (UITableViewCell *) textField.superview.superview;
        
    } else {
        // Load resources for iOS 7 or later
        cell = (UITableViewCell *) textField.superview.superview.superview;
        // TextField -> UITableVieCellContentView -> (in iOS 7!)ScrollView -> Cell!
    }
    [self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell:cell] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark -
#pragma mark Keyboard Controls Delegate

- (void)keyboardControls:(BSKeyboardControls *)keyboardControls selectedField:(UIView *)field inDirection:(BSKeyboardControlsDirection)direction
{
    UIView *view;
    
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        view = field.superview.superview;
    } else {
        view = field.superview.superview.superview;
    }
    
    //[self.tableView scrollRectToVisible:view.frame animated:YES];
}

- (void)keyboardControlsDonePressed:(BSKeyboardControls *)keyboardControls
{
    [self.view endEditing:YES];
}


#pragma mark - Table view data source

/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return 0;
}
*/
 
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

 
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}

 
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be redFocusEnd-orderable.
    return YES;
}

*/
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
