//
//  TabViewController.m
//  OcularCellscope
//
//  Created by PJ Loury on 3/22/14.
//  Copyright (c) 2014 UC Berkeley Ocular CellScope. All rights reserved.
//

#import "TabViewController.h"
#import "FixationViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

#import "UIColor+Custom.h"
#import "CellScopeContext.h"
#import "CoreDataController.h"
#import "Exam+Methods.h"
//#import "MBProgressHUD.h"

#import <Parse/Parse.h>

@interface TabViewController ()

@end

@implementation TabViewController

@synthesize uploadButton;
@synthesize uploadBanner;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize filesToUpload;
@synthesize backFromReview;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [ [UITabBar appearance] setTintColor: [UIColor brightGreenColor]];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBar.barTintColor = [UIColor brightGreenColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    self.managedObjectContext = [[CellScopeContext sharedContext] managedObjectContext];
    
    //[uploadButton setFont: [UIFont fontWithName:@"HelveticaNeue-Thin," size:14]];
    //FixationViewController *fix = (FixationViewController *)[self.tabBarController.viewControllers objectAtIndex:1];
    //[fix viewWillAppear:YES];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
     setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"HelveticaNeue-Light" size:17], NSFontAttributeName,
      [UIColor whiteColor], NSForegroundColorAttributeName,
      nil]
     
    forState:UIControlStateNormal];
    
    CGRect frame = CGRectMake(0.0,380.0,320.0,50.0);
    uploadBanner = [[UploadBannerView alloc]initWithFrame:frame];
    [uploadBanner setHidden:YES];
    [self.view addSubview:uploadBanner];
    [CellScopeHTTPClient sharedCellScopeHTTPClient].uploadBannerView = uploadBanner;
}

/*
-(void)viewWillAppear:(BOOL)animated{
    filesToUpload = [CoreDataController getEyeImagesToUploadForExam:[[CellScopeContext sharedContext]currentExam] ];
    //self.navigationController.navigationBar.topItem.title = @"Exam";
}
*/
 
- (IBAction)didPressUpload:(id)sender {
    
    NSError *error;
    if (![[[CellScopeContext sharedContext] managedObjectContext] save:&error])
        NSLog(@"Failed to commit to core data: %@", [error domain]);
    
    uploadButton.enabled = NO;
    
    filesToUpload = [CoreDataController getEyeImagesToUploadForExam:[[CellScopeContext sharedContext]currentExam] ];
    
    if([filesToUpload count ]>0){
        
        //OVERRIDE POINT: USE PARSE:
        
        for( EyeImage* ei in filesToUpload){
            [self uploadImageUsingParse:ei];
        }
        
        //[CellScopeHTTPClient sharedCellScopeHTTPClient].imagesToUpload = [NSMutableArray arrayWithArray:filesToUpload];
        //[[CellScopeHTTPClient sharedCellScopeHTTPClient] batch];
    }
    else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Images to Upload"
                                                            message:@"Press the Images tab to begin capturing images."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        
        [alertView show];
    }
    uploadButton.enabled = YES;
    
}

- (void)uploadImageUsingParse:(EyeImage *)eyeImage
{
    NSURL *aURL = [NSURL URLWithString: eyeImage.filePath];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:aURL
             resultBlock:^(ALAsset *asset)
     {
         ALAssetRepresentation* rep = [asset defaultRepresentation];
         
         NSUInteger size = (NSUInteger)rep.size;
         NSMutableData *imageData = [NSMutableData dataWithLength:size];
         NSError *error;
         [rep getBytes:imageData.mutableBytes fromOffset:0 length:size error:&error];
         
         [self uploadImage:imageData];
         
     }
            failureBlock:^(NSError *error)
     {
         NSLog(@"failure loading video/image from AssetLibrary");
     }
     ];
}


- (void)uploadImage:(NSData *)imageData
{
    PFFile *imageFile = [PFFile fileWithName:[NSString stringWithFormat:@"Image%@-%d.jpg",
                                              [[[CellScopeContext sharedContext] currentExam] fullName],arc4random()] data:imageData];
    
    // Save PFFile
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            // Create a PFObject around a PFFile and associate it with the current user
            PFObject *eyeImage = [PFObject objectWithClassName:@"EyeImage"];
            [eyeImage setObject:imageFile forKey:@"Image"];
            eyeImage[@"Eye"] = @"OD";
            
            // Set the access control list to current user for security purposes
            //eyeImage.ACL = [PFACL ACLWithUser:[PFUser currentUser]];
            
            [eyeImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
             {
                 PFObject *patient = [[CellScopeContext sharedContext] parsePatient];
                 PFRelation *relation = [patient relationForKey:@"EyeImages"];
                 [relation addObject: eyeImage];
                 [patient saveInBackground];
             }];
        }
        else{
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    } progressBlock:^(int percentDone) {
        // Update your progress spinner here. percentDone will be between 0 and 100.
        //HUD.progress = (float)percentDone/100;
        //HUD.labelText = [NSString stringWithFormat:@"%2f%",HUD.progress];
        
    }];
}


- (IBAction)didPressCancel:(id)sender {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete this exam?"
                                                        message:@"Your images and patient data will be lost."
                                                       delegate:self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes",nil];
    
    [alertView show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1){
        [self.managedObjectContext deleteObject:[[CellScopeContext sharedContext] currentExam]];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
