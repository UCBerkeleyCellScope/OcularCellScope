//
//  ImagesViewController.h
//  AV Camera App
//
//  Created by PJ Loury on 1/31/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Patient.h"

@interface ImagesViewController : UICollectionViewController <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    
    
    
    
}
@property (strong, nonatomic) NSMutableArray *allImages;

@property (strong, nonatomic) NSMutableArray *allPatients;

@property (weak, nonatomic) IBOutlet UIImageView *cellImage;
//the cell object instead has the image view

@property (strong, nonatomic) Patient* patientToDisplay;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@end
