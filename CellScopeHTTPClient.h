//
//  CellScopeHTTPClient.h
//  OcularCellscope
//
//  Created by PJ Loury on 4/28/14.
//  Copyright (c) 2014 NAYA LOUMOU. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import "CellScopeContext.h"

@protocol CellScopeHTTPClientDelegate;

@interface CellScopeHTTPClient : AFHTTPSessionManager
@property (nonatomic, weak) id<CellScopeHTTPClientDelegate>delegate;

+ (CellScopeHTTPClient *)sharedCellScopeHTTPClient;
- (instancetype)initWithBaseURL:(NSURL *)url;
- (void)updateDiagnosisForExam:(Exam *)exam;
- (void)uploadEyeImagesForExam:(Exam *)exam;

@end

@protocol CellScopeHTTPClientDelegate <NSObject>
@optional
-(void)cellScopeHTTPClient:(CellScopeHTTPClient *)client didUpdateDiagnosis:(id)diagnosis;
-(void)cellScopeHTTPClient:(CellScopeHTTPClient *)client didFailWithError:(NSError *)error;
-(void)cellScopeHTTPClient:(CellScopeHTTPClient *)client didUploadEyeImage:(id)eyeImage;

@end