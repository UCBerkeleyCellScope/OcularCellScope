//
//  ParseUploadManager.m
//  Ocular Cellscope
//
//  Created by Frankie Myers on 11/24/14.
//  Copyright (c) 2014 UC Berkeley Fletcher Lab. All rights reserved.
//


#import "ParseUploadManager.h"
#import "PopupMessage.h"

@implementation ParseUploadManager

int _totalNumberOfImagesToUpload = 0;
BOOL _queueIsProcessing = NO;

- (id) init
{
    self = [super init];
    if(self){
        
        
        self.reachability = [Reachability reachabilityForInternetConnection];
        [self.reachability startNotifier];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNetworkChange:) name:kReachabilityChangedNotification object:nil];
        
        self.imagesToUpload = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) handleNetworkChange:(NSNotification *)notice
{
    NetworkStatus remoteHostStatus = [self.reachability currentReachabilityStatus];
    if(remoteHostStatus == NotReachable) {CSLog(@"No Connection",@"SYSTEM");}
    else if (remoteHostStatus == ReachableViaWiFi) {CSLog(@"WiFi Connected",@"SYSTEM");}
    else if (remoteHostStatus == ReachableViaWWAN) {CSLog(@"Mobile Data Connected",@"SYSTEM");}
    
}

- (void) addExamToUploadQueue:(Exam*)exam
{

    
    if (self.reachability.currentReachabilityStatus==NotReachable) {
        [PopupMessage showPopup:@"Not Connected"];
        return;
    }
    
    
    //if (exam.uploaded.intValue!=0) {
        //TODO: handle this exam differently (it's already been uploaded/partially uploaded)
        //load the parseExam from Parse
        
        //for now, this just resets the uploaded flags on the exam and its images. eventually, we
        //want to have it associate these new exam updates + potentially new images with an existing record
        //exam.uploaded = 0;
        //for (EyeImage* ei in exam.eyeImages)
        //    ei.uploaded = 0;
    //}
    

    //this gets all the EyeImage objects for this exam
    NSArray* eyeImagesToAdd = [CoreDataController getEyeImagesToUploadForExam:exam];
    
    if (eyeImagesToAdd.count>0)
        exam.uploaded = @1; //upload "pending"
    else
        return;
    
    NSString* logmsg = [NSString stringWithFormat:@"Exam %d added to upload queue with %d images.",(int)exam.patientIndex,(int)eyeImagesToAdd.count];
    CSLog(logmsg, @"UPLOAD");
    
    
    [self.imagesToUpload addObjectsFromArray:eyeImagesToAdd];
    
    _totalNumberOfImagesToUpload += eyeImagesToAdd.count;
    
    if (_queueIsProcessing==NO)
        [self processUploadQueue];

}

//upload timeout in seconds
#define UPLOAD_TIMEOUT 30

- (void) processUploadQueue
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                
        _queueIsProcessing = YES;
        
        //process queue
        while (self.imagesToUpload.count>0) {
            EyeImage* nextImage = self.imagesToUpload[0];
            self.currentExam = nextImage.exam;
            
            //calculate progress and fire notification
            self.currentExamProgress = (float)[self.currentExam numberOfImagesUploaded]/(float)self.currentExam.eyeImages.count;
            self.overallProgress = 1 - ((float)self.imagesToUpload.count / (float)_totalNumberOfImagesToUpload); //calculate overall progress
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadProgressChangeNotification" object:nil];
            
            //upload "pending"
            nextImage.uploaded = @1;
            
            //trigger the upload. when it's done, it will set uploaded to 2 if success or 0 if fail
            [self uploadImage:nextImage];
            
            double startTimestamp = [[NSDate date] timeIntervalSince1970];
            
            //wait for upload to complete (need a timeout)
            while (nextImage.uploaded.intValue==1) {
                [NSThread sleepForTimeInterval:0.1];
                
                //timeout. if image never uploads, stop the queue
                if (([[NSDate date] timeIntervalSince1970] - startTimestamp)>UPLOAD_TIMEOUT) {
                    CSLog(@"Network timeout", @"UPLOAD");
                    [PopupMessage showPopup:@"Network Timeout"];
                    [self.imagesToUpload removeAllObjects];
                    self.currentExam = nil;
                    self.currentParseExam = nil;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[[CellScopeContext sharedContext] managedObjectContext] save:nil];
                    });
                    return;
                }
            }
            //dequeue this image
            [self.imagesToUpload removeObject:nextImage];
            
            //check to see if parent exam should also be marked as uploaded
            if ([self.currentExam numberOfImagesUploaded]==self.currentExam.eyeImages.count) {
                //all images have been uploaded for this exam, so update the overall exam upload status
                self.currentExam.uploaded = @2;
                self.currentExam = nil;
                self.currentParseExam = nil;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[CellScopeContext sharedContext] managedObjectContext] save:nil];
                });

            }

        }
        

        self.currentExam = nil;
        self.currentParseExam = nil;
        self.overallProgress = 1;
        self.currentExamProgress = 1;
        _totalNumberOfImagesToUpload = 0; //reset this
        _queueIsProcessing = NO;
        
        [self uploadLogWithCompletionHandler:nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadProgressChangeNotification" object:nil];
        
    });
    
    
}

- (void)uploadImage:(EyeImage *)eyeImage
{
    NSString* logmsg = [NSString stringWithFormat:@"Attempting Parse upload for photo with UUID: %@ ",eyeImage.uuid];
    CSLog(logmsg, @"UPLOAD");
    
    NSURL *aURL = [NSURL URLWithString: eyeImage.filePath];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:aURL
             resultBlock:^(ALAsset *asset)
     {
         ALAssetRepresentation* rep = [asset defaultRepresentation];
         
         NSUInteger size = (NSUInteger)rep.size;
         NSMutableData *imageData = [NSMutableData dataWithLength:size];
         NSError *error;
         [rep getBytes:imageData.mutableBytes fromOffset:0 length:size error:&error];
         
         
         [self uploadImageDataToParse:imageData
                         fromEyeImage:eyeImage
                    completionHandler:^(BOOL success, NSError* err) {
                        if (success) {
                            eyeImage.uploaded = @2; //mark as uploaded
                            CSLog(@"Image upload succeeded", @"UPLOAD");
                        }
                        else {
                            eyeImage.uploaded = @0; //mark as not uploaded
                            NSString* logmsg2 = [NSString stringWithFormat:@"Image upload failed with error: %@",err.description];
                            CSLog(logmsg2, @"UPLOAD");
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[[CellScopeContext sharedContext] managedObjectContext] save:nil];
                        });
                    }];
         
         //completion block should check for error, if error, set upload to 0, else 2, and save CD
         
     }
            failureBlock:^(NSError *error)
     {
         CSLog(@"Failure loading image from asset library", @"UPLOAD");
     }
     ];
}


- (void)uploadImageDataToParse:(NSData *)imageData fromEyeImage:(EyeImage*)ei completionHandler:(void(^)(BOOL,NSError*))completionBlock//add completion block
{
    
    PFFile *imageFile = [PFFile fileWithName:[NSString stringWithFormat:@"Image-%@-%d-%@-%d-%@.jpg",
                                                [[NSUserDefaults standardUserDefaults] stringForKey:@"cellscopeID"],
                                                ei.exam.patientIndex.intValue,
                                                ei.eye,
                                                ei.fixationLight.intValue,
                                                ei.uuid]
                                        data:imageData];
    
    // Save PFFile
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            
            // Create a PFObject around a PFFile and associate it with the current user
            PFObject *eyeImage = [PFObject objectWithClassName:@"EyeImage"];
            [eyeImage setObject:imageFile forKey:@"Image"];
            
            NSString* position;
            
            switch (ei.fixationLight.intValue) {
                case 1:
                    position = @"Central";
                    break;
                case 2:
                    position = @"Superior";
                    break;
                case 3:
                    position = @"Inferior";
                    break;
                case 4:
                    position = [ei.eye isEqualToString:@"OD"]?@"Temporal":@"Nasal";
                    break;
                case 5:
                    position = [ei.eye isEqualToString:@"OD"]?@"Nasal":@"Temporal";
                    break;
                default:
                    position = @"None";
                    break;
            }
            
            eyeImage[@"Eye"] = ei.eye;
            eyeImage[@"Position"] = position;
            eyeImage[@"appVersion"] = ei.appVersion;
            eyeImage[@"illumination"] = ei.illumination;
            eyeImage[@"focus"] = ei.focus;
            eyeImage[@"exposure"] = ei.exposure;
            eyeImage[@"iso"] = ei.iso;
            eyeImage[@"whiteBalance"] = ei.whiteBalance;
            eyeImage[@"flashDuration"] = ei.flashDuration;
            eyeImage[@"flashDelay"] = ei.flashDelay;
            
            
            // Set the access control list to current user for security purposes
            //eyeImage.ACL = [PFACL ACLWithUser:[PFUser currentUser]];
            
            [eyeImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
             {
                 if (!error) {
                     //TODO: pull the parse patient from the exam of this eyeImage
                     if (self.currentParseExam==nil) { //create one (or...search Parse DB to see if this record exists already)
                         
                         PFObject* parseExam;
                         
                         if(self.currentExam.uuid)
                         {
                             PFQuery *query = [PFQuery queryWithClassName:@"Patient"];
    
                             NSError* err;
                             parseExam = [query getObjectWithId:self.currentExam.uuid error:&err];
                             
                             if (err || parseExam==nil) { //error or empty object (assume it was deleted on server)
                                 self.currentExam.uuid = nil;
                                 self.currentExam.uploaded = @1;
                                 for (EyeImage* ei in self.currentExam.eyeImages) //reset all image upload flags
                                     ei.uploaded = @0;
                                 
                                 parseExam = [PFObject objectWithClassName:@"Patient"];
                             }
                         }
                         else
                         {
                             parseExam = [PFObject objectWithClassName:@"Patient"];
                         }
                         
                         parseExam[@"examID"] = self.currentExam.patientIndex;
                         parseExam[@"firstName"] = self.currentExam.firstName;
                         parseExam[@"lastName"] = self.currentExam.lastName;
                         parseExam[@"patientID"] = self.currentExam.patientID;
                         parseExam[@"phoneNumber"] = self.currentExam.phoneNumber;
                         if (self.currentExam.birthDate) {
                            parseExam[@"patientDOB"] = self.currentExam.birthDate;
                         }
                         parseExam[@"cellscope"] = [[NSUserDefaults standardUserDefaults] stringForKey:@"cellscopeID"];
                         parseExam[@"user"] = @"nouser";
                         parseExam[@"study"] = self.currentExam.studyName;
                         parseExam[@"examDate"] = self.currentExam.date;
                         parseExam[@"notes"] = self.currentExam.notes;
                         
                         
                         self.currentParseExam = parseExam;
                     }
                     
                     PFRelation *relation = [self.currentParseExam relationForKey:@"EyeImages"];
                     [relation addObject: eyeImage];
                     

                     //[self.currentParseExam saveInBackground]; //why is this not working w/ callback??
                     //need to get the UUID from this callback and save it to the eyeImage object, so that next time we generate this object we can refer to the correct one
                     //THEN call completionBlock
                     
                     //completionBlock(succeeded,nil);
                     
                     
                     [self.currentParseExam saveInBackgroundWithBlock:^(BOOL succeeded, NSError* error) {
                         
                         if (!error) {
                             self.currentExam.uuid = self.currentParseExam.objectId;
                             NSLog(@"uploaded with UUID %@",self.currentExam.uuid);
                             completionBlock(succeeded,nil);
                             
                         }
                         else
                             completionBlock(NO,error);
                         
                     }];
                     
                     

                     
                     /*
                      :^(BOOL succeeded, NSError *error)
                      {
                          if (!error)
                              completionBlock(succeeded,nil);
                          else
                              completionBlock(NO,error);
                      }];
                      */
                 }
                 else
                     completionBlock(NO,error);
             }];
        }
        else
            completionBlock(NO,error);
    } progressBlock:^(int percentDone) {} //file upload progress (not using this now)
    ];
    
    
}


//uploads any recent log entries to a new text file
- (void) uploadLogWithCompletionHandler:(void(^)(NSError*))completionBlock
{
    CSLog(@"Uploading log entries", @"UPLOAD");
    
    
    NSPredicate* pred = [NSPredicate predicateWithFormat:@"synced = nil"];
    NSArray* logEntries = [CoreDataController searchObjectsForEntity:@"Logs" withPredicate:pred andSortKey:@"date" andSortAscending:YES andContext:[[CellScopeContext sharedContext] managedObjectContext]];
    
    
    NSLog(@"LOG ENTRY COUNT %d",(int)logEntries.count);
    
    if (logEntries.count>0)
    {
        NSMutableArray* parseLogEntries = [[NSMutableArray alloc] init];
        NSString* cellscopeID = [[NSUserDefaults standardUserDefaults] stringForKey:@"cellscopeID"];
        for (Logs* logEntry in logEntries) {
            PFObject* parseLogEntry = [PFObject objectWithClassName:@"Logs"];
            parseLogEntry[@"entryDate"] = logEntry.date;
            parseLogEntry[@"category"] = logEntry.category;
            parseLogEntry[@"entry"] = logEntry.entry;
            parseLogEntry[@"cellscope"] = cellscopeID;
            [parseLogEntries addObject:parseLogEntry];
        }

        NSError* err;
        [PFObject saveAll:parseLogEntries error:&err];
        if (!err) {
            dispatch_async(dispatch_get_main_queue(), ^{
                for (Logs* logEntry in logEntries) {
                        logEntry.synced = @YES;
                        [[[CellScopeContext sharedContext] managedObjectContext] save:nil];

                };
            });
        }


        
    }
    
}

@end
