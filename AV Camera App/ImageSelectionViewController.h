//
//  ImageSelectionViewController.h
//  OcularCellscope
//
//  Created by Chris Echanique on 2/19/14.
//  Copyright (c) 2014 UC Berkeley Ocular CellScope. All rights reserved.
//
//  This view controller allows the user to browse photos and select ones for deletion. This controller
//  appears automatically after an acquisition sequence, and it also appears if the user selects "Review" in the
//  FixationViewController. After the user exits this controller, any photos marked for deletion are deleted from
//  Core Data and the rest are saved.
//
//  Note that the whole EyeImage/SelectableEyeImage/SelectableUIEyeImage thing is really confusing and needs to be redone.
//  Storing these images in memory is not a good idea because if there are too many they will crash the app. Better approach would be to store them to a local temporary directory and then move to another part of the file system when the user commit them. During review, we should only be loading one image in at a time as the user browses.

#import <UIKit/UIKit.h>
#import "CellScopeContext.h"

@interface ImageSelectionViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>
@property (strong, nonatomic) NSMutableArray *images; //THIS IS THE EIMAGEOBJECT
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeRightRecognizer;
@property BOOL reviewMode;
//@property (strong, nonatomic) IBOutlet UICollectionView *imageCollectionView;

-(IBAction)didPressCancel:(id)sender;
-(IBAction)didPressSave:(id)sender;
-(IBAction)didPressAdd:(id)sender;
-(void)didPressDeleteAll;



@end
