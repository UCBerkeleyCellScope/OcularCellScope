//
//  CoreDataController.m
//  AV Camera App
//
//  Created by NAYA LOUMOU on 11/24/13.
//  Copyright (c) 2013 UC Berkeley Ocular CellScope. All rights reserved.
//

#import "CoreDataController.h"
#import "CellScopeContext.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation CoreDataController

#pragma mark - Retrieve objects

+(UIImage*)getUIImageFromCameraRoll:(NSString*)filePath{
    
    NSURL *aURL = [NSURL URLWithString: filePath];
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:aURL resultBlock:^(ALAsset *asset)
     {
         //ALAssetRepresentation* rep = [asset defaultRepresentation];
         //CGImageRef iref = [rep fullResolutionImage];
         //UIImage* uim = [UIImage imageWithCGImage:iref];
         //return uim;
         
     }
    failureBlock:^(NSError *error)
     {
         NSLog(@"failure loading video/image from AssetLibrary");
     }];

    UIImage* uim;
    return uim;
    
 }

void(^foo)(void);

//UIImage* (^picGrabber)(ALAsset *asset);
// ^pic is a pointer to a block
// *pic is a pointer to an object

UIImage*(^picGrabber)(ALAsset *garbage) = ^UIImage*(ALAsset *asset){
    ALAssetRepresentation* rep = [asset defaultRepresentation];
    CGImageRef iref = [rep fullResolutionImage];
    UIImage* uim = [UIImage imageWithCGImage:iref];
    return uim;
};

/*
resultBlock:^(ALAsset *asset)
{
    ALAssetRepresentation* rep = [asset defaultRepresentation];
    CGImageRef iref = [rep fullResolutionImage];
    UIImage* uim = [UIImage imageWithCGImage:iref];
    //return uim;
    
};

failureBlock:^(NSError *error)
{
    NSLog(@"failure loading video/image from AssetLibrary");
};

*/


+(NSArray*)getEyeImagesForExam:(Exam*)exam{

    NSPredicate *p = [NSPredicate predicateWithFormat: @"exam == %@", exam];
    NSArray* examImages = [CoreDataController searchObjectsForEntity:@"EyeImage" withPredicate: p
                                    andSortKey: @"date" andSortAscending: YES
                                    andContext:   [[CellScopeContext sharedContext] managedObjectContext]];
    return examImages;
}

+(NSArray*)getEyeImagesToUploadForExam:(Exam*)exam{
    
    NSPredicate *p = [NSPredicate predicateWithFormat: @"exam == %@ AND uploaded == %@", exam, [NSNumber numberWithBool:NO]];
    NSArray* examImages = [CoreDataController searchObjectsForEntity:@"EyeImage" withPredicate: p
                                                          andSortKey: @"date" andSortAscending: YES
                                                          andContext:   [[CellScopeContext sharedContext] managedObjectContext]];
    return examImages;
}


// Fetch objects with a predicate
+(NSMutableArray *)searchObjectsForEntity:(NSString*)entityName withPredicate:(NSPredicate *)predicate andSortKey:(NSString*)sortKey andSortAscending:(BOOL)sortAscending andContext:(NSManagedObjectContext *)managedObjectContext
{
	// Create fetch request
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                   inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
    
	// If a predicate was specified then use it in the request
	if (predicate != nil)
		[request setPredicate:predicate];
    
	// If a sort key was passed then use it in the request
	if (sortKey != nil) {
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:sortAscending];
		NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
		[request setSortDescriptors:sortDescriptors];
	}
    
	// Execute the fetch request
	NSError *error = nil;
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
	// If the returned array was nil then there was an error
	if (mutableFetchResults == nil)
		NSLog(@"Couldn't get objects for entity %@", entityName);
    
	// Return the results
	return mutableFetchResults;
}

/*
// Fetch objects with a predicate and a fetchLimit
+(NSMutableArray *)searchObjectsForEntity:(NSString*)entityName withPredicate:(NSPredicate *)
                    predicate andSortKey:(NSString*)sortKey
                         andSortAscending:(BOOL)sortAscending
                            andFetchLimit:(NSUInteger) fetchLimit
                               andContext:(NSManagedObjectContext *)managedObjectContext
{
	// Create fetch request
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                              inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
    [request setFetchLimit:fetchLimit];
    
	// If a predicate was specified then use it in the request
	if (predicate != nil)
		[request setPredicate:predicate];
    
	// If a sort key was passed then use it in the request
	if (sortKey != nil) {
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:sortAscending];
		NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
		[request setSortDescriptors:sortDescriptors];
	}
    
	// Execute the fetch request
	NSError *error = nil;
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
	// If the returned array was nil then there was an error
	if (mutableFetchResults == nil)
		NSLog(@"Couldn't get objects for entity %@", entityName);
    
	// Return the results
	return mutableFetchResults;
}

*/

// Fetch objects without a predicate
+(NSMutableArray *)getObjectsForEntity:(NSString*)entityName withSortKey:(NSString*)sortKey andSortAscending:(BOOL)sortAscending andContext:(NSManagedObjectContext *)managedObjectContext
{
	return [self searchObjectsForEntity:entityName withPredicate:nil andSortKey:sortKey andSortAscending:sortAscending andContext:managedObjectContext];
}

#pragma mark - Count objects

// Get a count for an entity with a predicate
+(NSUInteger)countForEntity:(NSString *)entityName withPredicate:(NSPredicate *)predicate andContext:(NSManagedObjectContext *)managedObjectContext
{
	// Create fetch request
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	[request setIncludesPropertyValues:NO];
    
	// If a predicate was specified then use it in the request
	if (predicate != nil)
		[request setPredicate:predicate];
    
	// Execute the count request
	NSError *error = nil;
	NSUInteger count = [managedObjectContext countForFetchRequest:request error:&error];
    
	// If the count returned NSNotFound there was an error
	if (count == NSNotFound)
		NSLog(@"Couldn't get count for entity %@", entityName);
    
	// Return the results
	return count;
}

// Get a count for an entity without a predicate
+(NSUInteger)countForEntity:(NSString *)entityName andContext:(NSManagedObjectContext *)managedObjectContext
{
	return [self countForEntity:entityName withPredicate:nil andContext:managedObjectContext];
}

#pragma mark - Delete Objects

// Delete all objects for a given entity
+(BOOL)deleteAllObjectsForEntity:(NSString*)entityName withPredicate:(NSPredicate*)predicate andContext:(NSManagedObjectContext *)managedObjectContext
{
	// Create fetch request
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
    
	// Ignore property values for maximum performance
	[request setIncludesPropertyValues:NO];
    
	// If a predicate was specified then use it in the request
	if (predicate != nil)
		[request setPredicate:predicate];
    
	// Execute the count request
	NSError *error = nil;
	NSArray *fetchResults = [managedObjectContext executeFetchRequest:request error:&error];
    
	// Delete the objects returned if the results weren't nil
	if (fetchResults != nil) {
		for (NSManagedObject *manObj in fetchResults) {
			[managedObjectContext deleteObject:manObj];
		}
	} else {
		NSLog(@"Couldn't delete objects for entity %@", entityName);
		return NO;
	}
    
	return YES;
}

+(BOOL)deleteAllObjectsForEntity:(NSString*)entityName andContext:(NSManagedObjectContext *)managedObjectContext
{
	return [self deleteAllObjectsForEntity:entityName withPredicate:nil andContext:managedObjectContext];
}

@end