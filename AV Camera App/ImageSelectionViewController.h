//
//  ImageSelectionViewController.h
//  OcularCellscope
//
//  Created by Chris Echanique on 2/19/14.
//  Copyright (c) 2014 UC Berkeley Ocular CellScope. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CellScopeContext.h"

@interface ImageSelectionViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>
@property (strong, nonatomic) NSMutableArray *images; //THIS IS THE EIMAGEOBJECT
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeRightRecognizer;
@property BOOL reviewMode;
@property (strong, nonatomic) IBOutlet UICollectionView *imageCollectionView;

-(IBAction)didPressCancel:(id)sender;
-(IBAction)didPressSave:(id)sender;
-(IBAction)didPressAdd:(id)sender;
-(void)didPressDeleteAll;



@end
