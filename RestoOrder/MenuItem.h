//
//  MenuItem.h
//  RestoOrder
//
//  Created by Suresh Kumar on 29/09/15.
//
//

#import <Foundation/Foundation.h>

@interface MenuItem : NSObject

@property(nonatomic, strong)NSString *itemName;
@property(nonatomic, strong)NSString *itemId;
@property(nonatomic, strong)NSString *isFavorite;
@property(nonatomic, strong)NSString *price;
@property(nonatomic, strong)NSString *shortDesc;
@property(nonatomic, strong)NSString *favoriteCreationDate;
@property(nonatomic, strong)NSString *categoryId;
@property(nonatomic, strong)NSArray *addonArray;
@property(nonatomic, strong)NSDictionary *restaurantDict;
@end
