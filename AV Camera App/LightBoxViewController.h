//
//  LightBoxViewController.h
//  OcularCellscope
//
//  Created by PJ Loury on 2/11/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Image.h"

@interface LightBoxViewController : UIViewController <UIScrollViewDelegate>

@property(strong, nonatomic) Image * imageObject;

@property(strong, nonatomic) IBOutlet UIImageView * singleImage;

//@property(strong, nonatomic) IBOutlet LightBoxView * lbv;

@property (strong, nonatomic) IBOutlet UISegmentedControl *whichEye;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
