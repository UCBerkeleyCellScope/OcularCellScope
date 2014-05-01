//
//  ImageScrollViewController.m
//  OcularCellscope
//
//  Created by Chris Echanique on 4/25/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import <AssetsLibrary/ALAsset.h>
#import "ImageScrollViewController.h"
#import "EImage.h"
#import "EyeImage.h"
#import "CellScopeContext.h"


@interface ImageScrollViewController ()

@property UIViewController *fixationVC;

@end

@implementation ImageScrollViewController

@synthesize images = _images;
@synthesize fixationVC =_fixationVC;
@synthesize imageScrollView = _imageScrollView;
@synthesize reviewMode = _reviewMode;

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
    
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    
    NSArray* viewControllers = self.navigationController.viewControllers;
    self.fixationVC = [viewControllers objectAtIndex: 1 ];
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self setupScrollView];
}

-(void) setupScrollView{
    
    NSMutableArray *imageViews = [[NSMutableArray alloc] init];
    for(EImage *im in self.images){
        [imageViews addObject:[[UIImageView alloc] initWithImage: im]];
    }
    
    [self.view addSubview: self.imageScrollView]; //This code assumes it's in a UIViewController
    CGRect cRect = self.imageScrollView.bounds;
    UIImageView *cView;
    for (int i = 0; i < imageViews.count; i++){
        cView = [imageViews objectAtIndex:i];
        cView.frame = cRect;
        [self.imageScrollView addSubview:cView];
        cRect.origin.x += cRect.size.width;
    }
    self.imageScrollView.contentSize = CGSizeMake(cRect.origin.x, self.imageScrollView.bounds.size.height);
    self.imageScrollView.contentOffset = CGPointMake(0,0);//self.imageScrollView.bounds.size.width, 0); //should be the center page
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    //scrollView.contentOffset = CGPointMake(scrollView.bounds.size.width, 0);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)didPressCancel:(id)sender{
    [self.navigationController popToViewController:self.fixationVC animated:YES];
}

-(void)didPressDelete:(id)sender{
    
}

-(void)didPressSave:(id)sender{
    if(self.reviewMode == NO){
        for( EImage* ei in self.images){
            EyeImage* coreDataObject = (EyeImage*)[NSEntityDescription insertNewObjectForEntityForName:@"EyeImage" inManagedObjectContext:[[CellScopeContext sharedContext] managedObjectContext]];
            coreDataObject.date = ei.date;
            coreDataObject.eye = ei.eye;
            coreDataObject.fixationLight = [[NSNumber alloc ]initWithInteger: [[[CellScopeContext sharedContext]bleManager]selectedLight]];
            coreDataObject.exam = [[CellScopeContext sharedContext]currentExam];
            
            
            [self saveImageToCameraRoll:ei coreData: coreDataObject];
            coreDataObject.thumbnail = UIImagePNGRepresentation(ei.thumbnail);
            
            //NSNumber *myNum = [NSNumber numberWithInteger:ei.fixationLight];
            //coreDataObject.fixationLight = myNum;
            
            
            Exam* e = [[CellScopeContext sharedContext ]currentExam ];
            [e addEyeImagesObject:coreDataObject];
            
        }
    }
    
    [self.navigationController popToViewController:self.fixationVC animated:YES];
}

-(void)saveImageToCameraRoll:(UIImage*) image coreData: (EyeImage*) cd{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    [library writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error){
        if (error) {
            NSLog(@"Error writing image to photo album");
        }
        else {
            NSString *myString = [assetURL absoluteString];
            NSString *myPath = [assetURL path];
            NSLog(@"Super important! This is the file path!");
            NSLog(@"%@", myString);
            NSLog(@"%@", myPath);
            
            NSLog(@"Added image to asset library");
            
            cd.filePath = [assetURL absoluteString];
            
        }
    }]; // end of completion block
    //Consider an NSNotification that you may now Segue
    
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
