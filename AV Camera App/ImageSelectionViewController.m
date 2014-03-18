//
//  ImageSelectionViewController.m
//  OcularCellscope
//
//  Created by Chris Echanique on 2/19/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import "ImageSelectionViewController.h"
#import "EImage.h"
#import "FixationViewController.h"

@interface ImageSelectionViewController ()

@property(assign, nonatomic) int currentImageIndex;

@end

@implementation ImageSelectionViewController

@synthesize imageView,slider, images, currentImageIndex, selectedLight, selectedEye, thumbnails, imageViewButton, selectedIcon;


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
    currentImageIndex = 0;
    selectedIcon.layer.shadowOffset = CGSizeMake(0, 1);
}

-(void)viewWillAppear:(BOOL)animated
{
    //[selectedIcon setImage:[UIImage imageNamed:@"x_button.png"]];
    NSLog(@"There are %lu images", (unsigned long)[images count]);
    NSLog(@"There are %lu thumbnails", (unsigned long)[thumbnails count]);
    
    if([images count]<1)
        slider.hidden = YES;
    else{
        slider.hidden = NO;
        slider.minimumValue = 0;
        slider.maximumValue = [images count]-1;
        
        [self updateViewWithImage:[images objectAtIndex:currentImageIndex] useThumbnail:NO];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)didMoveSlider:(id)sender{
    int newImageIndex = (int) (slider.value + .5);
    
    if(newImageIndex!=currentImageIndex){
        currentImageIndex = newImageIndex;
        
        [self updateViewWithImage:[images objectAtIndex:currentImageIndex] useThumbnail:YES];
        
        //[imageView setImage:[thumbnails objectAtIndex:newImageIndex]];
        
        /*
        NSNumber* currentIndex = [NSNumber numberWithInt:currentImageIndex];
        
        BOOL isCurrentlySelected =[selectedImageIndices containsObject:currentIndex];
        
        if(isCurrentlySelected){
            // Deselect image
            [self changeImageIconToSelected:YES];
        }
        else{
            // Select image
            [self changeImageIconToSelected:NO];
        }
         */
    }
    
}

-(IBAction)didTouchUpFromSlider:(id)sender{
    //slider.value = currentImageIndex;
    //[imageView setImage:[images objectAtIndex:currentImageIndex]];
    
    [self updateViewWithImage:[images objectAtIndex:currentImageIndex] useThumbnail:NO];
}

-(IBAction)didSelectImage:(id)sender{
    NSLog(@"Image %d touched", currentImageIndex);
    
    EImage* currentImage = [images objectAtIndex:currentImageIndex];
    [currentImage toggleSelected];
    [self changeImageIconToSelected:[currentImage isSelected]];
    
    /*
    NSNumber* currentIndex = [NSNumber numberWithInt:currentImageIndex];
    
    BOOL isCurrentlySelected = [selectedImageIndices containsObject:currentIndex];
    
    if(isCurrentlySelected){
        // Deselect image
        NSLog(@"Image %d deselected", currentImageIndex);
        [self changeImageIconToSelected:YES];
        [selectedImageIndices removeObject:currentIndex];
    }
    else{
        // Select image
        NSLog(@"Image %d selected", currentImageIndex);
        [self changeImageIconToSelected:NO];
        [selectedImageIndices addObject:currentIndex];
    }
        */
    
}

-(IBAction)didPressCancel:(id)sender{
    NSArray* viewControllers = self.navigationController.viewControllers;
    UIViewController* fixationVC = [viewControllers objectAtIndex:[viewControllers count]-3];
    [self.navigationController popToViewController:fixationVC animated:YES];
}
-(IBAction)didPressSave:(id)sender{
    if([EImage containsSelectedImageInArray:images]){
        //save
        
        NSArray* viewControllers = self.navigationController.viewControllers;
        UIViewController* fixationVC = [viewControllers objectAtIndex:[viewControllers count]-3];
        [self.navigationController popToViewController:fixationVC animated:YES];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Images Selected"
                                                        message:@"You must select at least one image before saving."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"CaptureViewSegue"])
    {
        NSLog(@"Preparing for CaptureViewSegue");
        FixationViewController* fvc = (FixationViewController*)[segue destinationViewController];
        fvc.imageArray = [EImage selectedImagesFromArray:images];
    }
    
    else if ([[segue identifier] isEqualToString:@"ImageSelectionSegue"])
    {
        ImageSelectionViewController * isvc = (ImageSelectionViewController*)[segue destinationViewController];
        isvc.selectedEye = self.selectedEye;
        isvc.selectedLight = self.selectedLight;
    }
    
}

-(void)updateViewWithImage:(EImage*) image useThumbnail:(bool) useThumbnail{
    if(useThumbnail)
        [imageView setImage:image.thumbnail];
    else
        [imageView setImage:image];
    
    [self changeImageIconToSelected:[image isSelected]];
}

-(void)changeImageIconToSelected:(BOOL) isSelected{
    if(isSelected){
        [selectedIcon setImage:[UIImage imageNamed:@"selected_icon.png"]];
    }
    else{
        [selectedIcon setImage:[UIImage imageNamed:@"unselected_icon.png"]];
    }
}
@end
