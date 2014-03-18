//
//  ImageSelectionViewController.m
//  OcularCellscope
//
//  Created by Chris Echanique on 2/19/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import "ImageSelectionViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "FixationViewController.h"

@interface ImageSelectionViewController ()

@property(assign, nonatomic) int currentImageIndex;

@end

@implementation ImageSelectionViewController

@synthesize imageView,slider, currentImageIndex, selectedLight, selectedEye, images, thumbnails, eyeImages, currentEyeImage;

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
	// Do any additional setup after loading the view.
    //[imageView setImage:[UIImage imageNamed:@"im1.png"]];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    currentImageIndex = 0;
    /*
    images = [[NSMutableArray alloc] init];
    UIImage *im1 = [UIImage imageNamed:@"im1.png"];
    UIImage *im2 = [UIImage imageNamed:@"im2.png"];
    UIImage *im3 = [UIImage imageNamed:@"im3.png"];
    UIImage *im4 = [UIImage imageNamed:@"im4.png"];
    
    [images addObject:im1];
    [images addObject:im2];
    [images addObject:im3];
    [images addObject:im4];
    
    NSLog(@"%@", images);
    */
    
    NSLog(@"There are %lu images", (unsigned long)[images count]);
    NSLog(@"There are %lu thumbnails", (unsigned long)[thumbnails count]);
    
    if([eyeImages count]<1){
        slider.hidden = YES;
        NSLog(@"LESS THAN 1");
    }
    else{
        slider.hidden = NO;
        //[imageView setImage:[images objectAtIndex:currentImageIndex]];
        
        
        [self load:0];

         
        slider.minimumValue = 0;
        slider.maximumValue = [thumbnails count]-1;
    }
    
}

-(void) load: (int) cii{
    NSLog(@"IN THE LOAD");
    currentEyeImage = [eyeImages objectAtIndex:cii];
    
    NSURL *aURL = [NSURL URLWithString: currentEyeImage.filePath];
    
    NSLog(@"displaying image at: %@",currentEyeImage.filePath);
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:aURL resultBlock:^(ALAsset *asset)
     {
         ALAssetRepresentation* rep = [asset defaultRepresentation];
         CGImageRef iref = [rep fullResolutionImage];
         
         [imageView setImage:[UIImage imageWithCGImage:iref]];
     }
            failureBlock:^(NSError *error)
     {
         // error handling
         NSLog(@"failure loading video/image from AssetLibrary");
     }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)didMoveSlider:(id)sender{
    int newImageIndex = (int) (slider.value + .5);
    
    if(newImageIndex!=currentImageIndex){
        [imageView setImage:[thumbnails objectAtIndex:newImageIndex]];
        currentImageIndex = newImageIndex;
    }
    
}

-(IBAction)didTouchUpFromSlider:(id)sender{
    slider.value = currentImageIndex;
    //[imageView setImage:[images objectAtIndex:currentImageIndex]];
    [self load:currentImageIndex];
    
}




- (IBAction)didPressSaveButton:(id)sender {
    
    FixationViewController *fvc = [self.navigationController.viewControllers objectAtIndex:1];
    //fvc.selectedEye = selectedEye;
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}
@end
