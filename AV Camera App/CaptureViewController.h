//
//  CaptureViewController.h
//  OcularCellscope
//
//  Created by Chris Echanique on 2/21/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLE.h"

@interface CaptureViewController : UIViewController<BLEDelegate>
{
IBOutlet UIBarButtonItem *bleConnect;
}
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UILabel *counterLabel;

@property (nonatomic) NSInteger const selectedLight;
@property (copy, nonatomic) NSString *selectedEye;

@property (strong, nonatomic) BLE *ble;

@end
