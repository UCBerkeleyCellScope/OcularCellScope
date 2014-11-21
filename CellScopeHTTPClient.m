//
//  CellScopeHTTPClient.m
//  OcularCellscope
//
//  Created by PJ Loury on 4/28/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import "CellScopeHTTPClient.h"
#import "CoreDataController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "EyeImage+Methods.h"
#import "Exam+Methods.h"
#import <dispatch/dispatch.h>

//static NSString * const CellScopeAPIKey = @"PASTE YOUR API KEY HERE";
static NSString * const CellScopeURLString = @"http://ocswebapp.herokuapp.com/";
dispatch_queue_t backgroundQueue;

@implementation CellScopeHTTPClient

@synthesize imagesToUpload;
@synthesize mutableOperations;
@synthesize uploadBannerView;

+ (CellScopeHTTPClient *)sharedCellScopeHTTPClient
{
    static CellScopeHTTPClient *_sharedCellScopeHTTPClient = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedCellScopeHTTPClient = [[self alloc]
                                      initWithBaseURL:[NSURL URLWithString:CellScopeURLString]];
    });
    
    return _sharedCellScopeHTTPClient;
}

//- (instancetype)initWithBaseURL:(NSURL *)url
- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    
    self.mutableOperations = [[NSMutableArray alloc]init];
    self.imagesToUpload = [[NSMutableArray alloc]init];
    
    if (self) {
        //self.responseSerializer = [AFJSONResponseSerializer serializer];
        //self.requestSerializer = [AFJSONRequestSerializer serializer];

        self.responseSerializer = [AFHTTPResponseSerializer serializer];
        self.responseSerializer.acceptableContentTypes=[NSSet setWithObject:@"text/html"];
        
        //self.requestSerializer = [AFJSONRequestSerializer serializer];
        self.requestSerializer = [AFHTTPRequestSerializer serializer];

        //manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver: self
           selector:@selector(addOnNextEyeImage:)
               name:@"OperationAdded" //The notification that was sent is named ____
             object:nil]; //doesn't matter who sent the notification
    
    backgroundQueue = dispatch_queue_create("com.cellscope.httpclient.bgqueue", NULL);
    
    return self;
}

-(void)batch{
    [self.uploadBannerView setHidden:NO];
    
    [self postExam];
    
    //[self singleImageWithCallBack];
}

-(void)addOnNextEyeImage:(NSNotification*) note{
    
    //NSDictionary *extraInformation = [note userInfo];
    bool fired = FALSE;
    
    //if([ [extraInformation objectForKey:@"imagesLeft"] isEqualToNumber:0]){
    if ([imagesToUpload count]==0 && fired == FALSE){
        fired = TRUE;
        NSArray *operations = [AFURLConnectionOperation batchOfRequestOperations: mutableOperations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
            NSLog(@"%lu of %lu complete", (unsigned long)numberOfFinishedOperations,
                  (unsigned long)totalNumberOfOperations);
            uploadBannerView.uploadStatusLabel.text = [NSString stringWithFormat:
                                                       @"%lu of %lu complete", (unsigned long)numberOfFinishedOperations, (unsigned long)totalNumberOfOperations];
            
        } completionBlock:^(NSArray *operations) {
            NSLog(@"An Image has completed it's upload Process");
            //uploadBannerView.uploadStatusLabel.text = @"Upload Completed.";
            //[self.uploadBannerView takeBannerDownWithFade];
            
            
        }];
        //We're Adding these operations To the Main Queue All at once.
        // Would it be better to dispatch as async at this point?
        
        //AFURLConnectionOperation... it's not an e
        
        [[NSOperationQueue mainQueue] addOperations:operations waitUntilFinished:NO];
    }
    
    else{
        [self singleImage];
    }
    
    //id poster = [note object];
    //NSString *name = [note name];
    
}

- (void) postExam{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [[CellScopeContext sharedContext]currentExam].date= [NSDate date];
    
    
    NSLog(@"CurrentExam beforePOST %@",[[CellScopeContext sharedContext]currentExam]);
    NSLog(@"DateString beforePOST %@",[[[CellScopeContext sharedContext]currentExam] dateString]);
    
    NSDictionary *params = @{
                                 @"firstName":[[CellScopeContext sharedContext]currentExam].firstName,
                                 @"lastName":[[CellScopeContext sharedContext]currentExam].lastName,
                                 @"exam_uuid":[[CellScopeContext sharedContext]currentExam].uuid,
                                 @"date":
                                     [[[CellScopeContext sharedContext]currentExam] dateString]
                                 };
    
    //manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    [manager POST:[NSString stringWithFormat:@"%@exam",self.baseURL] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        [[[CellScopeContext sharedContext]currentExam] setUploaded:@YES];
        
        //NOT UPDATING TO EXAM CREATED
        self.uploadBannerView.hidden=NO;
        self.uploadBannerView.uploadStatusLabel.text=[NSString stringWithFormat:@"%@",responseObject];
        [self.uploadBannerView takeBannerDownWithFade];
        
        
        
        
        while([self.imagesToUpload count]>0){
            [self postImage2];
         }
        
        
        //[self singleImage];
        
        

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        self.uploadBannerView.hidden=NO;
        //self.uploadBannerView.uploadStatusLabel.text = [NSString stringWithFormat: @"Error: %@", error]; //
        //responseObject["status"]
        self.uploadBannerView.uploadStatusLabel.text = @"Connection Error";
        [self.uploadBannerView takeBannerDownWithFade];
    }];
}

/*
-(void)postImage{
    EyeImage* ei = [self.imagesToUpload objectAtIndex:0];
    NSURL *aURL = [NSURL URLWithString: ei.filePath];
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:aURL
             resultBlock:^(ALAsset *asset)
     {
         ALAssetRepresentation* rep = [asset defaultRepresentation];
         
         NSUInteger size = (NSUInteger)rep.size;
         NSMutableData *imageData = [NSMutableData dataWithLength:size];
         NSError *error;
         [rep getBytes:imageData.mutableBytes fromOffset:0 length:size error:&error];
         
         [uploadBannerView setHidden:NO];
         uploadBannerView.uploadStatusLabel.text=@"Uploading Single Image";
         
         NSDictionary *parameters = @{
                                      @"eye": ei.eye,
                                      @"fixationLight": ei.fixationLight,
                                      @"eyeImage_uuid":ei.uuid,
                                      @"exam_uuid":[[CellScopeContext sharedContext]currentExam].uuid,
                                      };
         
         NSURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:[NSString stringWithFormat:@"%@postImage",self.baseURL] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) //uploader
                                  {
                                      [formData appendPartWithFileData:imageData
                                                                  name:@"file"
                                                              fileName: ei.fileName
                                                              mimeType: @"image/jpeg"];
                                  }
                                                                                    error:nil];
         
         AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
         [mutableOperations addObject:operation];
         
         NSArray *operations = [AFURLConnectionOperation batchOfRequestOperations: mutableOperations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
             NSLog(@"%lu of %lu complete", (unsigned long)numberOfFinishedOperations,
                   (unsigned long)totalNumberOfOperations);
             uploadBannerView.uploadStatusLabel.text = [NSString stringWithFormat:
                                                        @"%lu of %lu complete", (unsigned long)numberOfFinishedOperations, (unsigned long)totalNumberOfOperations];
             
         } completionBlock:^(NSArray *operations) {
             NSLog(@"All operations in batch complete");
             uploadBannerView.uploadStatusLabel.text = @"Upload Completed.";
            [[CellScopeContext sharedContext]currentExam].uploaded = [NSNumber numberWithBool:YES];
 
             [self.uploadBannerView takeBannerDownWithFade ];
         }];
         
         [[NSOperationQueue mainQueue] addOperations:operations waitUntilFinished:NO];
     }
     
            failureBlock:^(NSError *error)
     {
         NSLog(@"failure loading video/image from AssetLibrary");
     }];
}
*/

-(void)postImage2{
    
    
    EyeImage* ei = [self.imagesToUpload objectAtIndex:0];
    [self.imagesToUpload removeObjectAtIndex:0];
    
    NSURL *aURL = [NSURL URLWithString: ei.filePath];
    
    NSLog(@"%@",ei.filePath);
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:aURL
             resultBlock:^(ALAsset *asset)
     {
         ALAssetRepresentation* rep = [asset defaultRepresentation];
         
         NSUInteger size = (NSUInteger)rep.size;
         NSMutableData *imageData = [NSMutableData dataWithLength:size];
         NSError *error;
         [rep getBytes:imageData.mutableBytes fromOffset:0 length:size error:&error];
         
         [uploadBannerView setHidden:NO];
         uploadBannerView.uploadStatusLabel.text=@"Uploading Single Image...";
         
         AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
         
         
         
         NSDictionary *params = @{
                                      @"eye": ei.eye,
                                      @"fixationLight": ei.fixationLight,
                                      @"eyeImage_uuid":ei.uuid,
                                      @"exam_uuid":[[CellScopeContext sharedContext]currentExam].uuid,
                                      @"date":[ei dateString]
                                      };
         
         
         //manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];

         [manager POST:[NSString stringWithFormat:@"%@uploader",self.baseURL] parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//             [formData appendPartWithFileData:imageData
//                                         name:@"file"
//                                        error:nil];
             
             [formData appendPartWithFileData:imageData
                                         name:@"file"
                                     fileName:ei.fileName
                                     mimeType:@"image/jpeg"];
         } success:^(AFHTTPRequestOperation *operation, id responseObject) {
             uploadBannerView.uploadStatusLabel.text = @"Single Image Uploaded.";
             [self.uploadBannerView takeBannerDownWithFade ];
             ei.uploaded = [NSNumber numberWithBool:YES];
             
             NSLog(@"Success: %@", responseObject);
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
             uploadBannerView.uploadStatusLabel.text = @"Single Image Upload Failed.";
             [self.uploadBannerView takeBannerDownWithFade ];
         }];
     }
     failureBlock:^(NSError *error)
     {
         NSLog(@"failure loading video/image from AssetLibrary");
     }
    ];
}

/*
-(void)uploadMultipleImagesWithTextMessageUsingAFNetworkingMultipartFormat:(id)sender {
    // Upload multiple images to server using multipartformatdata (AFNetworking)
    
    NSString *stringMessage = @"I am uploading multiple images to server";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //manager.parameterEncoding = AFJSONParameterEncoding;

    
    //AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL: [NSURL URLWithString:[NSString stringWithFormat:@"%@uploader",self.baseURL]]]; // replace BASEURL
    //client.parameterEncoding = AFJSONParameterEncoding;

    
                                 }
                                                                                           error:nil];
    
    
    
    NSMutableURLRequest *request2 = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:[NSString stringWithFormat:@"%@uploader",self.baseURL] parameters:nil constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        
        NSDictionary *parameters = @{
                                     @"eye": ei.eye,
                                     @"fixationLight": ei.fixationLight,
                                     @"eyeImage_uuid":ei.uuid,
                                     @"exam_uuid":[[CellScopeContext sharedContext]currentExam].uuid,
                                     @"json": @1};
        
        
        [formData appendPartWithFormData: 
         
         [[[NSUserDefaults standardUserDefaults] objectForKey:KServerAccessToken] dataUsingEncoding:NSUTF8StringEncoding] name:@"AccessToken"];
        
        [formData appendPartWithFormData:[stringMessage dataUsingEncoding:NSUTF8StringEncoding] name:@"PostText"];
        
        // arrayChosenImages is NSArray of UIImage to be uploaded
        for (int i=0; i<[arrayChosenImages count]; i++) {
            [formData appendPartWithFileData:UIImageJPEGRepresentation([arrayChosenImages objectAtIndex:i], 0.5)
                                        name:[NSString stringWithFormat:@"image%d",i]
                                    fileName:[NSString stringWithFormat:@"image%d.jpg",i]
                                    mimeType:@"image/jpeg"];
        }
    } error: nil];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long totalBytesWritten, long totalBytesExpectedToWrite) {
        float uploadPercentge = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
        float uploadActualPercentage = uploadPercentge * 100;
        NSLog(@"Sent %ld of %ld bytes", totalBytesWritten, totalBytesExpectedToWrite);
        NSLog(@"Multipartdata upload in progress: %@",[NSString stringWithFormat:@"%.2f %%",uploadActualPercentage]);
        if (uploadActualPercentage >= 100) {
            NSLog(@"Waitting for response ...");
        }
        //progressBar.progress = uploadPercentge; //  progressBar is UIProgressView to show upload progress
    }];
    [client enqueueHTTPRequestOperation:operation];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *dataResponseJSON = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dictResponseJSON = [NSJSONSerialization JSONObjectWithData:dataResponseJSON options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"PostMultImagesWithTextAPI API Response: %@", dictResponseJSON);
    }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         NSLog(@"PostMultImagesWithTextAPI API failed with error: %@", operation.responseString);
                                     }];
    [operation start];
}

*/


- (void)singleImage{
    
    EyeImage* ei = [self.imagesToUpload objectAtIndex:0];
    [self.imagesToUpload removeObjectAtIndex:0];
    
    NSURL *aURL = [NSURL URLWithString: ei.filePath];
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:aURL
             resultBlock:^(ALAsset *asset)
     {
         ALAssetRepresentation* rep = [asset defaultRepresentation];
         
         NSUInteger size = (NSUInteger)rep.size;
         NSMutableData *imageData = [NSMutableData dataWithLength:size];
         NSError *error;
         [rep getBytes:imageData.mutableBytes fromOffset:0 length:size error:&error];
         
         //[[CellScopeContext sharedContext]currentExam].firstName
         
         NSDictionary *params = @{
                                  @"eye": ei.eye,
                                  @"fixationLight": ei.fixationLight,
                                  @"eyeImage_uuid":ei.uuid,
                                  @"exam_uuid":[[CellScopeContext sharedContext]currentExam].uuid,
                                  @"date":[ei dateString]
                                  };
         //@"patientIndex": [[[CellScopeContext sharedContext] currentExam] patientIndex],
         
         NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
         [formatter setDateStyle: NSDateFormatterLongStyle];
         
         //NSString *stringFromDate = [formatter stringFromDate:ei.date];
         
         NSURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:[NSString stringWithFormat:@"%@uploader",self.baseURL] parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
                                  {
                                      //[formData appendPartWithFileURL:fileURL name:@"images[]" error:nil];
                                      [formData appendPartWithFileData:imageData
                                                                  name:@"file"
                                                              fileName:ei.fileName
                                                              mimeType:@"image/jpeg"];

                                      
                                      /*
                                      [formData appendPartWithFileData:ei.thumbnail
                                                                  name:@"thumbnail"
                                                              fileName: [ei.fileName stringByAppendingString:@"-thumbnail"]
                                                              mimeType: @"image/jpeg"];
                                       */
                                      
                                  }
                                                                                                error:nil];
         
         AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
         [mutableOperations addObject:operation];
         
         NSNumber* obj = [NSNumber numberWithInteger:[imagesToUpload count]];
         
         NSDictionary *extraInfo = [NSDictionary dictionaryWithObject:obj forKey:@"imagesLeft"];
         NSNotification *note = [NSNotification notificationWithName:@"OperationAdded" object:self userInfo:extraInfo];
         [[NSNotificationCenter defaultCenter] postNotification: note];
     }
     
            failureBlock:^(NSError *error)
     {
         NSLog(@"failure loading video/image from AssetLibrary");
     }];
}

- (void)updateDiagnosisForExam:(Exam *)exam
{
    NSMutableDictionary *parameters = nil;
    //[NSMutableDictionary dictionary];
    
    //parameters[@"num_of_days"] = @(number);
    //parameters[@"q"] = [NSString stringWithFormat:@"%f,%f",location.coordinate.latitude,location.coordinate.longitude];
    parameters[@"format"] = @"json";
    //parameters[@"key"] = CellScopeAPIKey;
    
    NSLog(@"Attempting to send a GET to update diagnosis");
    [self GET:@"diagnosis" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([self.delegate respondsToSelector:@selector(cellScopeHTTPClient:didUpdateDiagnosis:)]) {
            [self.delegate cellScopeHTTPClient:self didUpdateDiagnosis:responseObject];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if ([self.delegate respondsToSelector:@selector(cellScopeHTTPClient:didFailWithError:)]) {
            [self.delegate cellScopeHTTPClient:self didFailWithError:error];
        }
    }];
}


- (void)uploadEyeImagesPJ:(NSArray *)images{
    EyeImage *ei = [images firstObject];
    
    NSURL *aURL = [NSURL URLWithString: ei.filePath];
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:aURL resultBlock:^(ALAsset *asset)
     {
         ALAssetRepresentation* rep = [asset defaultRepresentation];
         
         NSUInteger size = (NSUInteger)rep.size;
         NSMutableData *imageData = [NSMutableData dataWithLength:size];
         NSError *error;
         [rep getBytes:imageData.mutableBytes fromOffset:0 length:size error:&error];
         
         //AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
         
         NSDictionary *parameters = @{//@"mrn": [[[CellScopeContext sharedContext] currentExam] patientID],
                                      @"date": [[[CellScopeContext sharedContext] currentExam] date],
                                      @"json": @1};
         NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
         [formatter setDateStyle: NSDateFormatterLongStyle];
         
         NSString *stringFromDate = [formatter stringFromDate:ei.date];
         
         // NSString *urlString = [[NSURL URLWithString:@"uploader" relativeToURL:self.baseURL] absoluteString];
         
         [self POST:@"uploader" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
             [formData appendPartWithFileData:imageData name:@"file" fileName:stringFromDate mimeType:@"image/jpeg"];
         } success:^(NSURLSessionDataTask *task, id responseObject) {
             NSLog(@"Success: %@", responseObject);
         } failure:^(NSURLSessionDataTask *task, NSError *error) {
             NSLog(@"Error: %@", error);
         }];
         
         //         NSMutableURLRequest *request = [self.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:parameters constructingBodyWithBlock:^(id <AFMultipartFormData> formData) {
         //             [formData appendPartWithFileData:imageData name:@"file" fileName:stringFromDate mimeType:@"image/jpeg"];
         //         }];
         //
         //         NSURLSessionUploadTask *task = [self uploadTaskWithStreamedRequest:request progress:progress completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
         //             if (error) {
         //                 if (failure) failure(error);
         //             } else {
         //                 if (success) success(responseObject);
         //             }
         //         }];
         //         [task resume];
         
         //        [self POST:@"uploader" parameters:parameters
         //            constructingBodyWithBlock: ^(id<AFMultipartFormData> formData) {
         //              [formData appendPartWithFileData: imageData name:@"file" fileName: stringFromDate mimeType: @"image/jpeg"];
         //            }
         //            success:^(AFHTTPRequestOperation *operation, id responseObject) {
         //               NSLog(@"Success: %@", responseObject);
         //            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         //               NSLog(@"Error: %@", error);
         //            }
         //        ];
         
     }
     
            failureBlock:^(NSError *error)
     {
         NSLog(@"failure loading video/image from AssetLibrary");
     }];
}

- (void)uploadEyeImagesFromArray:(NSArray *)images{
    for (EyeImage* ei in images){
        
        //UIImage* uim = [CoreDataController getUIImageFromCameraRoll:(NSString*)
        //           eyeImage1.filePath];
        
        NSURL *aURL = [NSURL URLWithString: ei.filePath];
        
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:aURL resultBlock:^(ALAsset *asset)
         {
             ALAssetRepresentation* rep = [asset defaultRepresentation];
             
             NSUInteger size = (NSUInteger)rep.size;
             NSMutableData *imageData = [NSMutableData dataWithLength:size];
             NSError *error;
             [rep getBytes:imageData.mutableBytes fromOffset:0 length:size error:&error];
             
             AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
             
             NSDictionary *parameters = @{//@"mrn": [[[CellScopeContext sharedContext] currentExam] patientID],
                                          @"date": [[[CellScopeContext sharedContext] currentExam] date],
                                          @"json": @1};
             
             NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
             [formatter setDateStyle: NSDateFormatterLongStyle];
             
             NSString *stringFromDate = [formatter stringFromDate:ei.date];
             
             //Uses RequestOperationManager
             [manager POST:[NSString stringWithFormat:@"%@uploader",self.baseURL] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                 
                 [formData appendPartWithFileData: imageData name:@"file" fileName: stringFromDate mimeType: @"image/jpeg"];
                 
                 //[[NSURL URLWithString:@"uploader" relativeToURL:self.baseURL] absoluteString]
                 
                 
             } success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 NSLog(@"Success: %@", responseObject);
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 NSLog(@"Error: %@", error);
             }];
             
             
             /**
              Appends the HTTP header `Content-Disposition: file; filename=#{filename}; name=#{name}"` and `Content-Type: #{mimeType}`, followed by the encoded file data and the multipart form boundary.
              
              @param data The data to be encoded and appended to the form data.
              @param name The name to be associated with the specified data. This parameter must not be `nil`.
              @param fileName The filename to be associated with the specified data. This parameter must not be `nil`.
              @param mimeType The MIME type of the specified data. (For example, the MIME type for a JPEG image is image/jpeg.) For a list of valid MIME types, see http://www.iana.org/assignments/media-types/. This parameter must not be `nil`.
              */
             
             
             //CGImageRef iref = [rep fullResolutionImage];
             //UIImage* uim = [UIImage imageWithCGImage:iref];
             
             
         }
                failureBlock:^(NSError *error)
         {
             NSLog(@"failure loading video/image from AssetLibrary");
         }];
    }
    
}



@end


