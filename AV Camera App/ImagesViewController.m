//
//  ImagesViewController.m
//  AV Camera App
//
//  Created by PJ Loury on 1/31/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import "ImagesViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "CoreDataController.h"
#import "LightBoxViewController.h"

#import "ImageCell.h"

@interface ImagesViewController ()
@property(nonatomic, weak) IBOutlet UICollectionView *collectionView;

@property(nonatomic,strong) NSArray *assets;
@end

@implementation ImagesViewController

@synthesize allImages, allPatients, patientToDisplay, managedObjectContext;


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
    
    self.allImages = [CoreDataController getObjectsForEntity:@"Image" withSortKey:@"date" andSortAscending:NO
                                                  andContext: self.managedObjectContext ];
                      
    //NSLog(self.allImages.description);
    NSLog(@"Loaded the Collection View!");
    
                      
    //Frankie would do this, because he had a CellScopeContext singleton, that contained a managedObjectContext
    //andContext:[[CellScopeContext sharedContext] managedObjectContext]];
    
    //  Force table refresh
    [self.collectionView reloadData];
    
    
    /*
    _assets = [@[] mutableCopy];
    __block NSMutableArray *tmpAssets = [@[] mutableCopy];
    // 1
    ALAssetsLibrary *assetsLibrary = [ImagesViewController defaultAssetsLibrary];
    // 2
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if(result)
            {
                // 3
                [tmpAssets addObject:result];
            }
        }];
        
        // 4
        //NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
        //self.assets = [tmpAssets sortedArrayUsingDescriptors:@[sort]];
        self.assets = tmpAssets;
        
        // 5
        [self.collectionView reloadData];
    } failureBlock:^(NSError *error) {
        NSLog(@"Error loading images %@", error);
    }];
     
     */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - collection view data source

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //return self.assets.count;
    
    //return self.patientToDisplay.imageKeys.count;
    
    return self.allImages.count;
    
}

//numberOfSectionsInCollectionView IS OPTIONAL, ONLY IF YOU WANT TO USE allPatients

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    

    LightBoxViewController *lbvc = [[LightBoxViewController alloc] init];

    NSArray *items =  allImages;
//These pointers point to the exact same items, so it's all the same object!!
//Isn't that amazing!

    //LightBoxViewController* lbvc = (LightBoxViewController*)[segue destinationViewController];
    
    
    Image *target2 = [items objectAtIndex:[indexPath row]]; //indexPath is just some UITable thing
    
    NSLog(@"WE CLICKED A COLLECTION OBJECT");
    NSLog(target2.description);
    
    lbvc.managedObjectContext = self.managedObjectContext;
    
    lbvc.imageObject = target2;


    [[self navigationController] pushViewController:lbvc
                                           animated:YES];

}



- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCell *cell = (ImageCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    
    //Retrieves the specific UIImage that we want
    
    NSLog(@"The Cells are being created");
    
    //Which section tells me which patient it is!!
    //Image *cellImageObject = (Image*) [ self.allImages objectAtIndex: indexPath.section];
    
    
    //Sets the Image* image field of "ImageCell" object
    Image *target = (Image*)[self.allImages objectAtIndex:indexPath.item];
    //Now that the ImageCell "has" an Image object, the ImageCell can be click on in order to view full screen
    cell.image = target;
    
    NSURL *url = [NSURL URLWithString: target.filePath];
    
    //NSData *data = [NSData dataWithContentsOfURL:url];
    //UIImage *img = [[UIImage alloc] initWithData: data];
    
   
/*
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL: url resultBlock:^(ALAsset *asset)
     {
         ALAssetRepresentation* rep = [asset defaultRepresentation];
         CGImageRef iref = [rep fullResolutionImage];
         
         UIImage *image = [UIImage imageWithCGImage:iref];
         
         [cell.imageView setImage: image];
         
     }
            failureBlock:^(NSError *error)
     {
         // error handling
         NSLog(@"failure loading video/image from AssetLibrary");
     }];
*/
    
    NSLog(@"Images ViewController filePath");
    NSLog(target.filePath.description);

    
    UIImage* thumbImage = [UIImage imageWithData: cell.image.thumbnail];
   
    //[cell.imageView setImage: img];
    
    [cell.imageView setImage: thumbImage];
    
    //From the Old Code
    //ALAsset *asset = self.assets[indexPath.row];
    //cell.asset = asset;
    
    //cell.image.image = [UIImage imageNamed: @"xcode"];
    
    //how does one set the indexPath to retrieve all the images!!!!
    
    //cell.backgroundColor = [UIColor redColor];
    
    return cell;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 4;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 1;
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //LightBoxViewController* lbvc = (LightBoxViewController*)[segue destinationViewController];
    
    //lbvc.managedObjectContext = self.managedObjectContext;
    //lbvc.singleImage = self.currentPatient;
    
    
}



@end
