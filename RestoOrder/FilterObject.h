//
//  FliterObject.h
//  RestoOrder
//
//  Created by Suresh Kumar on 04/11/15.
//
//

#import <Foundation/Foundation.h>

@interface FilterObject : NSObject
{
    
}
@property(nonatomic, strong)NSString *cuisines;
@property(nonatomic, strong)NSString *distanceCountStr;
@property(nonatomic, strong)NSString *preDistanceCountStr;
@property(nonatomic, strong)NSMutableArray *cuisineIndexes;
@property(nonatomic, strong)NSMutableArray *cuisinesArray;
@property(nonatomic, strong)NSMutableArray *selectedIds;
@property(nonatomic, strong)NSMutableArray *prevSelectedIds;
@property(nonatomic, strong)NSMutableArray *prevCuisineIndexes;


+(FilterObject *)sharedManager;

-(void)archiveFilterObject;
-(void)unarchiveFilterObject;
-(void)deleteArchivedFilterObject;

@end
