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
@synthesize imageObject, singleImage, whichEye, managedObjectContext;

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
}

- (void)viewWillAppear:(BOOL)animated{
    
    NSURL *url = [NSURL URLWithString: imageObject.filePath];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *img = [[UIImage alloc] initWithData: data];
    
    //self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame: screenRect]
    
    //LightBoxView *lbv =
    
    //[scrollView setMinimumZoomScale:1.0];
    //[scrollView setMaximumZoomScale:5.0];
    
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
- (IBAction)didPressDelete:(id)sender {
    
    
    UIAlertView* alert;
   
    alert = [[UIAlertView alloc] initWithTitle:@"Delete Photo" message:@"Are you sure?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    
    
    alert.tag = 1;
    alert.alertViewStyle = UIAlertViewStyleDefault;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==1) //this is our delete alert
    {
        if (buttonIndex==1) //YES BUTTON
            [self deletePhoto];
    }
}


- (void)deletePhoto
{
    NSLog(@"deleting photo");
    
    //if this session only has one photo, delete the whole session
    //if (currentPicture.session.pictures.count==1)
        //[[[CellScopeContext sharedContext] managedObjectContext] deleteObject:currentPicture.session];
    //else
    [managedObjectContext deleteObject:imageObject];
    
    [managedObjectContext save:nil];
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
