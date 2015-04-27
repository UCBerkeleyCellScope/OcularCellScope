//
//  TabViewController.h
//  OcularCellscope
//
//  Created by PJ Loury on 3/22/14.
//  Copyright (c) 2014 UC Berkeley Ocular CellScope. All rights reserved.
//
//  TabViewController contains both ExamInfoTableViewController and FixationViewController

#import <UIKit/UIKit.h>


@interface TabViewController : UITabBarController
{

}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *uploadButton;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic) BOOL backFromReview;
- (IBAction)didPressUpload:(id)sender;
- (IBAction)didPressCancel:(id)sender;

@end