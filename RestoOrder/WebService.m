//
//  WebService.m
//  Delivery_Runner
//
//  Created by Suresh Kumar on 02/02/15.
//  Copyright (c) 2015 WebSnoox Technologies. All rights reserved.
//

#import "WebService.h"
#import "AppDelegate.h"
#import "UserDetails.h"
#import "Database.h"
#import "Constants.h"
#import "UserDetails.h"
#import "Restaurant.h"
#import "MenuItem.h"
#import "Location.h"
#import "FilterObject.h"

#define PageLimit @"30"

@implementation WebService
@synthesize API_TYPE, RESTAURANT_SEARCH_TYPE, delegate, API_INDEX;


#pragma mark check internet connection

-(BOOL)hasInternetConnection;
{
    AppDelegate *appdelegateObj = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    BOOL isInternetActive = appdelegateObj.reachabilityStatus;
    return isInternetActive;
}

#pragma mark - Initialize operations

-(void)startOperationWithPostParam:(NSDictionary *)paramDict
{
        
    if ([self hasInternetConnection])
    {
        FilterObject *filterObj = [FilterObject sharedManager];
        
        NSString *userIdStr = [[UserDetails sharedManager] userId];
        NSString *latitude = [NSString stringWithFormat:@"%f",[[UserDetails sharedManager] latitude]];
        NSString *longitude = [NSString stringWithFormat:@"%f",[[UserDetails sharedManager] longitude]];
        
        NSMutableURLRequest *request;
        switch (API_TYPE)
        {
            case LOGIN_API:
            {
                NSString *emailStr = [paramDict objectForKey:@"email"];
                NSString *passwordStr = [paramDict objectForKey:@"password"];
                
                NSString *urlStr = [NSString stringWithFormat:@"%@/userLogin?",SERVERURL];
                request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
                
                NSString * params =[NSString stringWithFormat:@"userEmail=%@&userPassword=%@&device_type=iPhone&deviceToken=%@&userLatitude=%@&userLongitude=%@",emailStr,passwordStr,UIAppDelegate.deviceToken,latitude,longitude];
                
                [request setHTTPMethod:@"POST"];
                [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
                
                NSLog(@"url :%@ params :%@",urlStr, params);
                
            }
                break;
            case SIGNUP_API:
            {
                NSString *userName = [paramDict objectForKey:@"name"];
//                NSString *lastName = [paramDict objectForKey:@"lastName"];
                NSString *userEmail = [paramDict objectForKey:@"email"];
                NSString *facebookId = [paramDict objectForKey:@"facebookId"];
                NSString *password = [paramDict objectForKey:@"password"];
                NSString *mobile = [paramDict objectForKey:@"mobile"];
                
                NSString *urlStr = [NSString stringWithFormat:@"%@/userRegister",SERVERURL];
                request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
                
                NSString * params =[NSString stringWithFormat:@"userName=%@&userEmail=%@&userPassword=%@&deviceToken=%@&facebookId=%@&device_type=iPhone&userLatitude=%@&userLongitude=%@&phoneNumber=%@",userName,userEmail,password,UIAppDelegate.deviceToken,facebookId,latitude, longitude,mobile];
                
                [request setHTTPMethod:@"POST"];
                [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];

//                [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
                
                NSLog(@"url :%@",urlStr);
                
            }
                break;
            case UPDATE_USER_INFO_API:
            {
                NSString *userId = userIdStr;
                NSString *firstName = [paramDict objectForKey:@"firstName"];
                NSString *lastName = [paramDict objectForKey:@"lastName"];
                NSString *email = [paramDict objectForKey:@"email"];
                NSString *phone = [paramDict objectForKey:@"phone"];

                NSString *urlStr = [NSString stringWithFormat:@"%@/updateProfile?",SERVERURL];
                request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
                
                NSString * params =[NSString stringWithFormat:@"UserId=%@&firstName=%@&lastName=%@&userEmail=%@&phoneNumber=%@",userId,firstName,lastName,email,phone];
                
                [request setHTTPMethod:@"POST"];
                [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
                
                NSLog(@"url :%@",urlStr);
                
            }
                break;
            case UPDATE_USER_LOCATION_API:
            {
                NSString *auth_Token = userIdStr;
                NSString *latitude = [paramDict objectForKey:@"latitude"];
                NSString *longitude = [paramDict objectForKey:@"longitude"];
                NSString *urlStr = [NSString stringWithFormat:@"%@/user/updatelocation?token=%@&latitude=%@&longitude=%@",SERVERURL,auth_Token,latitude,longitude];
                request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
                [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
                
                NSLog(@"url :%@",urlStr);
                
            }
                break;
            case CHANGE_PASSWORD_API:
            {
                NSString *UserId = userIdStr;
                NSString *OldPassword = [paramDict objectForKey:@"OldPassword"];
                NSString *NewPassword = [paramDict objectForKey:@"NewPassword"];
                NSString *urlStr = [NSString stringWithFormat:@"%@/changePassword?",SERVERURL];
                
                request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
                
                NSString * params =[NSString stringWithFormat:@"UserId=%@&OldPassword=%@&NewPassword=%@",UserId,OldPassword,NewPassword];
                
                [request setHTTPMethod:@"POST"];
                [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
//                [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
                
                NSLog(@"url :%@",urlStr);
                
            }
                break;
            case FORGOT_PASSWORD_API:
            {
                NSString *emailStr = [paramDict objectForKey:@"email"];
                NSString *urlStr = [NSString stringWithFormat:@"%@/forgotPassword?userEmail=%@",SERVERURL,emailStr];
                request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
//                [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
                
                NSLog(@"url :%@",urlStr);
                
            }
                break;
                
            case FIND_RESTAURANTS_API:
            {
                NSString *userId = userIdStr;
                NSString *searchType = [paramDict objectForKey:@"searchType"];
                NSString *locationName = [paramDict objectForKey:@"searchText"];
                NSString *PageNo = [paramDict objectForKey:@"page"];
                NSString *Limit = PageLimit;
                
                NSMutableDictionary *filterDict = [[NSMutableDictionary alloc] init];
                [filterDict setObject:filterObj.selectedIds forKey:@"cuisines"];
                
                if ([searchType isEqualToString:@"0"] && [filterObj.distanceCountStr isEqualToString:@"0"])
                {
                    [filterDict setObject:@"10" forKey:@"RestaurantDistance"];
                    filterObj.distanceCountStr = @"10";
                }
                else
                {
                    [filterDict setObject:filterObj.distanceCountStr forKey:@"RestaurantDistance"];
                }
                
                
                NSMutableData *requestBody = [[NSMutableData alloc] initWithData: [NSJSONSerialization dataWithJSONObject:filterDict options:NSJSONWritingPrettyPrinted error:nil]];
                
                NSString *filterJson = [[NSString alloc] initWithData:requestBody encoding:NSUTF8StringEncoding];
                
                NSString *urlStr = [NSString stringWithFormat:@"%@/restaurantList?",SERVERURL];
                request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
                
                NSString * params =[NSString stringWithFormat:@"userId=%@&searchType=%@&locationName=%@&latitude=%@&longitude=%@&PageNo=%@&Limit=%@&Filter=%@",userId,searchType,locationName,latitude,longitude,PageNo,Limit,filterJson];
                
                [request setHTTPMethod:@"POST"];
                [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
                
                NSLog(@"url :%@ \n post params :%@",urlStr, params);
                
            }
                break;
                
            case SUGGESTION_LIST:
            {
                NSString *searchType = [paramDict objectForKey:@"searchType"];
                NSString *searchText = [paramDict objectForKey:@"searchText"];
                
                NSString *urlStr = [NSString stringWithFormat:@"%@/autoLocationList?",SERVERURL];
                request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
                
                NSString * params =[NSString stringWithFormat:@"searchType=%@&searchText=%@&latitude=%@&longitude=%@&userId=%@",searchType,searchText,latitude,longitude, userIdStr];
                
                [request setHTTPMethod:@"POST"];
                [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
                
                NSLog(@"suggestion url :%@ \n post params :%@",urlStr, params);
                
            }
                break;
                
            case RESTAURANT_CATEGORIES_API:
            {
                NSString *restaurantId = [paramDict objectForKey:@"restaurantId"];
                NSString *urlStr = [NSString stringWithFormat:@"%@/restaurantCategories?restaurantId=%@",SERVERURL,restaurantId];
                request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
//                [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
                
                NSLog(@"url :%@",urlStr);
            }
                break;
                
            case CATEGORY_MENU_API:
            {
                NSString *restaurantId = [paramDict objectForKey:@"restaurantId"];
                NSString *categoryId = [paramDict objectForKey:@"categoryId"];
                NSString *UserId = userIdStr;
                
                NSString *urlStr = [NSString stringWithFormat:@"%@/categoryItems?restaurantId=%@&categoryId=%@&UserId=%@",SERVERURL,restaurantId,categoryId,UserId];
                request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
                //                [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
                
                NSLog(@"url :%@",urlStr);
            }
                break;
                
            case RESTAURANT_DETAILS_API:
            {
                NSString *auth_Token = userIdStr;
                NSString *restoId = [paramDict objectForKey:@"id"];
                
                NSString *urlStr = [NSString stringWithFormat:@"%@/restaurant/details/%@?token=%@",SERVERURL,restoId,auth_Token];
                request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
//                [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
                
                NSLog(@"url :%@",urlStr);
                
            }
                break;
                 
            case ORDER_HISTORY_API:
            {
                NSString *UserId = userIdStr;
                
                NSString *urlStr = [NSString stringWithFormat:@"%@/orderHistory?UserId=%@",SERVERURL,UserId];
                
                request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
//                [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
                
                NSLog(@"url :%@",urlStr);
                
            }
                break;
            case CREATE_ORDER_API:
            {
                NSString *UserId = userIdStr;
                NSString *Items = [paramDict objectForKey:@"Items"];
                NSString *TotalPrice = [paramDict objectForKey:@"TotalPrice"];
                NSString *CheckoutType = [paramDict objectForKey:@"CheckoutType"];
                NSString *SubTotal = [paramDict objectForKey:@"SubTotal"];
                NSString *VatPrice = [paramDict objectForKey:@"VatPrice"];
                NSString *TaxPrice = [paramDict objectForKey:@"TaxPrice"];
                NSString *RestaurantId = [paramDict objectForKey:@"RestaurantId"];
                NSString *DeliveryTime = [paramDict objectForKey:@"DeliveryTime"];
                NSString *orderComments = [paramDict objectForKey:@"orderComments"];
                NSString *TakeAwayTime = [paramDict objectForKey:@"TakeAwayTime"];
                NSString *ReserveaTableTime = [paramDict objectForKey:@"ReserveaTableTime"];
                NSString *deliveryAddress = [paramDict objectForKey:@"deliveryAddress"];
                
                NSString *currentTime = [self getCurrentTimeForOrder];
                
                NSString *urlStr = [NSString stringWithFormat:@"%@/userPlaceOrder?",SERVERURL];
                request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
                
                NSString * params =[NSString stringWithFormat:@"UserId=%@&Items=%@&TotalPrice=%@&CheckoutType=%@&SubTotal=%@&VatPrice=%@&TaxPrice=%@&RestaurantId=%@&deliveryAddress=%@&orderComments=%@&takeAwayTime=%@&reserveaTableTime=%@&deliveryTime=%@&orderTime=%@",UserId,Items,TotalPrice,CheckoutType,SubTotal,VatPrice,TaxPrice,RestaurantId,deliveryAddress,orderComments,TakeAwayTime,ReserveaTableTime,DeliveryTime,currentTime];
                
                [request setHTTPMethod:@"POST"];
                [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
                
//                [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
                
                NSLog(@"url :%@",urlStr);
                
            }
                break;
                
            case MAKE_RESTAURANT_FAVORITE_API:
            {
                NSString *UserId = userIdStr;
                NSString *RestaurantId = [paramDict objectForKey:@"RestaurantId"];
                NSString *Isfavorite = [paramDict objectForKey:@"Isfavorite"];
                
                NSString *urlStr = [NSString stringWithFormat:@"%@/addRestaurantFavourite?UserId=%@&RestaurantId=%@&Isfavorite=%@",SERVERURL,UserId,RestaurantId,Isfavorite];
                request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
//                [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
                
                NSLog(@"url :%@",urlStr);
                
            }
                break;
                
            case MAKE_RESTAURANT_ITEM_FAVORITE_API:
            {
                NSString *UserId = userIdStr;
                NSString *ItemId = [paramDict objectForKey:@"ItemId"];
                NSString *RestaurantId = [paramDict objectForKey:@"RestaurantId"];
                NSString *Isfavorite = [paramDict objectForKey:@"Isfavorite"];
                
                NSString *urlStr = [NSString stringWithFormat:@"%@/addRestaurantItemsFavourite?UserId=%@&ItemId=%@&RestaurantId=%@&Isfavorite=%@",SERVERURL,UserId,ItemId,RestaurantId,Isfavorite];
                
                request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
//                [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
                
                NSLog(@"url :%@",urlStr);
                
            }
                break;
                
            case MAKE_LOCATION_FAVORITE_API:
            {
                NSString *UserId = userIdStr;
                NSString *Location = [paramDict objectForKey:@"Location"];
                NSString *LocationType = [paramDict objectForKey:@"LocationType"];
                
                NSString *urlStr = [NSString stringWithFormat:@"%@/addLocationFavourite?UserId=%@&Location=%@&LocationType=%@",SERVERURL,UserId,Location,LocationType];
                
                request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
//                [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
                
                NSLog(@"url :%@",urlStr);
                
            }
                break;
                
            case RESTAURANT_RATING_API:
            {
                NSString *UserId = userIdStr;
                NSString *RestaurantId = [paramDict objectForKey:@"RestaurantId"];
                NSString *RateValue = [paramDict objectForKey:@"RateValue"];
                
                NSString *urlStr = [NSString stringWithFormat:@"%@/restaurantRating?UserId=%@&RestaurantId=%@&RateValue=%@",SERVERURL,UserId,RestaurantId,RateValue];
                
                request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
                //                [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
                
                NSLog(@"url :%@",urlStr);
                
            }
                break;
                
            case FAVORITE_LOCATION_API:
            {
                NSString *UserId = userIdStr;
                
                NSString *urlStr = [NSString stringWithFormat:@"%@/locationFavouriteList?UserId=%@",SERVERURL,UserId];
                
                request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
                //                [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
                
                NSLog(@"url :%@",urlStr);
                
            }
                break;
                
            case FAVORITE_MENU_ITEMS_API:
            {
                NSString *UserId = userIdStr;
                
                NSString *urlStr = [NSString stringWithFormat:@"%@/userFavouriteMenuItems?UserId=%@",SERVERURL,UserId];
                
                request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
                //                [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
                
                NSLog(@"url :%@",urlStr);
                
            }
                break;
                
            case CANCEL_ORDER_API:
            {
                NSString *UserId = userIdStr;
                NSString *orderId = paramDict[@"orderId"];
                NSString *urlStr = [NSString stringWithFormat:@"%@/userCancelOrder?UserId=%@&orderId=%@",SERVERURL,UserId,orderId];
                
                request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
                //                [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
                
                NSLog(@"url :%@",urlStr);
                
            }
                break;
                
            case SEND_MESSAGE_API:
            {
                NSString *UserId = userIdStr;
                NSString *orderId = paramDict[@"orderId"];
                NSString *message = paramDict[@"message"];
                NSString *urlStr = [NSString stringWithFormat:@"%@/userMessage?UserId=%@&orderId=%@&message=%@",SERVERURL,UserId,orderId,message];
                
                request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
                //                [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
                
                NSLog(@"url :%@",urlStr);
                
            }
                break;
                
            case FILTER_API:
            {
                NSString *urlStr = [NSString stringWithFormat:@"%@/cuisinesList?",SERVERURL];
                
                request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
                
                NSLog(@"url :%@",urlStr);
                
            }
                break;
                
            case AUTHENTICATE_API:
            {
                NSString *UserId = userIdStr;
                NSString *password = paramDict[@"password"];
                NSString *urlStr = [NSString stringWithFormat:@"%@/authenticate?userId=%@&userPassword=%@",SERVERURL,UserId,password];
                
                request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
                //                [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
                
                NSLog(@"url :%@",urlStr);
                
            }
                break;

                
            default:
                break;
        }
        
        
        [self initializeOperationWithRequest:request];
        
    }
    else
    {
        NSString *errorStr = @"OH NO ! Internet connection is not available";
        
        if ([self respondsToSelector:@selector(operationFinishedWIthError: API_Index:)])
        {
            [self operationFinishedWIthError:errorStr API_Index:API_INDEX];
        }
    }
}

-(void)initializeOperationWithRequest:(NSURLRequest *)request
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:nil];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
      {
          dispatch_async(dispatch_get_main_queue(), ^{
              
              NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
//              int responseStatusCode = [httpResponse statusCode];
              
              if (error)
              {
                  
                  if ([self respondsToSelector:@selector(operationFinishedWIthError: API_Index:)])
                  {
                      NSString *errorDescription = error.localizedDescription;
                      [self operationFinishedWIthError:errorDescription API_Index:API_INDEX];
                      
                  }
              }
              
              else if(data != nil)
              {
                  NSString* myString;
                  myString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                  NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                  
                  responseDict = [self removeNull:responseDict];
                  
                  [self parseResponse:responseDict];
                 
              }
              else if ([httpResponse statusCode] != 200)
              {
                  if ([self respondsToSelector:@selector(operationFinishedWIthResponse: API_Index:)])
                  {
                      NSString *responseStr = response.description;
                      [self operationFinishedWIthResponse:responseStr API_Index:API_INDEX];
                      
                  }
              }
          });
      }] resume];
}

#pragma mark - Eliminate Null Values

-(id)removeNull:(id)rootObject
{
    if ([rootObject isKindOfClass:[NSDictionary class]])
    {
        NSMutableDictionary *sanitizedDictionary = [NSMutableDictionary dictionaryWithDictionary:rootObject];
        [rootObject enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            id sanitized = [self removeNull:obj];
            if (!sanitized) {
                [sanitizedDictionary setObject:@"" forKey:key];
            } else {
                [sanitizedDictionary setObject:sanitized forKey:key];
            }
        }];
        return [NSMutableDictionary dictionaryWithDictionary:sanitizedDictionary];
    }
    
    if ([rootObject isKindOfClass:[NSArray class]])
    {
        NSMutableArray *sanitizedArray = [NSMutableArray arrayWithArray:rootObject];
        [rootObject enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            id sanitized = [self removeNull:obj];
            if (!sanitized) {
                [sanitizedArray replaceObjectAtIndex:[sanitizedArray indexOfObject:obj] withObject:@""];
            } else {
                [sanitizedArray replaceObjectAtIndex:[sanitizedArray indexOfObject:obj] withObject:sanitized];
            }
        }];
        return [NSMutableArray arrayWithArray:sanitizedArray];
    }
    
    if ([rootObject isKindOfClass:[NSNull class]])
    {
        return (id)nil;
    }
    else
    {
        return rootObject;
    }
}

#pragma mark - Handle Parsing

-(void)parseResponse:(id)response
{
    NSLog(@"response:%@",response);
    
    switch (API_TYPE)
    {
        case LOGIN_API:
        {
            [self parseLoginAPIResponse:response];
        }
            break;
        case SIGNUP_API:
        {
            [self parseSignUpAPIResponse:response];
        }
            break;
        case UPDATE_USER_INFO_API:
        {
            [self parseUpdateUserInfoAPIResponse:response];
        }
            break;
        case UPDATE_USER_LOCATION_API:
        {
            [self parseUpdateUserLocationAPIResponse:response];
        }
            break;
        case CHANGE_PASSWORD_API:
        {
            [self parseChangePasswordAPIResponse:response];
        }
            break;
        case FORGOT_PASSWORD_API:
        {
            [self parseForgotPasswordAPIResponse:response];
        }
            break;
        case RESTAURANT_DETAILS_API:
        {
            [self parseRestaurantDetailsAPIResponse:response];
        }
            break;
        case ORDER_HISTORY_API:
        {
            [self parseOrderHistoryAPIResponse:response];
        }
            break;
        case CREATE_ORDER_API:
        {
            [self parseCreateOrderAPIResponse:response];
        }
            break;
        case FIND_RESTAURANTS_API:
        {
            [self parseRestaurantsListAPIResponse:response];
        }
            break;
            
        case SUGGESTION_LIST:
        {
            [self parseSuggestionListAPIResponse:response];
        }
            break;
        case RESTAURANT_CATEGORIES_API:
        {
            [self parseCategoriesAPIResponse:response];
        }
            break;
        case CATEGORY_MENU_API:
        {
            [self parseMenuAPIResponse:response];
        }
            break;
            
        case MAKE_RESTAURANT_FAVORITE_API:
        {
            [self parseMakeRestaurantFavoriteAPIResponse:response];
        }
            break;
            
        case MAKE_RESTAURANT_ITEM_FAVORITE_API:
        {
            [self parseMakeRestaurantItemFavoriteAPIResponse:response];
        }
            break;
            
        case MAKE_LOCATION_FAVORITE_API:
        {
            [self parseMakeLocationFavoriteAPIResponse:response];
        }
            break;
            
        case RESTAURANT_RATING_API:
        {
            [self parseRestaurantRatingAPIResponse:response];
        }
            break;
            
        case FAVORITE_LOCATION_API:
        {
            [self parseFavoriteLocationsAPIResponse:response];
        }
            break;
            
        case FAVORITE_MENU_ITEMS_API:
        {
            [self parseFavoriteItemsAPIResponse:response];
        }
            break;
            
        case CANCEL_ORDER_API:
        {
            [self parseCancelOrderAPIResponse:response];
        }
            break;
            
        case FILTER_API:
        {
            [self parseFilterAPIResponse:response];
        }
            break;
            
        case AUTHENTICATE_API:
        {
            [self parseAuthenticateAPIResponse:response];
        }
            break;
            
        case SEND_MESSAGE_API:
        {
            [self parseSendMessageAPIResponse:response];
        }
            break;
            
        default:
            break;
    }
}

-(void)parseLoginAPIResponse:(id)response
{
    NSDictionary *dict = (NSDictionary *)response;
    NSLog(@"dict :%@",dict[@"Message"]);
    if ([[dict valueForKey:@"Status"] integerValue] == 1)
    {
//        [[Database sharedObject] deleteAllProducts];
        
        UserDetails *userinfo = [UserDetails sharedManager];
        userinfo.userId = dict[@"UserId"];
        userinfo.email = dict[@"Email"];
        userinfo.name = dict[@"UserName"];
        userinfo.mobile = dict[@"PhoneNumber"];
        userinfo.userType = dict[@"UserType"];
        
        [userinfo archiveUserDetails];
        
        if ([self respondsToSelector:@selector(operationFinishedWIthResult: API_Index:)])
        {
            [self operationFinishedWIthResult:dict API_Index:API_INDEX];
        }
    }
    else
    {
        if ([self respondsToSelector:@selector(operationFinishedWIthError: API_Index:)])
        {
            NSString *errorDescription = dict[@"Message"];
            [self operationFinishedWIthError:errorDescription API_Index:API_INDEX];
            
        }
    }

}

-(void)parseSignUpAPIResponse:(id)response
{
    NSDictionary *dict = (NSDictionary *)response;
    NSLog(@"dict :%@",dict[@"Message"]);
    if ([[dict valueForKey:@"Status"] integerValue] == 1)
    {
        
        //        [[Database sharedObject] deleteAllProducts];
        
        UserDetails *userinfo = [UserDetails sharedManager];
        userinfo.userId = dict[@"UserId"];
        userinfo.email = dict[@"Email"];
        userinfo.name = dict[@"UserName"];
        userinfo.mobile = dict[@"PhoneNumber"];
        userinfo.userType = dict[@"UserType"];
        
        [userinfo archiveUserDetails];
        
        if ([self respondsToSelector:@selector(operationFinishedWIthResult: API_Index:)])
        {
            [self operationFinishedWIthResult:dict API_Index:API_INDEX];
        }
        
    }
    else
    {
        if ([self respondsToSelector:@selector(operationFinishedWIthError: API_Index:)])
        {
            NSString *errorDescription = dict[@"Message"];
            [self operationFinishedWIthError:errorDescription API_Index:API_INDEX];
            
        }
    }
    
}

-(void)parseForgotPasswordAPIResponse:(id)response
{
    NSDictionary *dict = (NSDictionary *)response;
    
    if ([[dict valueForKey:@"Status"] integerValue] == 1)
    {
        if ([self respondsToSelector:@selector(operationFinishedWIthResult: API_Index:)])
        {
            [self operationFinishedWIthResult:dict[@"Message"] API_Index:API_INDEX];
        }
    }
    else
    {
        if ([self respondsToSelector:@selector(operationFinishedWIthError: API_Index:)])
        {
            NSString *errorDescription = dict[@"Message"];
            [self operationFinishedWIthError:errorDescription API_Index:API_INDEX];
            
        }
    }
}

-(void)parseChangePasswordAPIResponse:(id)response
{
    NSDictionary *dict = (NSDictionary *)response;
    
    if ([[dict valueForKey:@"Status"] integerValue] == 1)
    {
        if ([self respondsToSelector:@selector(operationFinishedWIthResult: API_Index:)])
        {
            [self operationFinishedWIthResult:dict[@"Message"] API_Index:API_INDEX];
        }
    }
    else
    {
        if ([self respondsToSelector:@selector(operationFinishedWIthError: API_Index:)])
        {
            NSString *errorDescription = dict[@"Message"];
            [self operationFinishedWIthError:errorDescription API_Index:API_INDEX];
            
        }
    }
}

-(void)parseUpdateUserInfoAPIResponse:(id)response
{
    NSDictionary *dict = (NSDictionary *)response;
    
    if ([[dict valueForKey:@"Status"] integerValue] == 1)
    {
        if ([self respondsToSelector:@selector(operationFinishedWIthResult: API_Index:)])
        {
            [self operationFinishedWIthResult:dict API_Index:API_INDEX];
        }
    }
    else
    {
        if ([self respondsToSelector:@selector(operationFinishedWIthError: API_Index:)])
        {
            NSString *errorDescription = dict[@"Message"];
            [self operationFinishedWIthError:errorDescription API_Index:API_INDEX];
            
        }
    }
}

-(void)parseUpdateUserLocationAPIResponse:(id)response
{
    NSDictionary *dict = (NSDictionary *)response;
    
    if ([[dict valueForKey:@"error"] integerValue] == 0)
    {
        if ([self respondsToSelector:@selector(operationFinishedWIthResult: API_Index:)])
        {
            [self operationFinishedWIthResult:dict API_Index:API_INDEX];
        }
    }
    else
    {
        if ([self respondsToSelector:@selector(operationFinishedWIthError: API_Index:)])
        {
            NSString *errorDescription = dict[@"message"];
            [self operationFinishedWIthError:errorDescription API_Index:API_INDEX];
            
        }
    }
}

-(void)parseRestaurantsListAPIResponse:(id)response
{
    NSDictionary *dict = (NSDictionary *)response;
    
    if ([[dict valueForKey:@"Status"] integerValue] != 0)
    {
        NSMutableArray *restaurantArray = [[NSMutableArray alloc]init];
        NSArray *tempArr = [NSArray arrayWithArray:dict[@"Restaurants"]];
        
        if (tempArr.count < [PageLimit integerValue])
        {
            [UIAppDelegate.searchRestaurantDict setObject:@"0" forKey:@"nextPage"];
        }
        else
        {
            [UIAppDelegate.searchRestaurantDict setObject:@"1" forKey:@"nextPage"];
        }
        
        NSDictionary *savedRestDict = [[Database sharedObject] readRestaurant];
    
        for (NSDictionary *object in tempArr)
        {
            Restaurant *restaurantObj = [[Restaurant alloc] init];
            restaurantObj.Id = object[@"RestaurantId"];
            
            if (savedRestDict.allKeys.count > 0)
            {
                if ([savedRestDict[@"rId"] isEqualToString:object[@"RestaurantId"]])
                {
                    restaurantObj.isLocallySaved = @"1";
                }
            }
            restaurantObj.name = object[@"RestaurantName"];
            restaurantObj.isFavorite = object[@"IsFavorite"];
            restaurantObj.ImageUrl = object[@"restaurantImageUrl"];
            restaurantObj.logoUrl = object[@"logoImage"];
            restaurantObj.address = object[@"RestaurantAddress"];
            restaurantObj.latitude = object[@"latitude"];
            restaurantObj.longitude = object[@"longitude"];
            restaurantObj.contactNo = object[@"RestaurantContactNo"];
            restaurantObj.distance = object[@"RestaurantDistance"];
            restaurantObj.rateCount = object[@"RateCount"];
            restaurantObj.isOpen = object[@"IsOpen"];
            restaurantObj.openingHours = object[@"openingTime"];
            restaurantObj.closingHours = object[@"closingTime"];
            restaurantObj.minimumOrder = object[@"MinimumOrder"];
            restaurantObj.deliveryTime = object[@"DeliveryTime"];
            restaurantObj.serviceTax = object[@"ServiceTax"];
            restaurantObj.vat = object[@"vat"];
            restaurantObj.cardTypes = object[@"CardTypes"];
            restaurantObj.defaultTakeAwayTime = object[@"DefaultTakeAwayTime"];
            restaurantObj.defaultReserveaTableTime = object[@"defaultReserveaTableTime"];
            restaurantObj.defaultDeliveryTime = object[@"defaultDeliveryTime"];
            restaurantObj.favoriteCreationDate = object[@"favoriteCreationDate"];
            restaurantObj.restaurantType = object[@"cuisinesType"];
            restaurantObj.maxAmount = object[@"maxAmount"];
            restaurantObj.maxQty = object[@"maxQty"];
            [restaurantArray addObject:restaurantObj];
        }
        
        if ([self respondsToSelector:@selector(operationFinishedWIthResult: API_Index:)])
        {
            [self operationFinishedWIthResult:restaurantArray API_Index:API_INDEX];
        }
    }
    else
    {
        if ([self respondsToSelector:@selector(operationFinishedWIthError: API_Index:)])
        {
            NSString *errorDescription = dict[@"Message"];
            [self operationFinishedWIthError:errorDescription API_Index:API_INDEX];
            
        }
    }
}

-(void)parseSuggestionListAPIResponse:(id)response
{
    NSDictionary *dict = (NSDictionary *)response;
    
    if ([[dict valueForKey:@"Status"] integerValue] == 1)
    {
        NSArray *suggestionArray = dict[@"locationList"];
        NSLog(@"suggestion Array : %@",suggestionArray);
        if ([self respondsToSelector:@selector(operationFinishedWIthResult: API_Index:)])
        {
            [self operationFinishedWIthResult:suggestionArray API_Index:API_INDEX];
        }
        
    }
    else
    {
        if ([self respondsToSelector:@selector(operationFinishedWIthError: API_Index:)])
        {
            NSString *errorDescription = dict[@"Message"];
            [self operationFinishedWIthError:errorDescription API_Index:API_INDEX];
            
        }
    }
}

-(void)parseCategoriesAPIResponse:(id)response
{
    NSDictionary *dict = (NSDictionary *)response;
    
    if ([[dict valueForKey:@"Status"] integerValue] == 1)
    {
        NSArray *categoriesArray = dict[@"Category"];
        NSLog(@"categories Array : %@",categoriesArray);
        if ([self respondsToSelector:@selector(operationFinishedWIthResult: API_Index:)])
        {
            [self operationFinishedWIthResult:categoriesArray API_Index:API_INDEX];
        }
        
    }
    else
    {
        if ([self respondsToSelector:@selector(operationFinishedWIthError: API_Index:)])
        {
            NSString *errorDescription = dict[@"Message"];
            [self operationFinishedWIthError:errorDescription API_Index:API_INDEX];
            
        }
    }
}

-(void)parseMenuAPIResponse:(id)response
{
    NSDictionary *dict = (NSDictionary *)response;
    
    if ([[dict valueForKey:@"Status"] integerValue] == 1)
    {
        NSArray *tempArray = dict[@"Item"];
        NSMutableArray *itemsArray = [[NSMutableArray alloc] init];
        
        for (NSDictionary *currentDict in tempArray)
        {
            MenuItem *menuItemObj = [[MenuItem alloc] init];
            menuItemObj.itemName = currentDict[@"ItemName"];
            menuItemObj.itemId = currentDict[@"ItemId"];
            menuItemObj.shortDesc = currentDict[@"ShortDesc"];
            menuItemObj.isFavorite = currentDict[@"IsFavorite"];
            menuItemObj.price = currentDict[@"ItemPrice"];
            menuItemObj.addonArray = currentDict[@"Addon"];
            
            [itemsArray addObject:menuItemObj];
        }
        NSLog(@"items Array : %@",itemsArray);
        if ([self respondsToSelector:@selector(operationFinishedWIthResult: API_Index:)])
        {
            [self operationFinishedWIthResult:itemsArray API_Index:API_INDEX];
        }
        
    }
    else
    {
        if ([self respondsToSelector:@selector(operationFinishedWIthError: API_Index:)])
        {
            NSString *errorDescription = dict[@"Message"];
            [self operationFinishedWIthError:errorDescription API_Index:API_INDEX];
            
        }
    }
}


-(void)parseMakeRestaurantFavoriteAPIResponse:(id)response
{
    NSDictionary *dict = (NSDictionary *)response;
    
    if ([[dict valueForKey:@"Status"] integerValue] == 1)
    {
        
        if ([self respondsToSelector:@selector(operationFinishedWIthResult: API_Index:)])
        {
            [self operationFinishedWIthResult:dict[@"Message"] API_Index:API_INDEX];
        }
        
    }
    else
    {
        if ([self respondsToSelector:@selector(operationFinishedWIthError: API_Index:)])
        {
            NSString *errorDescription = dict[@"Message"];
            [self operationFinishedWIthError:errorDescription API_Index:API_INDEX];
            
        }
    }
}


-(void)parseMakeRestaurantItemFavoriteAPIResponse:(id)response
{
    NSDictionary *dict = (NSDictionary *)response;
    
    if ([[dict valueForKey:@"Status"] integerValue] == 1)
    {
        if ([self respondsToSelector:@selector(operationFinishedWIthResult: API_Index:)])
        {
            [self operationFinishedWIthResult:dict[@"Message"] API_Index:API_INDEX];
        }
        
    }
    else
    {
        if ([self respondsToSelector:@selector(operationFinishedWIthError: API_Index:)])
        {
            NSString *errorDescription = dict[@"Message"];
            [self operationFinishedWIthError:errorDescription API_Index:API_INDEX];
            
        }
    }
}


-(void)parseMakeLocationFavoriteAPIResponse:(id)response
{
    NSDictionary *dict = (NSDictionary *)response;
    
    if ([[dict valueForKey:@"Status"] integerValue] == 1)
    {
       
        if ([self respondsToSelector:@selector(operationFinishedWIthResult: API_Index:)])
        {
            [self operationFinishedWIthResult:dict[@"Message"] API_Index:API_INDEX];
        }
        
    }
    else
    {
        if ([self respondsToSelector:@selector(operationFinishedWIthError: API_Index:)])
        {
            NSString *errorDescription = dict[@"Message"];
            [self operationFinishedWIthError:errorDescription API_Index:API_INDEX];
            
        }
    }
}


-(void)parseRestaurantRatingAPIResponse:(id)response
{
    NSDictionary *dict = (NSDictionary *)response;
    
    if ([[dict valueForKey:@"Status"] integerValue] == 1)
    {
        if ([self respondsToSelector:@selector(operationFinishedWIthResult: API_Index:)])
        {
            [self operationFinishedWIthResult:dict[@"Message"] API_Index:API_INDEX];
        }
        
    }
    else
    {
        if ([self respondsToSelector:@selector(operationFinishedWIthError: API_Index:)])
        {
            NSString *errorDescription = dict[@"Message"];
            [self operationFinishedWIthError:errorDescription API_Index:API_INDEX];
            
        }
    }
}

-(void)parseFavoriteLocationsAPIResponse:(id)response
{
    NSDictionary *dict = (NSDictionary *)response;
    
    if ([[dict valueForKey:@"Status"] integerValue] == 1)
    {
        NSMutableArray *locArray = [[NSMutableArray alloc] init];
        NSArray *locationsArray = dict[@"Location"];
        for (NSDictionary *dict in locationsArray)
        {
            Location *locObj = [[Location alloc] init];
            locObj.locationId = dict[@"locationId"];
            locObj.locationName = dict[@"Location"];
            locObj.locationType = dict[@"LocationType"];
            locObj.favoriteCreationDate = dict[@"favoriteCreationDate"];
            [locArray addObject:locObj];
            
        }
        
        if ([self respondsToSelector:@selector(operationFinishedWIthResult: API_Index:)])
        {
            [self operationFinishedWIthResult:locArray API_Index:API_INDEX];
        }
        
    }
    else
    {
        if ([self respondsToSelector:@selector(operationFinishedWIthError: API_Index:)])
        {
            NSString *errorDescription = dict[@"Message"];
            [self operationFinishedWIthError:errorDescription API_Index:API_INDEX];
            
        }
    }
}

-(void)parseFavoriteItemsAPIResponse:(id)response
{
    NSDictionary *dict = (NSDictionary *)response;
    
    if ([[dict valueForKey:@"Status"] integerValue] == 1)
    {
        NSArray *tempArray = dict[@"Item"];
        NSMutableArray *itemsArray = [[NSMutableArray alloc] init];
        
        for (NSDictionary *currentDict in tempArray)
        {
            MenuItem *menuItemObj = [[MenuItem alloc] init];
            menuItemObj.itemName = currentDict[@"ItemName"];
            menuItemObj.itemId = currentDict[@"ItemId"];
            menuItemObj.categoryId = currentDict[@"ItemCategoryId"];
            menuItemObj.favoriteCreationDate = currentDict[@"favoriteCreationDate"];
            menuItemObj.price = currentDict[@"ItemPrice"];
            menuItemObj.addonArray = currentDict[@"Addon"];
            menuItemObj.shortDesc = currentDict[@"ShortDesc"];
            
            NSMutableDictionary *restaurantDetail = [[NSMutableDictionary alloc] init];
            [restaurantDetail setObject:currentDict[@"RestaurantName"] forKey:@"name"];
            [restaurantDetail setObject:currentDict[@"RestaurantId"] forKey:@"Id"];
            [restaurantDetail setObject:currentDict[@"RestaurantAddress"] forKey:@"address"];
            [restaurantDetail setObject:currentDict[@"RestaurantContactNo"] forKey:@"contactNo"];
            [restaurantDetail setObject:currentDict[@"MinimumOrder"] forKey:@"minimumOrder"];
            [restaurantDetail setObject:currentDict[@"defaultDeliveryTime"] forKey:@"deliveryTime"];
            [restaurantDetail setObject:currentDict[@"IsOpen"] forKey:@"isOpen"];
            [restaurantDetail setObject:currentDict[@"ServiceTax"] forKey:@"serviceTax"];
            [restaurantDetail setObject:currentDict[@"vat"] forKey:@"vat"];
            [restaurantDetail setObject:currentDict[@"cardType"] forKey:@"cardTypes"];
            [restaurantDetail setObject:currentDict[@"DefaultTakeAwayTime"] forKey:@"defaultTakeAwayTime"];
            [restaurantDetail setObject:currentDict[@"defaultReserveaTableTime"] forKey:@"defaultReserveaTableTime"];
            [restaurantDetail setObject:currentDict[@"defaultDeliveryTime"] forKey:@"defaultDeliveryTime"];
            [restaurantDetail setObject:currentDict[@"openingTime"] forKey:@"openingHours"];
            [restaurantDetail setObject:currentDict[@"closingTime"] forKey:@"closingHours"];
            
            [restaurantDetail setObject:currentDict[@"maxAmount"] forKey:@"maxAmount"];
            [restaurantDetail setObject:currentDict[@"maxQty"] forKey:@"maxQty"];
            
            [restaurantDetail setObject:currentDict[@"IsFavorite"] forKey:@"isfavorite"];
            [restaurantDetail setObject:currentDict[@"restaurantImageUrl"] forKey:@"imageUrl"];
            [restaurantDetail setObject:currentDict[@"logoImage"] forKey:@"logoImage"];
            [restaurantDetail setObject:currentDict[@"latitude"] forKey:@"latitude"];
            [restaurantDetail setObject:currentDict[@"longitude"] forKey:@"longitude"];
            [restaurantDetail setObject:currentDict[@"RestaurantDistance"] forKey:@"restaurantDistance"];
            [restaurantDetail setObject:currentDict[@"RateCount"] forKey:@"rateCount"];
            [restaurantDetail setObject:currentDict[@"cuisinesType"] forKey:@"cuisinesType"];
            
            menuItemObj.restaurantDict = restaurantDetail;
            [itemsArray addObject:menuItemObj];
        }
        NSLog(@"items Array : %@",itemsArray);
        if ([self respondsToSelector:@selector(operationFinishedWIthResult: API_Index:)])
        {
            [self operationFinishedWIthResult:itemsArray API_Index:API_INDEX];
        }
    }
    else
    {
        if ([self respondsToSelector:@selector(operationFinishedWIthError: API_Index:)])
        {
            NSString *errorDescription = dict[@"Message"];
            [self operationFinishedWIthError:errorDescription API_Index:API_INDEX];
            
        }
    }
}

-(void)parseRestaurantDetailsAPIResponse:(id)response
{
    NSDictionary *dict = (NSDictionary *)response;
    
    if ([[dict valueForKey:@"error"] integerValue] == 0)
    {
        if ([self respondsToSelector:@selector(operationFinishedWIthResult: API_Index:)])
        {
            [self operationFinishedWIthResult:dict API_Index:API_INDEX];
        }
        
    }
    else
    {
        if ([self respondsToSelector:@selector(operationFinishedWIthError: API_Index:)])
        {
            NSString *errorDescription = dict[@"message"];
            [self operationFinishedWIthError:errorDescription API_Index:API_INDEX];
            
        }
    }
}

-(void)parseOrderHistoryAPIResponse:(id)response
{
    NSDictionary *dict = (NSDictionary *)response;
    
    if ([[dict valueForKey:@"Status"] integerValue] != 0)
    {
        NSMutableArray *parsedArray = [[NSMutableArray alloc]init];
        NSArray *tempArr = dict[@"History"];
        for (NSDictionary *object in tempArr)
        {
            NSMutableDictionary *currentObject = [[NSMutableDictionary alloc]initWithDictionary:object];
            NSString *dateStr = currentObject[@"orderDate"];
            dateStr = [self convertServerDateIntoDeviceDateTime:dateStr];
            if (dateStr == nil)
            {
                dateStr = currentObject[@"orderDate"];
            }
            [currentObject setObject:dateStr forKey:@"orderDate"];
            [parsedArray addObject:currentObject];
        }
        
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"OrderId" ascending:NO comparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare:obj2
                            options:NSNumericSearch];
        }];
        
        [parsedArray sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];
        
        NSLog(@"orders :%@",parsedArray);
        
        if ([self respondsToSelector:@selector(operationFinishedWIthResult: API_Index:)])
        {
            [self operationFinishedWIthResult:parsedArray API_Index:API_INDEX];
        }
        
    }
    else
    {
        if ([self respondsToSelector:@selector(operationFinishedWIthError: API_Index:)])
        {
            NSString *errorDescription = dict[@"Message"];
            [self operationFinishedWIthError:errorDescription API_Index:API_INDEX];
            
        }
    }
}

-(void)parseCreateOrderAPIResponse:(id)response
{
    NSDictionary *dict = (NSDictionary *)response;
    
    if ([[dict valueForKey:@"Status"] integerValue] != 0)
    {
        if ([self respondsToSelector:@selector(operationFinishedWIthResult: API_Index:)])
        {
            [self operationFinishedWIthResult:dict API_Index:API_INDEX];
        }
        
    }
    else
    {
        if ([self respondsToSelector:@selector(operationFinishedWIthError: API_Index:)])
        {
            NSString *errorDescription = dict[@"Message"];
            [self operationFinishedWIthError:errorDescription API_Index:API_INDEX];
            
        }
    }
}

-(void)parseCancelOrderAPIResponse:(id)response
{
    NSDictionary *dict = (NSDictionary *)response;
    
    if ([[dict valueForKey:@"Status"] integerValue] != 0)
    {
        if ([self respondsToSelector:@selector(operationFinishedWIthResult: API_Index:)])
        {
            [self operationFinishedWIthResult:dict API_Index:API_INDEX];
        }
        
    }
    else
    {
        if ([self respondsToSelector:@selector(operationFinishedWIthError: API_Index:)])
        {
            NSString *errorDescription = dict[@"Message"];
            [self operationFinishedWIthError:errorDescription API_Index:API_INDEX];
            
        }
    }
}

-(void)parseFilterAPIResponse:(id)response
{
    NSDictionary *dict = (NSDictionary *)response;
    
    if ([[dict valueForKey:@"Status"] integerValue] != 0)
    {
        NSArray *cuisinesArray = dict[@"cuisinesType"];
        
        FilterObject *filterObj = [FilterObject sharedManager];
        [filterObj.cuisinesArray removeAllObjects];
        [filterObj.cuisinesArray addObjectsFromArray:cuisinesArray];
        [filterObj.cuisineIndexes removeAllObjects];
        [filterObj.cuisineIndexes addObject:@"0"];
        filterObj.distanceCountStr = @"0";
        
        if ([self respondsToSelector:@selector(operationFinishedWIthResult: API_Index:)])
        {
            [self operationFinishedWIthResult:dict API_Index:API_INDEX];
        }
        
    }
    else
    {
        if ([self respondsToSelector:@selector(operationFinishedWIthError: API_Index:)])
        {
            NSString *errorDescription = dict[@"Message"];
            [self operationFinishedWIthError:errorDescription API_Index:API_INDEX];
            
        }
    }
}

-(void)parseAuthenticateAPIResponse:(id)response
{
    NSDictionary *dict = (NSDictionary *)response;
    
    if ([[dict valueForKey:@"Status"] integerValue] != 0)
    {
        if ([self respondsToSelector:@selector(operationFinishedWIthResult: API_Index:)])
        {
            [self operationFinishedWIthResult:dict API_Index:API_INDEX];
        }
        
    }
    else
    {
        if ([self respondsToSelector:@selector(operationFinishedWIthError: API_Index:)])
        {
            NSString *errorDescription = dict[@"Message"];
            [self operationFinishedWIthError:errorDescription API_Index:API_INDEX];
            
        }
    }
}

-(void)parseSendMessageAPIResponse:(id)response
{
    NSDictionary *dict = (NSDictionary *)response;
    
    if ([[dict valueForKey:@"Status"] integerValue] != 0)
    {
        if ([self respondsToSelector:@selector(operationFinishedWIthResult: API_Index:)])
        {
            [self operationFinishedWIthResult:dict API_Index:API_INDEX];
        }
        
    }
    else
    {
        if ([self respondsToSelector:@selector(operationFinishedWIthError: API_Index:)])
        {
            NSString *errorDescription = dict[@"Message"];
            [self operationFinishedWIthError:errorDescription API_Index:API_INDEX];
            
        }
    }
}

#pragma mark - WebService Delegates

-(void)operationFinishedWIthResult:(id)result API_Index:(NSInteger)index
{
    [delegate serviceFinishedWithResult:result API_Index:index];
}

-(void)operationFinishedWIthResponse:(id)response API_Index:(NSInteger)index
{
    [delegate serviceFinishedWithResponse:response API_Index:index];
}

-(void)operationFinishedWIthError:(id)error API_Index:(NSInteger)index
{
    [delegate serviceFinishedWithError:error API_Index:index];
}

-(NSString *)convertServerDateIntoDeviceDateTime:(id)dateStr
{
    //UTC time
    NSDateFormatter *utcDateFormatter = [[NSDateFormatter alloc] init];
    [utcDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    // utc format
    NSDate *dateInUTC = [utcDateFormatter dateFromString: dateStr];
    
    // offset second
    NSInteger seconds = [[NSTimeZone localTimeZone] secondsFromGMT];
    
    // format it and send
    NSDateFormatter *localDateFormatter = [[NSDateFormatter alloc] init];
    [localDateFormatter setDateFormat:@"dd-MM-yyyy h:mm a"];
    
    // formatted string
    NSString *localDate = [localDateFormatter stringFromDate: dateInUTC];
    return localDate;
    
}

-(NSString *)getCurrentTimeForOrder
{
    NSDateFormatter *utcDateFormatter = [[NSDateFormatter alloc] init];
    [utcDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *dateInUTC = [NSDate date];

    NSString *localDate = [utcDateFormatter stringFromDate: dateInUTC];
    return localDate;

}


@end
