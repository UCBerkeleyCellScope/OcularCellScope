//
//  UploadBannerView.m
//  OcularCellscope
//
//  Created by PJ Loury on 6/4/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import "UploadBannerView.h"
#import "UIColor+Custom.h"

@implementation UploadBannerView
@synthesize uploadStatusLabel;
@synthesize uploadingIndicator;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    
    self.backgroundColor = [UIColor darkGreenColor];
    self.alpha = 1.0;
   // uploadStatusLabel = [[UILabel* alloc]init]
    
    
    
    uploadStatusLabel = [[UILabel alloc] initWithFrame:[self bounds]];
    
    [uploadStatusLabel setTextColor:[UIColor whiteColor]];
    [uploadStatusLabel setBackgroundColor:[UIColor clearColor]];
    [uploadStatusLabel setTextAlignment: NSTextAlignmentCenter];
    
    [uploadStatusLabel setFont:[UIFont fontWithName: @"Trebuchet MS" size: 14.0f]];
    uploadStatusLabel.text = @"Uploading...";
    
    [self addSubview:uploadStatusLabel];
    
    return self;
}

-(void)takeBannerDownWithFade{
    
    [UIView transitionWithView:self
                      duration:4.0
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:NULL
                    completion:NULL];
    
    self.hidden = YES;
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
