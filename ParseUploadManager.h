//
//  ParseUploadManager.h
//  Ocular Cellscope
//
//  Created by Frankie Myers on 11/24/14.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "Exam.h"
#import "Exam+Methods.h"
#import "CoreDataController.h"
#import "CellScopeContext.h"
#import "Reachability.h"

@interface ParseUploadManager : NSObject

@property (strong,nonatomic) NSMutableArray *imagesToUpload;
@property (nonatomic) float overallProgress;
@property (nonatomic) float currentExamProgress;
@property (strong,nonatomic) Exam* currentExam;
@property (strong,nonatomic) PFObject* currentParseExam;

@property (strong, nonatomic) Reachability* reachability;

- (void) addExamToUploadQueue:(Exam*)exam;

@end
