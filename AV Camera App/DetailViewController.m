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
@synthesize currentExam;
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
    
    firstnameField.text = currentExam.firstName;
    lastnameField.text = currentExam.lastName;
    patientIDField.text = currentExam.patientID;
    
    NSOrderedSet *images = currentExam.eyeImages;
    
    /*
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    request.entity = [NSEntityDescription entityForName:@"EyeImage" inManagedObjectContext: _managedObjectContext];
    request.predicate = [NSPredicate predicateWithFormat: @"eye == %@ AND fixationLight == %d", selectedEye, i];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
    request.fetchLimit = 1;
    NSError *error;
    
    NSArray *array = [_managedObjectContext executeFetchRequest:request error:&error];
    */
    
    
    
    EyeImage *im = [images firstObject];
    
    if(im.filePath!=NULL){
        
        NSLog(@"Filepath: %@",im.filePath);
        
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
