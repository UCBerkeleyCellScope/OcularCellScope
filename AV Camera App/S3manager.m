//
//  S3manager.m
//  OcularCellscope
//
//  Created by PJ Loury on 5/30/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import "S3manager.h"
#import "Constants.h"

#import <AWSRuntime/AWSRuntime.h>

@implementation S3manager

-(id)init{
    self = [super init];
    if(self){
        if(![ACCESS_KEY_ID isEqualToString:@"CHANGE ME"]
           && self.s3 == nil)
        {
            // Initialize the S3 Client.
            //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            // This sample App is for demonstration purposes only.
            // It is not secure to embed your credentials into source code.
            // DO NOT EMBED YOUR CREDENTIALS IN PRODUCTION APPS.
            // We offer two solutions for getting credentials to your mobile App.
            // Please read the following article to learn about Token Vending Machine:
            // * http://aws.amazon.com/articles/Mobile/4611615499399490
            // Or consider using web identity federation:
            // * http://aws.amazon.com/articles/Mobile/4617974389850313
            //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            self.s3 = [[AmazonS3Client alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY] ;
            self.s3.endpoint = [AmazonEndpoints s3Endpoint:US_WEST_2];
            
            // Create the picture bucket.
            S3CreateBucketRequest *createBucketRequest = [[S3CreateBucketRequest alloc] initWithName:[Constants pictureBucket] andRegion:[S3Region USWest2]];
            S3CreateBucketResponse *createBucketResponse = [self.s3 createBucket:createBucketRequest];
            if(createBucketResponse.error != nil)
            {
                NSLog(@"Error: %@", createBucketResponse.error);
            }
        }

    }
    return self;
}

- (void)processGrandCentralDispatchUpload:(NSData *)imageData
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        // Upload image data.  Remember to set the content type.
        S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:PICTURE_NAME
                                                                  inBucket:[Constants pictureBucket]];
        por.contentType = @"image/jpeg";
        por.data        = imageData;
        
        // Put the image data into the specified s3 bucket and object.
        S3PutObjectResponse *putObjectResponse = [self.s3 putObject:por];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(putObjectResponse.error != nil)
            {
                NSLog(@"Error: %@", putObjectResponse.error);
                [self showAlertMessage:[putObjectResponse.error.userInfo objectForKey:@"message"] withTitle:@"Upload Error"];
            }
            else
            {
                [self showAlertMessage:@"The image was successfully uploaded." withTitle:@"Upload Completed"];
            }
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
    });
}


-(void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response
{
    [self showAlertMessage:@"The image was successfully uploaded." withTitle:@"Upload Completed"];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

-(void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", error);
    [self showAlertMessage:error.description withTitle:@"Upload Error"];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)showAlertMessage:(NSString *)message withTitle:(NSString *)title
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                         message:message
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
    [alertView show];
}

@end
