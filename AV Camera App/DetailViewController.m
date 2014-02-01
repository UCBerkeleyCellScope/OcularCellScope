//
//  DetailViewController.m
//  AV Camera App
//
//  Created by Chris Echanique on 12/8/13.
//  Copyright (c) 2013 NAYA LOUMOU. All rights reserved.
//

#import "DetailViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface DetailViewController ()

@end

@implementation DetailViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize currentPatient;
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
    NSSet *images = currentPatient.patientImages;
    
    
    
    Images *im = [images anyObject];
    
    if(im.filepath!=NULL){
        
        NSLog(@"Filepath: %@",im.filepath);
        
        NSURL *url = [[NSURL alloc] initWithString:im.filepath];
        
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
