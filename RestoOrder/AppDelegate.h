//
//  AppDelegate.h
//  RestoOrder
//
//  Created by Suresh Kumar on 05/07/15.
//
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
@import CoreLocation;

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
}
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) Reachability *hostReachability;
@property(nonatomic, assign) BOOL reachabilityStatus;
@property(nonatomic, strong) NSString *deviceToken;
@property(nonatomic, strong) NSMutableDictionary *searchRestaurantDict;
@property(nonatomic, assign) NSInteger isMenuScreen;    // 1 if add to basket view appears from menu screen else 0;
@property(nonatomic, assign) NSInteger skipToSettingCheck;      // 1 if tab bar displayed by skip to setting action else 0

-(void)displayAlertWithMessage:(NSString *)message;
-(void)showLoaderWithinteractionEnabledOnView :(UIView *)IView;
-(void)hideLoaderWithinteractionEnabledFromView :(UIView *)IView;
-(void)showLoaderWithinteractionDisabled;
-(void)hideLoaderWithinteractionDisabled;

@end

