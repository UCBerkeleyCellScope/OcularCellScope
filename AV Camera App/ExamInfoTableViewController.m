//
//  ExamInfoTableViewController.m
//  OcularCellscope
//
//  Created by PJ Loury on 4/28/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import "ExamInfoTableViewController.h"
#define SYSTEM_VERSION_LESS_THAN(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

static NSString *const kKeychainItemName = @"Google Drive Quickstart";
static NSString *const kClientID = @"1081725371247-qltk4n42c8j8fkciuct6qt9gn50n4h21.apps.googleusercontent.com";
static NSString *const kClientSecret = @"xU778b5pej9hfVdMXioH416j";


@interface ExamInfoTableViewController ()
@property (nonatomic, strong) BSKeyboardControls *keyboardControls;

@property Exam* e;

@end

@implementation ExamInfoTableViewController

@synthesize firstnameField, lastnameField, profilePicButton, patientIDLabel, phoneNumberField;
@synthesize birthDayTextField,birthMonthTextField,birthYearTextField;
@synthesize driveService;
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

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if(indexPath) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.driveService = [[GTLServiceDrive alloc] init];
    self.driveService.authorizer = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                                                         clientID:kClientID
                                                                                     clientSecret:kClientSecret];
    
    NSArray *fields = @[ self.firstnameField, self.lastnameField,
                         ];
                         //,self.physicianField];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    
    //[self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:fields]];
    //[self.keyboardControls setDelegate:self];
    
    self.firstnameField.delegate=self;
    self.lastnameField.delegate=self;
    self.phoneNumberField.delegate=self;
       
   
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
    
    [self uploadPhoto:image];
    
    
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
    [profilePicButton setHighlighted: NO];
    
}

- (IBAction)didPressProfilePicture:(id)sender {
    
    [profilePicButton setHighlighted: YES];
    
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
        
        NSLog(@"SHOULD ONLY SHOW ON IPAD)");
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
    [super viewWillAppear:animated];
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView reloadData];
    if(indexPath) {
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    
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
    
    self.firstnameField.text = e.firstName;
    self.lastnameField.text = e.lastName;
    
    NSLog(e.patientID.description);
    
    if( e.patientID == 0){ // indicates a new exam
        e.patientID = [[NSUserDefaults standardUserDefaults] objectForKey:@"patientNumberIndex"];
        int value = [e.patientID intValue];
        value=value+1;
        
        [[NSUserDefaults standardUserDefaults] setValue: [NSNumber numberWithInt:value] forKey:@"patientNumberIndex" ];
        NSLog(@"%d",value);
        
        e.patientID = [NSNumber numberWithInt: value];
        //self.patientIDField.text = [e.patientID stringValue];
        self.patientIDLabel.text = [e.patientID stringValue];
    }
    else{
        //self.patientIDField.text = [e.patientID stringValue];
        self.patientIDLabel.text = [e.patientID stringValue];
        
    }
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
    
    e.phoneNumber = phoneNumberField.text;
    
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

// Restrict phone textField to format 123-456-7890
- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string {
    if (textField==phoneNumberField){
        // All digits entered
        if (range.location == 14) {
            return NO;
        }
        
        // Reject appending non-digit characters
        if (range.length == 0 &&
            ![[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[string characterAtIndex:0]]) {
            return NO;
        }
        
        // Auto-add hyphen and parentheses
        if (range.length == 0 && range.location == 3 &&![[textField.text substringToIndex:1] isEqualToString:@"("]) {
            textField.text = [NSString stringWithFormat:@"(%@)-%@", textField.text,string];
            return NO;
        }
        if (range.length == 0 && range.location == 4 &&[[textField.text substringToIndex:1] isEqualToString:@"("]) {
            textField.text = [NSString stringWithFormat:@"%@)-%@", textField.text,string];
            return NO;
        }
        
        // Auto-add 2nd hyphen
        if (range.length == 0 && range.location == 9) {
            textField.text = [NSString stringWithFormat:@"%@-%@", textField.text, string];
            return NO;
        }
        
        // Delete hyphen and parentheses when deleting its trailing digit
        if (range.length == 1 &&
            (range.location == 10 || range.location == 1)){
            range.location--;
            range.length = 2;
            textField.text = [textField.text stringByReplacingCharactersInRange:range withString:@""];
            return NO;
        }
        if (range.length == 1 && range.location == 6){
            range.location=range.location-2;
            range.length = 3;
            textField.text = [textField.text stringByReplacingCharactersInRange:range withString:@""];
            return NO;
        }
    }
    return YES;
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

- (BOOL)isAuthorized
{
    return [((GTMOAuth2Authentication *)self.driveService.authorizer) canAuthorize];
}

// Creates the auth controller for authorizing access to Google Drive.
- (GTMOAuth2ViewControllerTouch *)createAuthController
{
    GTMOAuth2ViewControllerTouch *authController;
    authController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:kGTLAuthScopeDriveFile
                                                                clientID:kClientID
                                                            clientSecret:kClientSecret
                                                        keychainItemName:kKeychainItemName
                                                                delegate:self
                                                        finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    return authController;
}

// Handle completion of the authorization process, and updates the Drive service
// with the new credentials.
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)authResult
                 error:(NSError *)error
{
    if (error != nil)
    {
        [self showAlert:@"Authentication Error" message:error.localizedDescription];
        self.driveService.authorizer = nil;
    }
    else
    {
        self.driveService.authorizer = authResult;
    }
}

// Uploads a photo to Google Drive
- (void)uploadPhoto:(UIImage*)image
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"'Quickstart Uploaded File ('EEEE MMMM d, YYYY h:mm a, zzz')"];
    
    GTLDriveFile *file = [GTLDriveFile object];
    file.title = [dateFormat stringFromDate:[NSDate date]];
    file.descriptionProperty = @"Uploaded from the Google Drive iOS Quickstart";
    file.mimeType = @"image/png";
    
    NSData *data = UIImagePNGRepresentation((UIImage *)image);
    GTLUploadParameters *uploadParameters = [GTLUploadParameters uploadParametersWithData:data MIMEType:file.mimeType];
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesInsertWithObject:file
                                                       uploadParameters:uploadParameters];
    
    UIAlertView *waitIndicator = [self showWaitIndicator:@"Uploading to Google Drive"];
    
    [self.driveService executeQuery:query
                  completionHandler:^(GTLServiceTicket *ticket,
                                      GTLDriveFile *insertedFile, NSError *error) {
                      [waitIndicator dismissWithClickedButtonIndex:0 animated:YES];
                      if (error == nil)
                      {
                          NSLog(@"File ID: %@", insertedFile.identifier);
                          [self showAlert:@"Google Drive" message:@"File saved!"];
                      }
                      else
                      {
                          NSLog(@"An error occurred: %@", error);
                          [self showAlert:@"Google Drive" message:@"Sorry, an error occurred!"];
                      }
                  }];
}

// Helper for showing a wait indicator in a popup
- (UIAlertView*)showWaitIndicator:(NSString *)title
{
    UIAlertView *progressAlert;
    progressAlert = [[UIAlertView alloc] initWithTitle:title
                                               message:@"Please wait..."
                                              delegate:nil
                                     cancelButtonTitle:nil
                                     otherButtonTitles:nil];
    [progressAlert show];
    
    UIActivityIndicatorView *activityView;
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityView.center = CGPointMake(progressAlert.bounds.size.width / 2,
                                      progressAlert.bounds.size.height - 45);
    
    [progressAlert addSubview:activityView];
    [activityView startAnimating];
    return progressAlert;
}

// Helper for showing an alert
- (void)showAlert:(NSString *)title message:(NSString *)message
{
    UIAlertView *alert;
    alert = [[UIAlertView alloc] initWithTitle: title
                                       message: message
                                      delegate: nil
                             cancelButtonTitle: @"OK"
                             otherButtonTitles: nil];
    [alert show];
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
