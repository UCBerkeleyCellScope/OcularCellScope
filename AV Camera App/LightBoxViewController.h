//
//  LightBoxViewController.h
//  OcularCellscope
//
//  Created by PJ Loury on 2/11/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Image.h"

@interface LightBoxViewController : UIViewController

@property(strong, nonatomic) IBOutlet UIImageView * singleImage;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property(strong, nonatomic) Image * imageObject;
@end
