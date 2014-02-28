//
//  CaptureViewController.h
//  OcularCellscope
//
//  Created by Chris Echanique on 2/21/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CaptureViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (copy, nonatomic) NSString *whichLight;

@end
