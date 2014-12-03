//
//  PopupMessage.m
//  Ocular Cellscope
//
//  Created by Frankie Myers on 12/2/14.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//

#import "PopupMessage.h"

@implementation PopupMessage


+ (void) showPopup:(NSString*)message
{
    //todo: move this to a generic UI class
    UIWindow* window = [[UIApplication sharedApplication] keyWindow];
    
    UITextView* alertPopup = [[UITextView alloc] init];
    CGRect frame;
    frame.size.height = 40;
    frame.size.width = 280;
    alertPopup.frame = frame;
    alertPopup.center = window.center;
    alertPopup.text = message;
    [alertPopup setTextAlignment:NSTextAlignmentCenter];
    
    [alertPopup setTextColor:[UIColor whiteColor]];
    [alertPopup setFont:[UIFont boldSystemFontOfSize:20]];
    alertPopup.backgroundColor = [UIColor grayColor];
    alertPopup.layer.cornerRadius = 20;
    alertPopup.clipsToBounds = YES;
    alertPopup.layer.borderWidth = 2.0f;
    alertPopup.layer.borderColor = [UIColor darkGrayColor].CGColor;
    alertPopup.alpha = 0.9f;
    alertPopup.hidden = NO;
    [window addSubview:alertPopup];
    [window bringSubviewToFront:alertPopup];
    
    // Then fades it away after 2 seconds (the cross-fade animation will take 0.5s)
    [UIView animateWithDuration:0.5 delay:2.0 options:0 animations:^{
        // Animate the alpha value of your imageView from 1.0 to 0.0 here
        alertPopup.alpha = 0.0f;
    } completion:^(BOOL finished) {
        // Once the animation is completed and the alpha has gone to 0.0, hide the view for good
        alertPopup.hidden = YES;
        [alertPopup removeFromSuperview];
    }];
}

@end
