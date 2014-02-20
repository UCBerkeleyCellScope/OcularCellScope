//
//  DetailViewController.m
//  AV Camera App
//
//  Created by Chris Echanique on 12/8/13.
//  Copyright (c) 2013 NAYA LOUMOU. All rights reserved.
//

#import "DetailViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "CoreDataController.h"

@interface DetailViewController ()

@property (strong, nonatomic) NSMutableArray *allImages;

@end

@implementation DetailViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize currentPatient, allImages;
@synthesize firstnameField, lastnameField, patientIDField, physicianField, notesField, lefteyeView, righteyeView;

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
    self.title = @"Patient Info";
    
    firstnameField.text = currentPatient.firstName;
    lastnameField.text = currentPatient.lastName;
    patientIDField.text = currentPatient.patientID;
    //NSSet *images = currentPatient.patientImages;
    
    
    self.allImages = [CoreDataController getObjectsForEntity:@"Image" withSortKey:@"date" andSortAscending:NO
                                                  andContext: self.managedObjectContext ];
    Image *im = [allImages objectAtIndex:0];
    
    if(im.filePath!=NULL){
        
        NSLog(@"filePath: %@",im.filePath);
        
        NSURL *url = [[NSURL alloc] initWithString:im.filePath];
        
        ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
        
        [library assetForURL:url
                 resultBlock:^(ALAsset *asset) {
                     
                     lefteyeView.image = [UIImage imageWithCGImage:[asset thumbnail]];
                     
                 } failureBlock:^(NSError *error) {
                     
                     NSLog(@"Couldn't load asset %@ => %@", error, [error localizedDescription]);
                     
                 }];
        
    }
    
	// Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textViewShouldReturn:(UITextView *)textView {
    [textView resignFirstResponder];
    return NO;
}


@end
