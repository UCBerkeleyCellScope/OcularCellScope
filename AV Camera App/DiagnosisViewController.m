//
//  DiagnosisViewController.m
//  OcularCellscope
//
//  Created by PJ Loury on 4/7/14.
//  Copyright (c) 2014 UC Berkeley Ocular CellScope. All rights reserved.
//

#import "DiagnosisViewController.h"

@interface DiagnosisViewController ()
//@property (strong, nonatomic) NSDictionary* diagnosis;
@property CellScopeHTTPClient *client;

@end

@implementation DiagnosisViewController

@synthesize patientID, diagnosisTitle, diagnosisText, contactPatientButton,contactPatientLabel,diagnosisngSpecialistImageView,
    prognosisTextView;

//@synthesize diagnosis;
@synthesize client;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    client = [CellScopeHTTPClient sharedCellScopeHTTPClient];
    client.delegate = self;
    
    CALayer *specialistLayer = diagnosisngSpecialistImageView.layer;
    [specialistLayer setCornerRadius:8];
    [specialistLayer setMasksToBounds:YES];
    
    contactPatientLabel.layer.borderWidth=1.0f;
    contactPatientLabel.layer.borderColor=[[UIColor lightGrayColor] CGColor];
}


- (void)viewWillAppear:(BOOL)animated{
    
    [client updateDiagnosisForExam: [[CellScopeContext sharedContext]currentExam]];
    
    patientID = [[[CellScopeContext sharedContext] currentExam] patientID];
    
    //NSString *string = [NSString stringWithFormat:@"%@diagnosis?patientID=%@&format=json",
    //                    BaseURLString, patientID];
    
    /*
     NSString *string = [NSString stringWithFormat:@"%@diagnosis?format=json",
     BaseURLString];
     
     NSURL *url = [NSURL URLWithString:string];
     NSURLRequest *request = [NSURLRequest requestWithURL:url];
     
     if([[CellScopeContext sharedContext]currentExam].firstName != nil &&
     [[CellScopeContext sharedContext]currentExam].lastName != nil){
     self.tabBarController.title = [NSString stringWithFormat:@"%@ %@",
     [[CellScopeContext sharedContext]currentExam].firstName,
     [[CellScopeContext sharedContext]currentExam].lastName];
     }
     // 2
     AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
     operation.responseSerializer = [AFJSONResponseSerializer serializer];
     
     [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
     
     // 3
     self.diagnosis = (NSDictionary *)responseObject;
     
     [diagnosisTitle setText: self.diagnosis[@"diagnosisTitle"]];
     
     [diagnosisText setText: self.diagnosis[@"diagnosisText"]];
     
     //How will I parse the responseObject
     //[self.tableView reloadData];
     
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
     
     // 4
     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Diagnosis"
     message:[error localizedDescription]
     delegate:nil
     cancelButtonTitle:@"Ok"
     otherButtonTitles:nil];
     [alertView show];
     }];
     
     // 5
     [operation start];
     */
    
    
}

-(void)cellScopeHTTPClient:(CellScopeHTTPClient *)client didUpdateDiagnosis:(id)diagnosis{
    NSLog(@"RETRIEVED DIAGNOSIS");
    [diagnosisTitle setText: diagnosis[@"diagnosisTitle"]];
    [diagnosisText setText: diagnosis[@"diagnosisText"]];
}

-(void)cellScopeHTTPClient:(CellScopeHTTPClient *)client didFailWithError:(NSError *)error{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Diagnosis"
                                                        message:[NSString stringWithFormat:@"%@",error]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
