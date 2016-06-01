//
//  FliterObject.m
//  RestoOrder
//
//  Created by Suresh Kumar on 04/11/15.
//
//

#import "FilterObject.h"
#import "Constants.h"

@implementation FilterObject
@synthesize cuisineIndexes, cuisines,cuisinesArray,selectedIds, prevCuisineIndexes, prevSelectedIds, distanceCountStr,preDistanceCountStr;

static FilterObject *filterObject;

+(FilterObject *)sharedManager
{
    if (filterObject == nil)
    {
        filterObject = [[FilterObject alloc] init];
    }
    
    return filterObject;
}


-(void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:cuisines forKey:@"cuisines"];
    [encoder encodeObject:cuisineIndexes forKey:@"cuisineIndexes"];
    [encoder encodeObject:cuisinesArray forKey:@"cuisinesArray"];
    [encoder encodeObject:selectedIds forKey:@"selectedIds"];
    [encoder encodeObject:prevCuisineIndexes forKey:@"prevCuisineIndexes"];
    [encoder encodeObject:prevSelectedIds forKey:@"prevSelectedIds"];
    [encoder encodeObject:distanceCountStr forKey:@"distanceCountStr"];
    [encoder encodeObject:preDistanceCountStr forKey:@"preDistanceCountStr"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        
        cuisines = [decoder decodeObjectForKey:@"cuisines"];
        cuisineIndexes = [decoder decodeObjectForKey:@"cuisineIndexes"];
        cuisinesArray = [decoder decodeObjectForKey:@"cuisinesArray"];
        selectedIds = [decoder decodeObjectForKey:@"selectedIds"];
        prevCuisineIndexes = [decoder decodeObjectForKey:@"prevCuisineIndexes"];
        prevCuisineIndexes = [decoder decodeObjectForKey:@"prevCuisineIndexes"];
        distanceCountStr = [decoder decodeObjectForKey:@"distanceCountStr"];
        preDistanceCountStr = [decoder decodeObjectForKey:@"preDistanceCountStr"];
    }
    return self;
}

-(void)archiveFilterObject
{
    //archiving user detail object...
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"filterObject"];
    [NSKeyedArchiver archiveRootObject:self toFile:filePath];
}

-(void)unarchiveFilterObject
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"filterObject"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        FilterObject *filterObj = [[FilterObject alloc] init];
        filterObj = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        
        cuisines = filterObj.cuisines;
        cuisineIndexes = filterObj.cuisineIndexes;
        cuisinesArray = filterObj.cuisinesArray;
        selectedIds = filterObj.selectedIds;
        prevCuisineIndexes = filterObj.prevCuisineIndexes;
        prevSelectedIds = filterObj.prevSelectedIds;
        distanceCountStr = self.distanceCountStr;
        preDistanceCountStr = self.preDistanceCountStr;
    }
}

-(void)deleteArchivedFilterObject
{
    self.cuisines = nil;
    [self.cuisineIndexes removeAllObjects];
    [self.cuisinesArray removeAllObjects];
    [self.selectedIds removeAllObjects];
    [self.prevCuisineIndexes removeAllObjects];
    [self.prevSelectedIds removeAllObjects];
    self.distanceCountStr = nil;
    self.preDistanceCountStr = nil;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"filterObject"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
}


@end
