//
//  DiagnosisViewController.h
//  OcularCellscope
//
//  Created by PJ Loury on 4/7/14.
//  Copyright (c) 2014 UC Berkeley Ocular CellScope. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CellScopeContext.h"
#import "CellScopeHTTPClient.h"


@interface DiagnosisViewController : UIViewController<CellScopeHTTPClientDelegate>
@property (weak, nonatomic) IBOutlet UILabel *diagnosisTitle;

@property (weak, nonatomic) IBOutlet UILabel *diagnosisText;

@property (strong, nonatomic) NSString* patientID;

@property (weak, nonatomic) IBOutlet UITextView *prognosisTextView;


@property (weak, nonatomic) IBOutlet UIImageView *diagnosisngSpecialistImageView;
@property (weak, nonatomic) IBOutlet UILabel *contactPatientLabel;
@property (weak, nonatomic) IBOutlet UIButton *contactPatientButton;



@end
