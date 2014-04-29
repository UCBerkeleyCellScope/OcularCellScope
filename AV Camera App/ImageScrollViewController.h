//
//  ImageScrollViewController.h
//  OcularCellscope
//
//  Created by Chris Echanique on 4/25/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageScrollViewController : UIViewController

@property (strong, nonatomic) NSMutableArray *images; //THIS IS THE EIMAGEOBJECT
@property (strong, nonatomic) IBOutlet UIScrollView *imageScrollView;
@property (assign, nonatomic) BOOL reviewMode;

-(IBAction)didPressCancel:(id)sender;
-(IBAction)didPressSave:(id)sender;
-(IBAction)didPressDelete:(id)sender;

@end
