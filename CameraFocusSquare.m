//
//  CameraFocusSquare.m
//  OcularCellscope
//
//  Created by PJ Loury on 5/19/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import "CameraFocusSquare.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+Custom.h"

@interface CameraFocusSquare(){
    CALayer *lay;

}
@end

const float squareLength = 80.0f;
@implementation CameraFocusSquare

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self setBackgroundColor:[UIColor clearColor]];
        [self.layer setBorderWidth:2.0];
        [self.layer setCornerRadius:2.0];
        [self.layer setBorderColor:[UIColor whiteColor].CGColor];
        
        CABasicAnimation* selectionAnimation = [CABasicAnimation animationWithKeyPath:@"borderColor"];
        selectionAnimation.delegate = self;
        
        
        selectionAnimation.toValue = (id)[UIColor mediumGreenColor].CGColor;
        selectionAnimation.repeatCount = 2;
        
        [self.layer addAnimation:selectionAnimation forKey:@"a"];
        
        //every
        
        /*
        CAAnimationGroup *group = [CAAnimationGroup animation];
        [group setAnimations:[NSArray arrayWithObjects:selectionAnimation, fader,nil]];
        [self.layer addAnimation: group forKey:@"allAnimations"];
         */
        
        
    }
    return self;
}


-(void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{

        NSLog(@"Animation interrupted: %@", (!flag)?@"Yes" : @"No");
        CABasicAnimation* fader = [CABasicAnimation
                                   animationWithKeyPath:@"opacity"];
        
        [fader setDuration:1.0];
        [fader setFromValue:[NSNumber numberWithFloat:1.0]];
        [fader setToValue:[NSNumber numberWithFloat:0.0]];
        //fader.delegate = self;
    
        self.layer.opacity = 0.0;
        [self.layer addAnimation:fader forKey:@"focusBoxFade"];

}
@end
