//
//  ImageStore.m
//  Homepwner
//
//  Created by PJ Loury on 1/5/14.
//  Copyright (c) 2014 com.bignerdranch. All rights reserved.
//

#import "ImageStore.h"


@implementation ImageStore

//the accessor and the field have the same name

+ (id) allocWithZone:(struct _NSZone *)zone
{
    return [self sharedStore];
}

+(ImageStore *)sharedStore
{
    static ImageStore *sharedStore = nil;
    if (!sharedStore){
        sharedStore = [[super allocWithZone:NULL] init]; //
    }
    
    return sharedStore;
    
}

-(id)init
{
    self = [super init];
    if(self){
        dictionary = [[NSMutableDictionary alloc] init];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(clearCache:)
                   name: UIApplicationDidReceiveMemoryWarningNotification
                 object:nil];
    
        //if any object passes ImageStore the message that a memory warning occured
        //then the ImageStore should execute clearCache:
        
    }
    
    return self;
}


-(void)setImage:(UIImage *) i forKey: (NSString *) s
{
    [dictionary setObject: i forKey: s];
    
    //SAVE RIGHT AWAY because you don't want to keep the image in memory!
    
    //Create full path for image
    NSString *imagePath = [self  imagePathForKey:s];
    
    NSData *d = UIImageJPEGRepresentation(i, 0.5); //takes an image and a compression quality
    
    [d writeToFile: imagePath atomically:YES]; //send d the message writeToFile..
    //atomically is the Boolean value yes, temporary , rename to the path imagePath
    //writing atomically prevents file corruption
    
    //This kind of writing is NOT archiving
    //NSData instances CAN be archived but writeToFile:atomically is a binary write
    
    
}

-(UIImage *)imageForKey: (NSString *)s
{
    //return [dictionary objectForKey: s];
    
    UIImage *result = [dictionary objectForKey:s];
    
    if(!result){
        //create UIImage object from file instead
        result = [UIImage imageWithContentsOfFile:[self imagePathForKey:s]];
        
        if(result)
            [dictionary setObject:result forKey:s]; //now it's in the cache, faster access times!
        else
            NSLog(@"Error: unable to find %@", [self imagePathForKey:s]);
    }
    
    return result;
    
}

-(void)deleteImageForKey:(NSString *)s
{
        if(!s)
            return;
        [dictionary removeObjectForKey:s];
    
    NSString *path = [self imagePathForKey:s];
    [[NSFileManager defaultManager]removeItemAtPath:path error:NULL];

}


-(NSString *)imagePathForKey:(NSString *)key
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    //create a string path using a given key
    
    return [documentDirectory stringByAppendingPathComponent:key];
    
}


-(void)clearCache:(NSNotification *)note
{
    NSLog(@"flushing %d images out of the cache", [dictionary count]);
    [dictionary removeAllObjects];
    //But don't delete from the file system!
    //flushing the cache causes all the images to lose an owner
    //Images that aren't being used by other objects are destroyed
    
    //Apparently this will only remove the items that don't have an owner??
    
}


@end
