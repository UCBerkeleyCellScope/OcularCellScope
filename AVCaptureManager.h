//
//  AVCaptureManager.h
//  OcularCellscope
//
//  Created by Chris Echanique on 4/17/14.
//  Copyright (c) 2014 UC Berkeley Ocular CellScope. All rights reserved.
//
//  This includes all of our camera functionality. AVCaptureSession and Device objects, functions for taking
//  pictures, and controlling focus/exposure/whitebalance.

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
@property (weak, nonatomic) UIView *view;
@property (weak, nonatomic) id <ImageCaptureDelegate> delegate;
@property (nonatomic) BOOL isExposureLocked;
@property (assign, nonatomic) BOOL isCapturingImages;
@property (assign, nonatomic) BOOL previewLayerIsInverted;

@property (strong,atomic) NSMutableDictionary* lastImageMetadata;

-(void)setupCameraWithPreview:(UIView*)view;
-(void)takeDownCamera;

-(void)takePicture;
-(void)lockFocus;
-(void)unlockFocus;
-(void)lockWhiteBalance;
-(void)unlockWhiteBalance;

-(void)setFocusWithPoint:(CGPoint)focusPoint;
-(void)setExposureLock:(BOOL)locked;

- (void)setRedGain:(float)redGain
         greenGain:(float)greenGain
          blueGain:(float)blueGain;
- (void)setFocusPosition:(float)position;
- (void)setExposureDuration:(float)durationMilliseconds ISO:(float)iso;


@end
