//
//  Restaurant.h
//  RestoOrder
//
//  Created by Suresh Kumar on 25/09/15.
//
//

#import <Foundation/Foundation.h>

@interface Restaurant : NSObject

@property(nonatomic, strong)NSString *name;
@property(nonatomic, strong)NSString *Id;
@property(nonatomic, strong)NSString *isFavorite;
@property(nonatomic, strong)NSString *ImageUrl;
@property(nonatomic, strong)NSString *logoUrl;
@property(nonatomic, strong)NSString *address;
@property(nonatomic, strong)NSString *contactNo;
@property(nonatomic, strong)NSString *distance;
@property(nonatomic, strong)NSString *rateCount;
@property(nonatomic, strong)NSString *isOpen;
@property(nonatomic, strong)NSString *minimumOrder;
@property(nonatomic, strong)NSString *deliveryTime;
@property(nonatomic, strong)NSString *serviceTax;
@property(nonatomic, strong)NSString *vat;
@property(nonatomic, strong)NSString *cardTypes;
@property(nonatomic, strong)NSString *defaultTakeAwayTime;
@property(nonatomic, strong)NSString *defaultReserveaTableTime;
@property(nonatomic, strong)NSString *defaultDeliveryTime;
@property(nonatomic, strong)NSString *latitude;
@property(nonatomic, strong)NSString *longitude;
@property(nonatomic, strong)NSString *favoriteCreationDate;
@property(nonatomic, strong)NSString *isLocallySaved;
@property(nonatomic, strong)NSString *openingHours;
@property(nonatomic, strong)NSString *closingHours;
@property(nonatomic, strong)NSString *restaurantType;
@property(nonatomic, strong)NSString *maxAmount;
@property(nonatomic, strong)NSString *maxQty;

@end
