//
//  CellScopeContext.h
//  edscope
//
//  Created by Frankie Myers on 11/29/13.
//  Copyright (c) 2013 UC Berkeley Fletcher Lab. All rights reserved.
//

@interface CellScopeContext : NSObject

//TODO: add managed object context, session, etc.
@property (nonatomic, retain) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, retain) NSString* flickrUsername;
@property (nonatomic, retain) NSString* flickrUserID;
@property (nonatomic, retain) NSString* studentName;
@property (nonatomic, retain) NSString* groupName;

+ (id)sharedContext;

@end
