//
//  CellScopeHTTPClient.m
//  OcularCellscope
//
//  Created by PJ Loury on 4/28/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import "CellScopeHTTPClient.h"

//static NSString * const CellScopeAPIKey = @"PASTE YOUR API KEY HERE";
static NSString * const CellScopeURLString = @"http://warm-dawn-6399.herokuapp.com/";

@implementation CellScopeHTTPClient

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

- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    
    if (self) {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    
    return self;
}



- (void)updateDiagnosisForExam:(Exam *)exam
{
    NSMutableDictionary *parameters = nil;
    //[NSMutableDictionary dictionary];
    
    //parameters[@"num_of_days"] = @(number);
    //parameters[@"q"] = [NSString stringWithFormat:@"%f,%f",location.coordinate.latitude,location.coordinate.longitude];
    //parameters[@"format"] = @"json";
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

- (void)uploadEyeImagesForExam:(Exam *)exam{
    
}

@end


