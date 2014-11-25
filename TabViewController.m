//
//  TabViewController.m
//  OcularCellscope
//
//  Created by PJ Loury on 3/22/14.
//  Copyright (c) 2014 UC Berkeley Ocular CellScope. All rights reserved.
//

#import "TabViewController.h"
#import "FixationViewController.h"

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
    
    [[[CellScopeContext sharedContext] uploadManager] addExamToUploadQueue:[[CellScopeContext sharedContext] currentExam]];
    
    [self.navigationController popViewControllerAnimated:YES];
    
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
