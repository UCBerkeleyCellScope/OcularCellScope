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

//static NSString * const CellScopeAPIKey = @"PASTE YOUR API KEY HERE";
static NSString * const CellScopeURLString = @"http://warm-dawn-6399.herokuapp.com/";
static NSString * const CellScopeURLString2 = @"http://localhost:5000/";

@implementation CellScopeHTTPClient

@synthesize imagesToUpload;
@synthesize mutableOperations;

/*
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
*/

//- (instancetype)initWithBaseURL:(NSURL *)url
- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    
    self.mutableOperations = [[NSMutableArray alloc]init];
    self.imagesToUpload = [[NSMutableArray alloc]init];
    
    if (self) {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver: self
           selector:@selector(addOnNextEyeImage:)
               name:@"OperationAdded" //The notification that was sent is named ____
             object:nil]; //doesn't matter who sent the notification
    
    return self;
}

-(void)addOnNextEyeImage:(NSNotification*) note{
    
    NSDictionary *extraInformation = [note userInfo];
    bool fired = FALSE;
    
    //if([ [extraInformation objectForKey:@"imagesLeft"] isEqualToNumber:0]){
    if ([imagesToUpload count]==0 && fired == FALSE){
        fired = TRUE;
        NSArray *operations = [AFURLConnectionOperation batchOfRequestOperations: mutableOperations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
            NSLog(@"%lu of %lu complete", (unsigned long)numberOfFinishedOperations, totalNumberOfOperations);
        } completionBlock:^(NSArray *operations) {
            NSLog(@"All operations in batch complete");
        }];
        [[NSOperationQueue mainQueue] addOperations:operations waitUntilFinished:NO];
    }
    
    else{
        [self singleImage];
    }
    
    //id poster = [note object];
    //NSString *name = [note name];

}

-(void)batch{
    [self singleImage];
}


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
    
         NSDictionary *parameters = @{  //@"date": [[[CellScopeContext sharedContext] currentExam] date],
                                        @"json": @1};
                                      //@"patientIndex": [[[CellScopeContext sharedContext] currentExam] patientIndex],
                                    
         NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
         [formatter setDateStyle: NSDateFormatterLongStyle];
         
         NSString *stringFromDate = [formatter stringFromDate:ei.date];
         
         NSURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:[NSString stringWithFormat:@"%@uploader",self.baseURL] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
         {
             //[formData appendPartWithFileURL:fileURL name:@"images[]" error:nil];
            [formData appendPartWithFileData: imageData name:@"file" fileName: stringFromDate mimeType: @"image/jpeg"];
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


