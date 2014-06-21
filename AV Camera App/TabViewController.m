//
//  TabViewController.m
//  OcularCellscope
//
//  Created by PJ Loury on 3/22/14.
//  Copyright (c) 2014 UC Berkeley Ocular CellScope. All rights reserved.
//

#import "TabViewController.h"
#import "UIColor+Custom.h"
#import "CellScopeContext.h"
#import "CoreDataController.h"

@interface TabViewController ()

@end

@implementation TabViewController

@synthesize uploadButton;
@synthesize uploadBanner;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize filesToUpload;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [ [UITabBar appearance] setTintColor: [UIColor lightGreenColor]];
    // Do any additional setup after loading the view.
    
    self.managedObjectContext = [[CellScopeContext sharedContext] managedObjectContext];
    
    CGRect frame = CGRectMake(0.0,380.0,320.0,50.0);
    uploadBanner = [[UploadBannerView alloc]initWithFrame:frame];
    [uploadBanner setHidden:YES];
    [self.view addSubview:uploadBanner];
    [CellScopeHTTPClient sharedCellScopeHTTPClient].uploadBannerView = uploadBanner;
}

-(void)viewWillAppear:(BOOL)animated{
    filesToUpload = [CoreDataController getEyeImagesToUploadForExam:[[CellScopeContext sharedContext]currentExam] ];

}

- (IBAction)didPressUpload:(id)sender {
    
    NSError *error;
    if (![[[CellScopeContext sharedContext] managedObjectContext] save:&error])
        NSLog(@"Failed to commit to core data: %@", [error domain]);
    
    uploadButton.enabled = NO;
    
    filesToUpload = [CoreDataController getEyeImagesToUploadForExam:[[CellScopeContext sharedContext]currentExam] ];
    
    if([filesToUpload count ]>0){
        [CellScopeHTTPClient sharedCellScopeHTTPClient].imagesToUpload = [NSMutableArray arrayWithArray:filesToUpload];
        [[CellScopeHTTPClient sharedCellScopeHTTPClient] batch];
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

    //[self.navigationController popViewControllerAnimated:YES];
    
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
