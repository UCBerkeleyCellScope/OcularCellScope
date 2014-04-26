//
//  TabViewController.h
//  OcularCellscope
//
//  Created by PJ Loury on 3/22/14.
//  Copyright (c) 2014 UC Berkeley Ocular CellScope. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TabViewController : UITabBarController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
- (IBAction)didPressSave:(id)sender;
- (IBAction)didPressCancel:(id)sender;

@end
