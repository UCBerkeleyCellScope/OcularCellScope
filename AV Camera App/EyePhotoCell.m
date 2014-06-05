//
//  EyePhotoCell.m
//  OcularCellscope
//
//  Created by Chris Echanique on 5/1/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import "EyePhotoCell.h"
#import "SelectableUIEyeImage.h"
#import "SelectableEyeImage.h"
#import "EyeImage.h"
#import "CellScopeContext.h"

//#import "Light.h"

@implementation EyePhotoCell

@synthesize eyeImage = _eyeImage;
@synthesize eyeImageView = _eyeImageView;
@synthesize fixationImageView = _fixationImageView;
@synthesize scrollView = _scrollView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self updateCell];
    }
    
    return self;
}

-(void) setEyeImage:(SelectableEyeImage *)image{
    _eyeImage = image;
    _eyeImageView.image = image;
    [self setFixationImageViewWithEyeImage];
    [self updateCell];
    
}

- (IBAction)didSelectImage:(id)sender {
    [self.eyeImage toggleSelected];
    [self updateCell];
}

- (void)updateCell{
    self.eyeImageView.image = self.eyeImage;
    [self changeImageIconToSelected:self.eyeImage.selected];
}

-(void)changeImageIconToSelected:(BOOL) isSelected{
    if(isSelected){
        NSLog(@"changedImageIcon");
        [self.selectButton setImage:[UIImage imageNamed:@"delete_icon.png"] forState:UIControlStateNormal];
    }
    else{
        [self.selectButton setImage:[UIImage imageNamed:@"unselected.png"] forState:UIControlStateNormal];
    }
}

//TODO: revisit...flip images for right eye
-(void) setFixationImageViewWithEyeImage{
    EyeImage *cdImage = self.eyeImage.coreDataImage;
    switch(cdImage.fixationLight.intValue){

        case FIXATION_LIGHT_CENTER:
            self.fixationImageView.image = [UIImage imageNamed:@"center.png"];
            break;
        case FIXATION_LIGHT_UP:
            self.fixationImageView.image = [UIImage imageNamed:@"top.png"];
            break;
        case FIXATION_LIGHT_DOWN:
            self.fixationImageView.image = [UIImage imageNamed:@"bottom.png"];
            break;
        case FIXATION_LIGHT_LEFT:
            self.fixationImageView.image = [UIImage imageNamed:@"left.png"];
            break;
        case FIXATION_LIGHT_RIGHT:
            self.fixationImageView.image = [UIImage imageNamed:@"right.png"];
            break;
        case FIXATION_LIGHT_NONE:
            self.fixationImageView.image = nil;
            break;
    }
}

/*
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.eyeImageView;
}
 */

- (void)view:(UIView*)view setCenter:(CGPoint)centerPoint
{
    CGRect vf = view.frame;
    CGPoint co = self.scrollView.contentOffset;
    
    CGFloat x = centerPoint.x - vf.size.width / 2.0;
    CGFloat y = centerPoint.y - vf.size.height / 2.0;
    
    if(x < 0)
    {
        co.x = -x;
        vf.origin.x = 0.0;
    }
    else
    {
        vf.origin.x = x;
    }
    if(y < 0)
    {
        co.y = -y;
        vf.origin.y = 0.0;
    }
    else
    {
        vf.origin.y = y;
    }
    
    view.frame = vf;
    self.scrollView.contentOffset = co;
}

// MARK: - UIScrollViewDelegate
- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return  self.eyeImageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)sv
{
    UIView* zoomView = [sv.delegate viewForZoomingInScrollView:sv];
    CGRect zvf = zoomView.frame;
    if(zvf.size.width < sv.bounds.size.width)
    {
        zvf.origin.x = (sv.bounds.size.width - zvf.size.width) / 2.0;
    }
    else
    {
        zvf.origin.x = 0.0;
    }
    if(zvf.size.height < sv.bounds.size.height)
    {
        zvf.origin.y = (sv.bounds.size.height - zvf.size.height) / 2.0;
    }
    else
    {
        zvf.origin.y = 0.0;
    }
    zoomView.frame = zvf;
}


@end
