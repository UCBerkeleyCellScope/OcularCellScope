//
//  PopupMessage.h
//  Ocular Cellscope
//
//  Created by Frankie Myers on 12/2/14.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//
//  Implements a popup message that displays over the current view controller and dissolves after a few seconds

#import <Foundation/Foundation.h>

@interface PopupMessage : NSObject

+ (void) showPopup:(NSString*)message;

@end
