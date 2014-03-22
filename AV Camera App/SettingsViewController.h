//
//  SettingsViewController.h
//  OcularCellscope
//
//  Created by PJ Loury on 3/21/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CellScopeContext.h"

@interface SettingsViewController : UITableViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *debugToggle;
- (IBAction)toggleDidChange:(id)sender;

- (IBAction)didPressDone:(id)sender;


@end
