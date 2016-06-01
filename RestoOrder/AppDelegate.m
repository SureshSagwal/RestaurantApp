//
//  AppDelegate.m
//  RestoOrder
//
//  Created by Suresh Kumar on 05/07/15.
//
//

#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "Constants.h"
#import "UserDetails.h"
#import "WebService.h"

@interface AppDelegate ()<WebServiceDelegate>
{
    UIActivityIndicatorView *activityIndicator;
    UIView *progressBackgroundView;
}
@end

@implementation AppDelegate
@synthesize reachabilityStatus, deviceToken, searchRestaurantDict, isMenuScreen, skipToSettingCheck;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    isMenuScreen = 0;
    skipToSettingCheck = 0;
    searchRestaurantDict = [[NSMutableDictionary alloc] init];
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityIndicator hidesWhenStopped];
    [activityIndicator stopAnimating];
    
    progressBackgroundView = [[UIView alloc] init];
    progressBackgroundView.hidden = YES;
    
    NSDictionary *dict = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    
    if (dict) {
        
    }
    
    if (IS_iOS8) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge
                                                                                             |UIRemoteNotificationTypeSound
                                                                                             |UIRemoteNotificationTypeAlert) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    else
    {
        //register to receive notifications
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    }

    [self initializeLocationManager];
    
    [self performSelector:@selector(getFilterParameters) withObject:nil afterDelay:2.0];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    [locationManager stopUpdatingLocation];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    [self startReachabilityCheck];
    [self initializeLocationManager];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)getFilterParameters
{
    WebService *serviceObj = [[WebService alloc] init];
    serviceObj.delegate = self;
    serviceObj.API_TYPE = FILTER_API;
    serviceObj.API_INDEX = FILTER_API;
    [serviceObj startOperationWithPostParam:nil];
}

#pragma mark - Server Request Delegates

-(void)serviceFinishedWithResult:(id)result API_Index:(NSInteger)index
{
    
}

-(void)serviceFinishedWithResponse:(id)response API_Index:(NSInteger)index
{
    [self performSelector:@selector(getFilterParameters) withObject:nil afterDelay:300.0];
}

-(void)serviceFinishedWithError:(id)error API_Index:(NSInteger)index
{
    [self performSelector:@selector(getFilterParameters) withObject:nil afterDelay:30.0];
}

#pragma mark - Initialize Location manager

-(void)initializeLocationManager
{
    if (locationManager == nil)
    {
        locationManager = [[CLLocationManager alloc]init];
    }
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    locationManager.distanceFilter = CLLocationDistanceMax;
    locationManager.activityType = CLActivityTypeOtherNavigation;
    
    if(IS_iOS8)
    {
        [locationManager requestWhenInUseAuthorization];
    }
    
    [locationManager startUpdatingLocation];
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
    {
        if(IS_iOS8)
        {
            [locationManager requestWhenInUseAuthorization];
        }
        
    }
    
    NSLog(@"authorization status :%d",[CLLocationManager authorizationStatus]);
    
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse)
    {
        [manager startUpdatingLocation];
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"new locations :%@",locations);
    CLLocation *updatedLocation = (CLLocation *)locations[0];
    UserDetails *userObj = [UserDetails sharedManager];
    userObj.latitude = updatedLocation.coordinate.latitude;
    userObj.longitude = updatedLocation.coordinate.longitude;
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"location update error:%@",error.localizedDescription);
    //    [[[UIAlertView alloc]initWithTitle:@"Location update Error !" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}

#pragma mark - Push Notification Methods

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken
{
    
    self.deviceToken = [[[devToken description]
                         stringByReplacingOccurrencesOfString:@"<"withString:@""]
                        stringByReplacingOccurrencesOfString:@">" withString:@""];
    
    NSLog(@"token :%@",self.deviceToken);
    if (self.deviceToken == nil || self.deviceToken.length == 0)
    {
        self.deviceToken = @"";
    }

}

 // Failed to Register for Remote Notifications
 
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    if (self.deviceToken == nil || self.deviceToken.length == 0)
    {
        self.deviceToken = @"";
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
}


#pragma mark - LoaderView Handlers

-(void)showLoaderWithinteractionEnabledOnView:(UIView *)IView
{
    if ([IView viewWithTag:-594])
    {
        return;
    }
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [indicator hidesWhenStopped];
    indicator.tag = -594;
    
    indicator.center = IView.center;
    indicator.color = [UIColor whiteColor];
    [indicator startAnimating];
    
    [IView addSubview:indicator];
}

-(void)hideLoaderWithinteractionEnabledFromView:(UIView *)IView
{
    UIActivityIndicatorView *indicator = (UIActivityIndicatorView *) [IView viewWithTag:-594];
    
    if ([indicator isDescendantOfView:IView])
    {
        [indicator stopAnimating];
        [indicator removeFromSuperview];
    }
}

-(void)showLoaderWithinteractionDisabled
{
    if ([progressBackgroundView isDescendantOfView:self.window])
    {
        return;
    }
    progressBackgroundView.backgroundColor = [UIColor blackColor];
    progressBackgroundView.alpha = 0.6;
    progressBackgroundView.hidden = NO;
    
    progressBackgroundView.frame = UIAppDelegate.window.frame;
    
    [self.window addSubview:progressBackgroundView];
    
    activityIndicator.center = UIAppDelegate.window.center;
    activityIndicator.color = [UIColor whiteColor];
    [activityIndicator startAnimating];
    
    [self.window addSubview:activityIndicator];
}

-(void)hideLoaderWithinteractionDisabled
{
    if ([activityIndicator isDescendantOfView:self.window])
    {
        [activityIndicator stopAnimating];
        [activityIndicator removeFromSuperview];
    }
    
    if ([progressBackgroundView isDescendantOfView:self.window])
    {
        [progressBackgroundView removeFromSuperview];
    }
}

#pragma mark - UIAlert Action

-(void)displayAlertWithMessage:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}

#pragma mark - Reachability Notification

- (void)startReachabilityCheck {
    // Check if we need to create a hostReachability instance
    if (self.hostReachability == nil) {
        // Create an instance of reachability
        self.hostReachability = [Reachability reachabilityForInternetConnection];
        
        // Listen for changes
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reachabilityChanged:)
                                                     name:kReachabilityChangedNotification
                                                   object:nil];
    }
    
    // Start notifications
    [self.hostReachability startNotifier];
    
    NetworkStatus status = [self.hostReachability currentReachabilityStatus];
    if (status == NotReachable)
    {
        reachabilityStatus = false;
    }
    else
    {
        reachabilityStatus = true;
    }
    
}

-(void)reachabilityChanged:(NSNotification *)notif
{
    Reachability *reach = [notif object];
    NetworkStatus status = [reach currentReachabilityStatus];
    if (status == NotReachable)
    {
        reachabilityStatus = false;
    }
    else
    {
        reachabilityStatus = true;
    }
    NSLog(@"notif :%@",notif);
}


@end
