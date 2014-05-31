//
//  S3manager.h
//  OcularCellscope
//
//  Created by PJ Loury on 5/30/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <AWSS3/AWSS3.h>

typedef enum {
    GrandCentralDispatch,
    Delegate,
    BackgroundThread
} UploadType;

@interface S3manager:NSObject<AmazonServiceRequestDelegate> {
    UploadType _uploadType;
}

@property (nonatomic, retain) AmazonS3Client *s3;
/*
-(void)uploadPhotoWithGrandCentralDispatch:(id)sender;
-(void)uploadPhotoWithDelegate:(id)sender;
-(void)uploadPhotoWithBackgroundThread:(id)sender;
-(void)showInBrowser:(id)sender;
*/
- (void)processGrandCentralDispatchUpload:(NSData *)imageData;

@end