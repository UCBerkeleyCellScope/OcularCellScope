//
//  EyePhotoCell.m
//  OcularCellscope
//
//  Created by Chris Echanique on 5/1/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import "EyePhotoCell.h"
#import "SelectableUIEyeImage.h"
#import "EyeImage.h"
#import "Light.h"

@implementation EyePhotoCell

@synthesize eyeImage = _eyeImage;
@synthesize eyeImageView = _eyeImageView;
@synthesize fixationImageView = _fixationImageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self updateCell];
    }
    
    return self;
}

-(void) setEyeImage:(SelectableUIEyeImage *)eyeImage{
    _eyeImage = eyeImage;
    _eyeImageView.image = eyeImage;
    [self setFixationImageViewWithEyeImage];
    [self updateCell];
    
}

- (IBAction)didSelectImage:(id)sender {
    NSLog(@"eyeImage exists? %d,  eyeImage.selected = %d", self.eyeImage != nil, self.eyeImage.selected);
    [self.eyeImage toggleSelected];
    [self updateCell];
}

- (void)updateCell{
    [self changeImageIconToSelected:self.eyeImage.selected];
}

-(void)changeImageIconToSelected:(BOOL) isSelected{
    if(isSelected){
        NSLog(@"changedImageIcon");
        [self.selectButton setImage:[UIImage imageNamed:@"delete_icon.png"] forState:UIControlStateNormal];
    }
    else{
        [self.selectButton setImage:[UIImage imageNamed:@"unselected_icon.png"] forState:UIControlStateNormal];
    }
}

-(void) setFixationImageViewWithEyeImage{
    EyeImage *cdImage = self.eyeImage.eyeImage;
    switch(cdImage.fixationLight.intValue){

        case CENTER_LIGHT:
            self.fixationImageView.image = [UIImage imageNamed:@"center.png"];
            break;
        case TOP_LIGHT:
            self.fixationImageView.image = [UIImage imageNamed:@"top.png"];
            break;
        case BOTTOM_LIGHT:
            self.fixationImageView.image = [UIImage imageNamed:@"bottom.png"];
            break;
        case LEFT_LIGHT:
            self.fixationImageView.image = [UIImage imageNamed:@"left.png"];
            break;
        case RIGHT_LIGHT:
            self.fixationImageView.image = [UIImage imageNamed:@"right.png"];
            break;
        case NO_LIGHT:
            self.fixationImageView.image = nil;
            break;
    }
}

@end
