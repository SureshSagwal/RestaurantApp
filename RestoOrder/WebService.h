//
//  WebService.h
//  Delivery_Runner
//
//  Created by Suresh Kumar on 02/02/15.
//  Copyright (c) 2015 WebSnoox Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol WebServiceDelegate <NSObject>

@optional

-(void)serviceFinishedWithResult:(id)result API_Index:(NSInteger)index;
-(void)serviceFinishedWithResponse:(id)response API_Index:(NSInteger)index;
-(void)serviceFinishedWithError:(id)error API_Index:(NSInteger)index;

@end

@interface WebService : NSObject
{
    
}

typedef NS_ENUM(NSInteger, API_TYPE)
{
    LOGIN_API = 1,
    SIGNUP_API = 2,
    UPDATE_USER_INFO_API = 3,
    UPDATE_USER_LOCATION_API = 4,
    CHANGE_PASSWORD_API = 5,
    FORGOT_PASSWORD_API = 6,
    
    RESTAURANT_CATEGORIES_API = 7,
    RESTAURANT_DETAILS_API = 8,
    ORDER_HISTORY_API = 9,
    CREATE_ORDER_API = 10,
    FIND_RESTAURANTS_API = 11,          // nearby, favorite, by location
    CATEGORY_MENU_API = 12,
    
    FAVORITE_LOCATION_API = 13,
    FAVORITE_MENU_ITEMS_API = 14,
    
    MAKE_RESTAURANT_FAVORITE_API = 15,
    MAKE_RESTAURANT_ITEM_FAVORITE_API = 16,
    MAKE_LOCATION_FAVORITE_API = 17,
    RESTAURANT_RATING_API = 18,
    CANCEL_ORDER_API = 19,
    FILTER_API = 20,
    AUTHENTICATE_API = 21,
    SUGGESTION_LIST = 22,
    SEND_MESSAGE_API = 23,
    
};

typedef NS_ENUM(NSInteger, RESTAURANT_SEARCH_TYPE)
{
    BY_LOCATION_TEXT = 1,
    FAVORITE = 2,
    NEARBY = 3,
   
};

@property(nonatomic, weak) id <WebServiceDelegate> delegate;
@property(nonatomic, assign) NSInteger API_TYPE;
@property(nonatomic, assign) NSInteger RESTAURANT_SEARCH_TYPE;
@property(nonatomic,assign) NSInteger API_INDEX;            // use to identify api index in response when multiple api's are in action.

-(void)startOperationWithPostParam:(NSDictionary *)paramDict;
@end

