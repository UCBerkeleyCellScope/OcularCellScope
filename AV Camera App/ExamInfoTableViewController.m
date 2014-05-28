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
@property NSArray *physiciansArray;
@property Exam* e;

@end

@implementation ExamInfoTableViewController

@synthesize firstnameField, lastnameField, patientIDField, physiciansArray, profilePicButton;
//physicianField
@synthesize e;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [physiciansArray count];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 0.0f, 300.0f, 60.0f)]; //x and width are mutually correlated
    label.textAlignment = NSTextAlignmentCenter;
    [label setFont:[UIFont systemFontOfSize:17]];
    label.text = [physiciansArray objectAtIndex:row];
    return label;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSArray *fields = @[ self.firstnameField, self.lastnameField,
                         self.patientIDField];
                         //,self.physicianField];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    
    //[self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:fields]];
    //[self.keyboardControls setDelegate:self];
    
    self.firstnameField.delegate=self;
    self.lastnameField.delegate=self;
    self.patientIDField.delegate=self;
    //self.physicianField.delegate=self;
    
    physiciansArray = (NSArray*) @[@"Dr. Harrison", @"Dr. Copeland", @"Dr. King", @"Dr. Liu"];
    
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped)];
    [self.tableView addGestureRecognizer:gestureRecognizer];

    
    //self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    firstnameField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    lastnameField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    //physicianField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    
    
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    //Now, what if it's a video? There's no UIVideo class.
    //Video is written to disk in a temporary directory
    //When user finalizes recording, the message is sent to the delegate (this file)
    //The PATH of the video on disk is in the info dictionary
    NSURL *mediaURL = [info objectForKey:UIImagePickerControllerMediaURL];
    //Temporary is not safe, it needs to be moved
    
    if(mediaURL){
        //apparently NSURLs, not NSStrings, have paths
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum([mediaURL path]))
        {
            UISaveVideoAtPathToSavedPhotosAlbum([mediaURL path], nil, nil, nil);
            [[NSFileManager defaultManager] removeItemAtPath:[mediaURL path] error:nil];
        }
    }
    
    // // // // ///
    //e.profilePicPath= mediaURL;

    UIImage *image = [info objectForKey: UIImagePickerControllerOriginalImage];
    
    //[item setThumbnailDataFromImage:image];
    
    //Core Foundation objects.. Ref means its a Pointer
    //Core Foundation a collection of C classes
    
    [profilePicButton setImage:image forState:UIControlStateNormal];
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        // If on the phone, image picker is presented modally, so Dismiss it
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else{
        //We dismiss popovers differently
        [profilePicturePopover dismissPopoverAnimated:YES];
        profilePicturePopover =nil;
    }
}

- (IBAction)profilePicturePressed:(id)sender {
    
    if([profilePicturePopover isPopoverVisible]){
        //Because you're making a new popover you need to destroy the old one, mamke it not visible
        [profilePicturePopover dismissPopoverAnimated:YES];
        profilePicturePopover = nil;
        return;
        
    }
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    
    //[imagePicker setAllowsEditing: YES];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        NSArray *availableTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypeCamera];
        
        [imagePicker setMediaTypes: availableTypes];
        [imagePicker setSourceType: UIImagePickerControllerSourceTypeCamera]; //4
    }
    
    else{
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    
    [imagePicker setDelegate:self];//5
    
    //This was the simple modal way, now we're going for a popover
    //[self presentViewController: imagePicker animated:YES completion:nil];
    //See, we presentedViewController as a modal transition
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
        profilePicturePopover = [[UIPopoverController alloc]
                              initWithContentViewController:imagePicker ];
        
        [profilePicturePopover setDelegate:self];
        
        [profilePicturePopover presentPopoverFromBarButtonItem: sender
                                   permittedArrowDirections: UIPopoverArrowDirectionAny
                                                   animated: YES];
        
        //BTW UIPopoverControllers only work on iPad
    }
    
    else{
        [self presentViewController:imagePicker animated:YES completion: nil];
    }
    
}



- (void)backgroundTapped {
    NSLog(@"Background Tapped");
    
    [[self tableView] endEditing:YES];
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
