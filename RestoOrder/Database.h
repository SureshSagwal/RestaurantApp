//
//  Database.h
//  Delivery
//
//  Created by Suresh Kumar on 20/02/15.
//  Copyright (c) 2015 WebSnoox Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "MenuItem.h"

@interface Database : NSObject
{
    sqlite3 *database;
}

@property(nonatomic, assign) BOOL operationSucces;
@property(nonatomic, retain) NSMutableArray *dataArray;

+(Database *)sharedObject;

#pragma mark - Address Table

-(void)addNewAddressWithAddress1:(NSString *)address1 Address2:(NSString *)address2 pin:(NSString *)pincode is_Default:(int)isDefault;

-(void)updateAddressWithAddress1:(NSString *)address1 Address2:(NSString *)address2 pin:(NSString *)pincode is_Default:(int)isDefault AddressId:(int)addressId;

-(void)deleteAddressWithId:(int)addressId;

-(NSArray *)readAllAddresses;

-(void)deleteAllAddresses;


#pragma mark - CartTable

-(void)addNewProductWithName:(NSString *)productName server_Id:(NSString *)serverId quantity:(int)qty price:(double)price TotalPrice:(double)totalPrice addon_Ids:(NSString *)addonIds CategoryId:(NSString *)categoryId ItemDict:(NSString *)itemDict;

-(NSDictionary *)readProductWithId:(NSString *)serverId;

-(NSArray *)readAllProducts;

-(void)updateProductWithId:(int)productId quantity:(int)qty price:(double)price TotalPrice:(double)totalPrice addon_Ids:(NSString *)addonIds;

-(void)deleteProductWithId:(int)productId;

-(void)deleteAllProducts;


#pragma mark - Restaurant Detail Table

-(void)addNewRestaurantWithId:(NSString *)rId DetailDict:(NSString *)detailDict;
-(NSDictionary *)readRestaurantWithId:(NSString *)restaurantId;
-(NSDictionary *)readRestaurant;
//-(void)updateRestaurantDetailWithId:(NSString *)rId TotalPrice:(float)totalPrice CheckoutType:(int)checkoutType SubTotal:(float)subTotal VatPrice:(float)vatPrice TaxPrice:(float)vatPrice PaymentMode:(int)paymentMode OrderComments:(NSString *)comment TakeAwayTime:(NSString *)takeAwayTime ReserveaTableTime:(NSString *)reservationTableTime;
-(void)deleteRestaurantDetail;


@end
