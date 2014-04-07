//
//  SettingsViewController.m
//  OcularCellscope
//
//  Created by PJ Loury on 3/21/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()
@property(nonatomic, strong) NSUserDefaults *prefs;

@end

@implementation SettingsViewController
@synthesize prefs = _prefs;

@synthesize debugToggle,captureDelay,flashDuration,multiShot;

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
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped)];
    [self.tableView addGestureRecognizer:gestureRecognizer];
    
    _prefs = [NSUserDefaults standardUserDefaults];
    
    [ debugToggle setOn: [_prefs boolForKey: @"debugMode"] animated: NO];
    
    //NSString initWith
    
    //[captureDelay setText: [_prefs integerForKey: @"captureDelay"]   ];
   
    //[flashDuration setText: [_prefs integerForKey: @"captureDelay"]   ];
    
    
    //[ captureDelay setText:[[_prefs integerForKey: @"captureDelay"]stringValue] ];
    //@"numberOfImages"
   //@"numberOfImages"
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void) viewDidAppear:(BOOL)animated{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backgroundTapped {
    NSLog(@"Background Tapped");
    [[self tableView] endEditing:YES];
}

- (IBAction)toggleDidChange:(id)sender {


    if(debugToggle.on == YES){
        [_prefs setValue: @YES forKey:@"debugMode" ];

    }
    else if(debugToggle.on == NO){
        [_prefs setValue: @NO forKey:@"debugMode" ];
    }
    
    NSLog(@"ToggleChange to %d",debugToggle.on);
    
}

- (IBAction)didPressDone:(id)sender {

    [self.navigationController popToRootViewControllerAnimated:YES];

}

#pragma mark - Table view data source

/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.

}
*/
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
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
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
