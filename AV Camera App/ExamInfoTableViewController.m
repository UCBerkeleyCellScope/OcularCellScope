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

@synthesize firstnameField, lastnameField, profilePicButton, patientIDLabel,  phoneNumberField, patientIDTextField;
@synthesize birthDayTextField,birthMonthTextField,birthYearTextField;
//@synthesize driveService;
@synthesize s3manager;

//physicianField
@synthesize e;

@synthesize tapRecognizer;

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
    
    /*self.driveService = [[GTLServiceDrive alloc] init];
    self.driveService.authorizer = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                                                         clientID:kClientID
                                                                                     clientSecret:kClientSecret];
    */
    
    self.s3manager = [[CellScopeContext sharedContext]s3manager];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    //[self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:fields]];
    //[self.keyboardControls setDelegate:self];
    
    self.firstnameField.delegate=self;
    self.lastnameField.delegate=self;
    
    self.birthDayTextField.delegate=self;
    self.birthMonthTextField.delegate=self;
    self.birthYearTextField.delegate=self;
    
    self.phoneNumberField.delegate=self;
    self.patientIDTextField.delegate=self;
       
   
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapBackground:)];
    [self.tableView addGestureRecognizer:tapRecognizer];
    tapRecognizer.delegate = self;
    
    firstnameField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    lastnameField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    //physicianField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    
    
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
    self.patientIDTextField.text = e.patientID;
    self.phoneNumberField.text = e.phoneNumber;
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:e.date];
    
    self.birthDayTextField.text = [NSString stringWithFormat: @"%d", (int)[components day]];
    self.birthMonthTextField.text = [NSString stringWithFormat: @"%d", (int)[components month]];
    self.birthYearTextField.text = [NSString stringWithFormat: @"%d", (int)[components year]];
    
    if(e.profilePicData){
        [self.profilePicButton setImage:[UIImage imageWithData:e.profilePicData] forState:UIControlStateNormal];
    }
    
    if( e.patientIndex == 0){ // indicates a new exam
        e.patientIndex = [[NSUserDefaults standardUserDefaults] objectForKey:@"patientNumberIndex"];
        int value = [e.patientIndex intValue];
        value=value+1;
        
        [[NSUserDefaults standardUserDefaults] setValue: [NSNumber numberWithInt:value] forKey:@"patientNumberIndex" ];
        NSLog(@"%d",value);
        
        e.patientIndex = [NSNumber numberWithInt: value];
        //self.patientIDField.text = [e.patientID stringValue];
        self.patientIDLabel.text = [e.patientIndex stringValue];
    }
    else{
        //self.patientIDField.text = [e.patientID stringValue];
        self.patientIDLabel.text = [e.patientIndex stringValue];
        
    }
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
    
    //Crop the image to a square
    CGSize imageSize = image.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    if (width != height) {
        CGFloat newDimension = MIN(width, height);
        CGFloat widthOffset = (width - newDimension) / 2;
        CGFloat heightOffset = (height - newDimension) / 2;
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(newDimension, newDimension), NO, 0.);
        [image drawAtPoint:CGPointMake(-widthOffset, -heightOffset)
                 blendMode:kCGBlendModeCopy
                     alpha:1.];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
    e.profilePicData = imageData;
    
    //[self uploadPhoto:image];
    
    [profilePicButton setImage:image forState:UIControlStateNormal];
    
    NSString *bucketName = [[[Constants pictureBucket] stringByAppendingString:[e fullName]]lowercaseString];
        
    [s3manager processGrandCentralDispatchUpload:imageData forExamBucket:bucketName andImageName:PICTURE_NAME];
    
    
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


-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    CGPoint p = [gestureRecognizer locationInView:[self tableView]];
    
    NSIndexPath *indexPath = [[self tableView] indexPathForRowAtPoint:p];
    
    NSLog(@"ROW:%d",indexPath.row);
    NSLog(@"TAG:%d",touch.view.tag);
    
    if([touch.view isKindOfClass:[UITableViewCell class]]){
        if(touch.view.tag >0){
            [[self tableView] endEditing:YES];
            return YES;
        }
    }
    return NO;
    
    /*
     if(indexPath != nil && indexPath.row ==0 ) {
     [[self tableView] endEditing:YES];
     return YES;
     }
     else
     return NO;
     */
}

- (void)didTapBackground{
    NSLog(@"Background Tapped");
    
    [[self tableView] endEditing:YES];
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
    e.patientID = patientIDTextField.text;
    
    NSArray *array = [NSArray arrayWithObjects:
    self.birthDayTextField.text,
    self.birthMonthTextField.text,
    self.birthYearTextField.text, nil
                      ];
    NSString * birthDateString = [[array valueForKey:@"description"] componentsJoinedByString:@""];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // this is imporant - we set our input date format to match our input string
    // if format doesn't match you'll get nil from your string, so be careful
    [dateFormatter setDateFormat:@"ddMMyyyy"];
    e.date = [dateFormatter dateFromString:birthDateString];
    NSLog(@"%@",e.phoneNumber);
    NSLog(@"%@",e.date.description);
    
    // Commit to core data
    NSError *error;
    if (![[[CellScopeContext sharedContext] managedObjectContext] save:&error])
        NSLog(@"Failed to commit to core data: %@", [error domain]);
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"Text Field Should Return!");
    if (textField == firstnameField) {
        [lastnameField becomeFirstResponder];
        return YES;
    } else if (textField == lastnameField) {
        [birthDayTextField becomeFirstResponder];
        return YES;
    } else if (textField == birthDayTextField) {
        [birthMonthTextField becomeFirstResponder];
        return YES;
    } else if (textField == birthMonthTextField) {
        [birthYearTextField becomeFirstResponder];
        return YES;
    }else if (textField == birthYearTextField) {
        [phoneNumberField becomeFirstResponder];
        return YES;
    } else if (textField == phoneNumberField) {
        [patientIDTextField becomeFirstResponder];
        return YES;
    }
    else{
        [textField resignFirstResponder];
        return NO;
    }
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
    
    if(textField == birthDayTextField){
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        if (newLength > 2)
            [birthMonthTextField becomeFirstResponder];
    }
    if (textField == birthMonthTextField){
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        if (newLength > 2)
            [birthYearTextField becomeFirstResponder];
    }
    if (textField == birthYearTextField){
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        if (newLength > 4)
        [phoneNumberField becomeFirstResponder];
    }

    
    
    if (textField==phoneNumberField){
        // All digits entered
        if (range.location == 15) {
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
/*
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
*/

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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
