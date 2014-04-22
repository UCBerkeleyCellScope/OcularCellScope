//
//  AVCaptureManager.h
//  OcularCellscope
//
//  Created by Chris Echanique on 4/17/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AVFoundation;

@protocol ImageCaptureDelegate
- (void)didCaptureImageWithData:(NSData *)data;
@end

@interface AVCaptureManager : NSObject

@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) AVCaptureDevice *device;
@property (strong, nonatomic) AVCaptureDeviceInput *deviceInput;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (strong, nonatomic) AVCaptureStillImageOutput *stillOutput;
@property (weak, nonatomic) id <ImageCaptureDelegate> delegate;

-(void)setupVideoForView:(UIView*)view;
-(void)takePicture;
-(void)lockFocus;
-(void)unlockFocus;

@end
