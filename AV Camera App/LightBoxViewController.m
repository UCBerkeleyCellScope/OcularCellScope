//
//  LightBoxViewController.m
//  OcularCellscope
//
//  Created by PJ Loury on 2/11/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import "LightBoxViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "CoreDataController.h"
#import "Image.h"

@interface LightBoxViewController ()

@end

@implementation LightBoxViewController
@synthesize imageObject, singleImage, managedObjectContext ;

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
    
    NSURL *url = [NSURL URLWithString: imageObject.filePath];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *img = [[UIImage alloc] initWithData: data];
    
    
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL: url resultBlock:^(ALAsset *asset)
     {
         ALAssetRepresentation* rep = [asset defaultRepresentation];
         CGImageRef iref = [rep fullResolutionImage];
         
         UIImage *image = [UIImage imageWithCGImage:iref];
         
         NSLog(url.description);
         
         [self.singleImage setImage: image];
         
         
         //         [cameraScrollView showImage:image];
         //
         //         [cameraScrollView setZoomScale:[[NSUserDefaults standardUserDefaults] floatForKey:@"MinimumZoom"]*0.91 animated:NO];
         //         [cameraScrollView setMinimumZoomScale:[[NSUserDefaults standardUserDefaults] floatForKey:@"MinimumZoom"]*0.91];
         //         [cameraScrollView setContentOffset:CGPointMake(250,0) animated:NO];
         
     }
            failureBlock:^(NSError *error)
     {
         // error handling
         NSLog(@"failure loading video/image from AssetLibrary");
     }];

     //[self.singleImage setImage: img];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
