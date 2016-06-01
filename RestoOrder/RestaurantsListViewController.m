//
//  RestaurantsListViewController.m
//  RestoOrder
//
//  Created by Suresh Kumar on 14/07/15.
//
//

#import "RestaurantsListViewController.h"
#import <MapKit/MapKit.h>
#import "RatingView.h"
#import "WebService.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "MenuCategoriesViewController.h"
#import "Restaurant.h"
#import "UIImageView+WebCache.h"
#import "CustomAnnotation.h"
#import "UserDetails.h"
#import "Database.h"
#import "FilterTableView.h"
#import "FilterObject.h"

#define kFilterWidth 270.0

@interface RestaurantsListViewController ()<MKMapViewDelegate, CLLocationManagerDelegate, WebServiceDelegate, RatingViewDelegate, UIAlertViewDelegate, UITextFieldDelegate, FilterTableDelegate>
{
    
    __weak IBOutlet UILabel *tapHereLabel;
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UILabel *resultsCountLabel;
    __weak IBOutlet MKMapView *mapView;
    __weak IBOutlet UIButton *mapListBtn;
    __weak IBOutlet UISearchBar *searchBar;
    __weak IBOutlet UICollectionView *collectionView;
    __weak IBOutlet NSLayoutConstraint *restaurantBottomViewBottomConstraint;
    __weak IBOutlet UIView *restaurantBottomView;
    __weak IBOutlet UIView *collectionViewSuperView;
    __weak IBOutlet UIView *mapViewSuperView;
    __weak IBOutlet UIView *containerViewSuperView;
    NSMutableArray *restaurantsArray;
    NSMutableArray *searchArray;
    NSInteger selectedRestaurantIndex;
    UICollectionReusableView *footerView;
    
    // bottom restaurant view's subviews
    
    __weak IBOutlet UIImageView *restaurantBgImageView;
    
    __weak IBOutlet UILabel *restaurantTypeLbl;
    
    __weak IBOutlet UILabel *restaurantTimeLbl;
    
    __weak IBOutlet UIImageView *restaurantLogoImageView;
    __weak IBOutlet UILabel *restaurantNameLabel;
    __weak IBOutlet UIView *ratingView;
    __weak IBOutlet UIButton *restaurantFavoriteBtn;
    
    RatingView *rateView;
    NSInteger currentSelectedAnnotationIndex;
    
    // make location favorite view
    
    BOOL isKeyboardShown;
    
    __weak IBOutlet UITextField *locationCategoryTextField;
    __weak IBOutlet UILabel *locationNameLabel;
    __weak IBOutlet UIView *makeFavoriteLocationView;
    __weak IBOutlet NSLayoutConstraint *makeFavoriteViewBottomConstraint;
    __weak IBOutlet UIImageView *bgImageView;
    
    // Filter View
    
    __weak IBOutlet NSLayoutConstraint *filterViewWidthConstraint;
    
    __weak IBOutlet FilterTableView *filterTable;
}
- (IBAction)applyFilterBtnAction:(id)sender;
- (IBAction)resetFilterBtnAction:(id)sender;
- (IBAction)cancelFilterAction:(id)sender;


- (IBAction)makeLocationFavoriteAction:(id)sender;

- (IBAction)cancelMakeFavoriteLocationAction:(id)sender;
- (IBAction)navigationBarTapGesture:(id)sender;

- (IBAction)makeRestaurantFavoriteAction:(id)sender;
- (IBAction)findRestaurantBtnAction:(id)sender;
- (IBAction)mapListBtnAction:(id)sender;
- (IBAction)hideRestaurantDetailsBottomView:(id)sender;
- (IBAction)filterBtnAction:(id)sender;

- (IBAction)ordrBtnAction:(id)sender;

@end

@implementation RestaurantsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    selectedRestaurantIndex = -1;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshRestaurantsList:) name:@"refreshList" object:nil];         // refresh restaurant list based on new search filters.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addMoreOrderItemAction:) name:@"AddMore" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(useFavoriteRestaurant:) name:@"UseFavoriteRestaurant" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(useFavoriteLocation:) name:@"UseFavoriteLocation" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRestaurantInfo:) name:@"updateRestaurantInfo" object:nil];      // update current selected restaurant info like rating, favorite from category or menu screens.
    
    restaurantsArray = [[NSMutableArray alloc] init];
    searchArray = [[NSMutableArray alloc] init];
    
    restaurantBottomViewBottomConstraint.constant = - restaurantBottomView.frame.size.height;
    [self.view setNeedsUpdateConstraints];
    [self.view layoutIfNeeded];
    
    rateView = [[RatingView alloc] initWithFrame:CGRectMake(0, (ratingView.frame.size.height - 20)/2, ratingView.frame.size.width, 20)];
    rateView.tag = 100;
    rateView.rate = 2.5;
    rateView.editable = YES;
    rateView.delegate = self;
    rateView.alignment = RateViewAlignmentLeft;
    [ratingView addSubview:rateView];
    
    // setup footer view
    
    footerView = (UICollectionReusableView *)[collectionView viewWithTag:-999];
    footerView.hidden = YES;
    
    mapView.showsUserLocation = YES;
    [self addMapAnnotations];
    
    double latitude = [[UserDetails sharedManager] latitude];
    double longitude = [[UserDetails sharedManager] longitude];
    
    [self setMapRegionWithLatitude:latitude Longitude:longitude];
    
    [UIAppDelegate showLoaderWithinteractionEnabledOnView:self.view];
    [self loadRestaurantsList];
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];

    makeFavoriteLocationView.alpha = 0.0;
    bgImageView.alpha = 0.0;
    makeFavoriteLocationView.layer.cornerRadius = 5.0;
    
    if(!mapListBtn.selected)
    {
        [self mapListBtnAction:nil];
    }
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"searchRestoDict :%@",UIAppDelegate.searchRestaurantDict);
    titleLabel.text = [UIAppDelegate.searchRestaurantDict objectForKey:@"title"];
    
    if ([[UIAppDelegate.searchRestaurantDict objectForKey:@"searchType"] integerValue] == 2)
    {
        tapHereLabel.hidden = NO;
    }
    else
    {
        tapHereLabel.hidden = YES;
    }
}

-(void)loadRestaurantsList
{
    WebService *serviceObj = [[WebService alloc] init];
    serviceObj.delegate = self;
    serviceObj.API_TYPE = FIND_RESTAURANTS_API;
    serviceObj.API_INDEX = FIND_RESTAURANTS_API;
    
    [serviceObj startOperationWithPostParam:UIAppDelegate.searchRestaurantDict];
}

#pragma mark - NSNotification Actions

-(void)addMoreOrderItemAction:(NSNotification *)notif
{
    BOOL check = false;
    if ([self.navigationController.topViewController isKindOfClass:[MenuCategoriesViewController class]])
    {
        check = true;
    }
    else if (check == false)
    {
        for (UIViewController *controller in self.navigationController.viewControllers)
        {
            if ([controller isKindOfClass:[MenuCategoriesViewController class]])
            {
                check = true;
                [self.navigationController popToViewController:controller animated:NO];
                break;
            }
        }
    }
    if (check == false)
    {
        NSLog(@"notif object :%@",notif.object);
        if (selectedRestaurantIndex != -1)
        {
            Restaurant *restaurantObj = restaurantsArray[selectedRestaurantIndex];
            MenuCategoriesViewController *categoryObj = [self.storyboard instantiateViewControllerWithIdentifier:@"MenuCategoryControl"];
            categoryObj.restaurantDict = restaurantObj;
            [self.navigationController pushViewController:categoryObj animated:NO];
        }
        else if (notif.object != nil)
        {
            NSDictionary *object = notif.object;
            Restaurant *restaurantObj = [[Restaurant alloc] init];
            restaurantObj.Id = object[@"Id"];
            restaurantObj.name = object[@"name"];
            restaurantObj.isFavorite = object[@"isfavorite"];
            restaurantObj.ImageUrl = object[@"imageUrl"];
            restaurantObj.logoUrl = object[@"logoImage"];
            restaurantObj.address = object[@"address"];
            restaurantObj.latitude = object[@"latitude"];
            restaurantObj.longitude = object[@"longitude"];
            restaurantObj.contactNo = object[@"contactNo"];
            restaurantObj.distance = object[@"restaurantDistance"];
            restaurantObj.rateCount = object[@"rateCount"];
            restaurantObj.isOpen = object[@"isOpen"];
            restaurantObj.openingHours = object[@"openingHours"];
            restaurantObj.closingHours = object[@"closingHours"];
            restaurantObj.minimumOrder = object[@"minimumOrder"];
            restaurantObj.deliveryTime = object[@"deliveryTime"];
            restaurantObj.serviceTax = object[@"serviceTax"];
            restaurantObj.vat = object[@"vat"];
            restaurantObj.cardTypes = object[@"cardTypes"];
            restaurantObj.defaultTakeAwayTime = object[@"defaultTakeAwayTime"];
            restaurantObj.defaultReserveaTableTime = object[@"defaultReserveaTableTime"];
            restaurantObj.defaultDeliveryTime = object[@"defaultDeliveryTime"];
            restaurantObj.favoriteCreationDate = object[@"favoriteCreationDate"];
            restaurantObj.restaurantType = object[@"cuisinesType"];
            restaurantObj.maxAmount = object[@"maxAmount"];
            restaurantObj.maxQty = object[@"maxQty"];
            
            MenuCategoriesViewController *categoryObj = [self.storyboard instantiateViewControllerWithIdentifier:@"MenuCategoryControl"];
            categoryObj.restaurantDict = restaurantObj;
            [self.navigationController pushViewController:categoryObj animated:NO];
        }
    }
//   [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectHomeTab" object:nil];
}

-(void)refreshRestaurantsList:(NSNotification *)notif
{
    titleLabel.text = [UIAppDelegate.searchRestaurantDict objectForKey:@"title"];
    [UIAppDelegate showLoaderWithinteractionEnabledOnView:self.view];
    [self loadRestaurantsList];
}

-(void)updateRestaurantInfo:(NSNotification *)notif
{
    Restaurant *restaurantObj = notif.object;
    [restaurantsArray replaceObjectAtIndex:selectedRestaurantIndex withObject:restaurantObj];
    [collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:selectedRestaurantIndex inSection:0]]];
}

-(void)useFavoriteRestaurant:(NSNotification *)notif
{
    [self.navigationController popToRootViewControllerAnimated:NO];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectHomeTab" object:nil];
    MenuCategoriesViewController *categoryObj = [self.storyboard instantiateViewControllerWithIdentifier:@"MenuCategoryControl"];
    categoryObj.restaurantDict = (Restaurant *)notif.object;
    [self.navigationController pushViewController:categoryObj animated:NO];
}

-(void)useFavoriteLocation:(NSNotification *)notif
{
    [self.navigationController popToRootViewControllerAnimated:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectHomeTab" object:nil];
    
    tapHereLabel.hidden = YES;
    titleLabel.text = [UIAppDelegate.searchRestaurantDict objectForKey:@"title"];
    [UIAppDelegate showLoaderWithinteractionEnabledOnView:self.view];
    [self loadRestaurantsList];
}

#pragma mark - RatingView Delegate

-(void)rateView:(RatingView *)rateView changedToNewRate:(NSNumber *)rate
{
    Restaurant *restaurantDict = restaurantsArray[currentSelectedAnnotationIndex];
    NSString *rateValue = [NSString stringWithFormat:@"%@",rate];
    WebService *serviceObj = [[WebService alloc] init];
    serviceObj.delegate = self;
    serviceObj.API_TYPE = RESTAURANT_RATING_API;
    serviceObj.API_INDEX = RESTAURANT_RATING_API;
    
    NSMutableDictionary *paraDict = [[NSMutableDictionary alloc] init];
    [paraDict setObject:restaurantDict.Id forKey:@"RestaurantId"];
    [paraDict setObject:rateValue forKey:@"RateValue"];
    [serviceObj startOperationWithPostParam:paraDict];
    
    restaurantDict.rateCount = rateValue;
    
    [restaurantsArray replaceObjectAtIndex:currentSelectedAnnotationIndex withObject:restaurantDict];
    [collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:currentSelectedAnnotationIndex inSection:0]]];
}

#pragma mark - UIButtons Action

- (IBAction)applyFilterBtnAction:(id)sender {
    
    FilterObject *filterObj = [FilterObject sharedManager];
    NSLog(@"cuisines array :%@ cuisines :%@",filterObj.cuisineIndexes,filterObj.cuisines);
    filterViewWidthConstraint.constant = 0.0;
    [self.view updateConstraintsIfNeeded];
    
    [UIView animateWithDuration:0.35 animations:^{
        
        [self.view layoutIfNeeded];
        bgImageView.alpha = 0.0;
        
    } completion:^(BOOL finished) {
        
    }];
    
    [UIAppDelegate.searchRestaurantDict setObject:@"0" forKey:@"page"];
    [UIAppDelegate showLoaderWithinteractionEnabledOnView:self.view];
    [self loadRestaurantsList];
}

- (IBAction)resetFilterBtnAction:(id)sender
{
    FilterObject *filterObj = [FilterObject sharedManager];
    [filterObj.cuisineIndexes removeAllObjects];
    [filterObj.cuisineIndexes addObject:@"0"];
    [filterObj.selectedIds removeAllObjects];
    [filterObj.selectedIds addObject:@"0"];
    filterObj.distanceCountStr = @"0";
    filterObj.preDistanceCountStr = @"0";
    
    [filterTable reloadTable];
}

- (IBAction)cancelFilterAction:(id)sender {
    
    filterViewWidthConstraint.constant = 0.0;
    [self.view updateConstraintsIfNeeded];
    
    [UIView animateWithDuration:0.35 animations:^{
        
        [self.view layoutIfNeeded];
        bgImageView.alpha = 0.0;
        
    } completion:^(BOOL finished) {
        
    }];

    FilterObject *filterObj = [FilterObject sharedManager];
    [filterObj.cuisineIndexes removeAllObjects];
    [filterObj.cuisineIndexes addObjectsFromArray:filterObj.prevCuisineIndexes];
    [filterObj.selectedIds removeAllObjects];
    [filterObj.selectedIds addObjectsFromArray:filterObj.prevCuisineIndexes];
    filterObj.distanceCountStr = filterObj.preDistanceCountStr;
    [filterTable reloadTable];
}

- (IBAction)makeLocationFavoriteAction:(id)sender {
    
    if (locationCategoryTextField.text.length > 0)
    {
        WebService *serviceObj = [[WebService alloc] init];
        serviceObj.delegate = self;
        serviceObj.API_TYPE = MAKE_LOCATION_FAVORITE_API;
        serviceObj.API_INDEX = MAKE_LOCATION_FAVORITE_API;
        
        NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
        [paramDict setObject:locationNameLabel.text forKey:@"Location"];
        [paramDict setObject:[locationCategoryTextField.text capitalizedString] forKey:@"LocationType"];
        [serviceObj startOperationWithPostParam:paramDict];
        
        tapHereLabel.hidden = YES;
        [locationCategoryTextField resignFirstResponder];
        makeFavoriteViewBottomConstraint.constant = 0.0;
        [self.view updateConstraintsIfNeeded];
        
        [UIView animateWithDuration:0.35 animations:^{
            
            [self.view layoutIfNeeded];
            makeFavoriteLocationView.alpha = 0.0;
            bgImageView.alpha = 0.0;
            
        } completion:^(BOOL finished) {
            
        }];

    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Please enter location category !" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
    
}

- (IBAction)cancelMakeFavoriteLocationAction:(id)sender {
    
    if (filterViewWidthConstraint.constant != kFilterWidth)
    {
        [locationCategoryTextField resignFirstResponder];
        makeFavoriteViewBottomConstraint.constant = 0.0;
        [self.view updateConstraintsIfNeeded];
        
        [UIView animateWithDuration:0.35 animations:^{
            
            [self.view layoutIfNeeded];
            makeFavoriteLocationView.alpha = 0.0;
            bgImageView.alpha = 0.0;
            
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (IBAction)navigationBarTapGesture:(id)sender
{
    if (tapHereLabel.hidden == NO)
    {
        UserDetails *userDetailObj = [UserDetails sharedManager];
        if (userDetailObj.userId != nil)
        {
            NSLog(@"tap to make favorite");
            locationNameLabel.text = titleLabel.text;
            makeFavoriteLocationView.alpha = 1.0;
            [locationCategoryTextField becomeFirstResponder];
    
            [UIView animateWithDuration:0.5 animations:^{
                bgImageView.alpha = 0.6;
            } completion:^(BOOL finished) {
                
            }];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not Login" message:@"Please login to make location favorite !" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Login", nil];
            alert.tag = 111;
            [alert show];
        }
    }
}

- (IBAction)makeRestaurantFavoriteAction:(id)sender {
    
    UserDetails *userDetailObj = [UserDetails sharedManager];
    if (userDetailObj.userId != nil)
    {
        Restaurant *restaurantDict = restaurantsArray[currentSelectedAnnotationIndex];
        UIButton *btn = sender;
        NSString *isFavorite;
        if (!btn.selected)
        {
            btn.selected = YES;
            isFavorite = @"1";
            restaurantDict.isFavorite = @"1";
        }
        else
        {
            btn.selected = NO;
            isFavorite = @"0";
            restaurantDict.isFavorite = @"0";
        }
        
        WebService *serviceObj = [[WebService alloc] init];
        serviceObj.delegate = self;
        serviceObj.API_TYPE = MAKE_RESTAURANT_FAVORITE_API;
        serviceObj.API_INDEX = MAKE_RESTAURANT_FAVORITE_API;
        
        NSMutableDictionary *paraDict = [[NSMutableDictionary alloc] init];
        [paraDict setObject:restaurantDict.Id forKey:@"RestaurantId"];
        [paraDict setObject:isFavorite forKey:@"Isfavorite"];
        [serviceObj startOperationWithPostParam:paraDict];
        
        [restaurantsArray replaceObjectAtIndex:currentSelectedAnnotationIndex withObject:restaurantDict];
        [collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:currentSelectedAnnotationIndex inSection:0]]];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not Login" message:@"Please login to make restaurant favorite !" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Login", nil];
        alert.tag = 111;
        [alert show];
    }
}

- (IBAction)findRestaurantBtnAction:(id)sender {
    
    [self hideRestaurantDetailsBottomView:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PresentFindRestaurantScreen" object:nil];
}

- (IBAction)mapListBtnAction:(id)sender {
    
    if (restaurantBottomViewBottomConstraint.constant == 0)
    {
        restaurantBottomViewBottomConstraint.constant = - restaurantBottomView.frame.size.height;
        [self.view setNeedsUpdateConstraints];
        [self.view layoutIfNeeded];
    }
        
    [UIView transitionWithView:containerViewSuperView
                      duration:1.0
                       options:(mapListBtn.selected ? UIViewAnimationOptionTransitionFlipFromRight :
                                UIViewAnimationOptionTransitionFlipFromLeft)
                    animations: ^{
                        if(mapListBtn.selected)
                        {
                            mapListBtn.selected = NO;
                            mapViewSuperView.hidden = YES;
                            collectionViewSuperView.hidden = NO;
                        }
                        else
                        {
                            mapListBtn.selected = YES;
                            mapViewSuperView.hidden = NO;
                            collectionViewSuperView.hidden = YES;
                        }
                    }
     
                    completion:^(BOOL finished) {
                        
                    }];

}

- (IBAction)hideRestaurantDetailsBottomView:(id)sender {
    
    restaurantBottomViewBottomConstraint.constant = -restaurantBottomView.frame.size.height;
    [self updateBottomViewFrame];
}

- (IBAction)filterBtnAction:(id)sender {
    
    [self hideRestaurantDetailsBottomView:nil];
    
    FilterObject *filterObj = [FilterObject sharedManager];
    if (filterObj.prevCuisineIndexes == nil)
    {
        filterObj.prevCuisineIndexes = [[NSMutableArray alloc] init];
    }
    [filterObj.prevCuisineIndexes removeAllObjects];
    [filterObj.prevCuisineIndexes addObjectsFromArray:filterObj.cuisineIndexes];
    if (filterObj.prevSelectedIds == nil)
    {
        filterObj.prevSelectedIds = [[NSMutableArray alloc] init];
    }
    [filterObj.prevSelectedIds removeAllObjects];
    [filterObj.prevSelectedIds addObjectsFromArray:filterObj.selectedIds];
    filterObj.preDistanceCountStr = filterObj.distanceCountStr;
    
    [filterTable reloadTable];
    
    filterViewWidthConstraint.constant = kFilterWidth;
    [self.view updateConstraintsIfNeeded];
    
    [UIView animateWithDuration:0.35 animations:^{
        
        [self.view layoutIfNeeded];
        bgImageView.alpha = 0.6;
        
    } completion:^(BOOL finished) {
        
    }];

}

- (IBAction)ordrBtnAction:(id)sender {
    
    selectedRestaurantIndex = currentSelectedAnnotationIndex;
    
    [self initiateOrderWithDetails];
}

-(void)setMapRegionWithLatitude:(double)latitude Longitude:(double)longitude
{
    //  set map region
    
    CLLocationCoordinate2D centerCoordinates = CLLocationCoordinate2DMake(latitude, longitude);
    
    [mapView setCenterCoordinate:centerCoordinates animated:YES];
    
    MKCoordinateSpan span = MKCoordinateSpanMake(0.050, 0.050);
    MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinates, span);
    
    [mapView setRegion:region];
}

-(void)addMapAnnotations
{
    [mapView removeAnnotations:mapView.annotations];
    
    NSMutableArray *annotationsArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < restaurantsArray.count; i++)
    {
        Restaurant *restaurantObj = restaurantsArray[i];
        double latitude = [restaurantObj.latitude doubleValue];
        double longitude = [restaurantObj.longitude doubleValue];
        NSString *name = restaurantObj.name;
        NSInteger index = i;
        CustomAnnotation *customAnnotation = [[CustomAnnotation alloc] init];
        customAnnotation = [customAnnotation createAnnotationWithLatitude:latitude Longitude:longitude Title:name Index:index];
        [annotationsArray addObject:customAnnotation];
    }
    
    if (annotationsArray.count > 0)
    {
        [mapView addAnnotations:annotationsArray];
    }
}

-(void)markRestaurantFavoriteInList:(id)sender
{
    UserDetails *userDetailObj = [UserDetails sharedManager];
    if (userDetailObj.userId != nil)
    {
        CGPoint buttonPosition = [sender convertPoint:CGPointZero
                                               toView:collectionView];
        NSIndexPath *indexPath = [collectionView indexPathForItemAtPoint:buttonPosition];
        Restaurant *restaurantObj = restaurantsArray[indexPath.row];
        NSString *isFavorite;
        if ([restaurantObj.isFavorite integerValue] == 1)
        {
            isFavorite = @"0";
            restaurantObj.isFavorite = @"0";
        }
        else
        {
            isFavorite = @"1";
            restaurantObj.isFavorite = @"1";
        }
        
        WebService *serviceObj = [[WebService alloc] init];
        serviceObj.delegate = self;
        serviceObj.API_TYPE = MAKE_RESTAURANT_FAVORITE_API;
        serviceObj.API_INDEX = MAKE_RESTAURANT_FAVORITE_API;
        NSMutableDictionary *paraDict = [[NSMutableDictionary alloc] init];
        [paraDict setObject:restaurantObj.Id forKey:@"RestaurantId"];
        [paraDict setObject:isFavorite forKey:@"Isfavorite"];
        [serviceObj startOperationWithPostParam:paraDict];
        
        [restaurantsArray replaceObjectAtIndex:indexPath.row withObject:restaurantObj];
        [collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not Login" message:@"Please login to make restaurant favorite !" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Login", nil];
        alert.tag = 111;
        [alert show];
    }
}

#pragma mark - Keyboard Delegate

- (void)keyboardWillHide:(NSNotification *)n
{
    isKeyboardShown = NO;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView commitAnimations];
    
}

- (void)keyboardWillShow:(NSNotification *)n
{
    if (isKeyboardShown == YES)
    {
        return;
    }
    isKeyboardShown = YES;
    NSDictionary* userInfo = [n userInfo];
    
    // get the size of the keyboard
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    makeFavoriteViewBottomConstraint.constant = keyboardSize.height;
    [self.view updateConstraintsIfNeeded];
    [self.view layoutIfNeeded];
    
    [UIView commitAnimations];
    
}


#pragma mark - WebService Delegates

-(void)serviceFinishedWithResult:(id)result API_Index:(NSInteger)index
{
    if (index == FIND_RESTAURANTS_API)
    {
        if ([result isKindOfClass:[NSArray class]])
        {
            NSArray *resultArray = [NSArray arrayWithArray:(NSArray *)result];
            
            if ([[UIAppDelegate.searchRestaurantDict objectForKey:@"page"] integerValue] == 0)
            {
                [restaurantsArray removeAllObjects];
            }
            [restaurantsArray addObjectsFromArray:resultArray];
            [searchArray removeAllObjects];
            [searchArray addObjectsFromArray:restaurantsArray];
            
            resultsCountLabel.text = [NSString stringWithFormat:@"\"%lu Results\"",(unsigned long)restaurantsArray.count];
            footerView.hidden = YES;
            [collectionView reloadData];
            
            [self addMapAnnotations];
            
            for (int i = 0; i < restaurantsArray.count; i ++)
            {
                Restaurant *restaurantObj = restaurantsArray[i];
                double latitude = [restaurantObj.latitude doubleValue];
                double longitude = [restaurantObj.longitude doubleValue];
                
                if (latitude != 0.0 && longitude  != 0.0)
                {
                    [self setMapRegionWithLatitude:latitude Longitude:longitude];
                    
                    break;
                }
                
            }
                        
        }
        
    }
    else if (index == MAKE_RESTAURANT_FAVORITE_API)
    {
        
    }
    else if (index == RESTAURANT_RATING_API)
    {
        
    }
    else if (index == MAKE_LOCATION_FAVORITE_API)
    {
        tapHereLabel.hidden = YES;
        [UIAppDelegate displayAlertWithMessage:@"This Location has been made your favorite, use it from favorite section in Settings to place your order quickly !"];
    }
    
//    [UIAppDelegate hideLoaderWithinteractionDisabled];
    [UIAppDelegate hideLoaderWithinteractionEnabledFromView:self.view];
}

-(void)serviceFinishedWithResponse:(id)response API_Index:(NSInteger)index
{
    if (index == FIND_RESTAURANTS_API)
    {
        if ([[UIAppDelegate.searchRestaurantDict objectForKey:@"page"] integerValue] == 0)
        {
            [restaurantsArray removeAllObjects];
            [collectionView reloadData];
            resultsCountLabel.text = @"";
            [mapView removeAnnotations:mapView.annotations];
        }
    }
    else if (index == MAKE_LOCATION_FAVORITE_API)
    {
        tapHereLabel.hidden = NO;
    }
    footerView.hidden = YES;
//    [UIAppDelegate hideLoaderWithinteractionDisabled];
    [UIAppDelegate hideLoaderWithinteractionEnabledFromView:self.view];
    [UIAppDelegate displayAlertWithMessage:response];
}

-(void)serviceFinishedWithError:(id)error API_Index:(NSInteger)index
{
    if (index == FIND_RESTAURANTS_API)
    {
        if ([[UIAppDelegate.searchRestaurantDict objectForKey:@"page"] integerValue] == 0)
        {
            [restaurantsArray removeAllObjects];
            [collectionView reloadData];
            resultsCountLabel.text = @"";
            [mapView removeAnnotations:mapView.annotations];
            
            if ([error isEqualToString:@"Restaurant not found."] || [error isEqualToString:@"Records not found."])
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error message:@"Do you want to update your search range filters to get better results !" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Filter", nil];
                alert.tag = 110;
                [alert show];
            }
            else
            {
                [UIAppDelegate displayAlertWithMessage:error];
            }
            
        }
    }
    else if (index == MAKE_LOCATION_FAVORITE_API)
    {
        tapHereLabel.hidden = NO;
        [UIAppDelegate displayAlertWithMessage:error];
    }
    
    footerView.hidden = YES;
//    [UIAppDelegate hideLoaderWithinteractionDisabled];
    [UIAppDelegate hideLoaderWithinteractionEnabledFromView:self.view];
    
}

#pragma mark - MapView Delegates

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString *annotationIdentifier = @"AnnotationIdentifier";
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        MKPinAnnotationView *pinAnnotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
        pinAnnotationView.pinColor = MKPinAnnotationColorRed;
        pinAnnotationView.animatesDrop = YES;
        
        return pinAnnotationView;
    }
    else
    {
        MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
        CustomAnnotation *customAnnotation = (CustomAnnotation *)annotation;
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 60)];
        view.backgroundColor = [UIColor clearColor];
        UIImageView *annotaionImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_icon.png"]];
        annotaionImageView.frame = CGRectMake(0, 0, 80, 35);
        annotaionImageView.contentMode = UIViewContentModeCenter;
        [view addSubview:annotaionImageView];
        
        UILabel *titleLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, 80, 15)];
        titleLabel1.text = customAnnotation.name;
        titleLabel1.layer.borderWidth = 1.0;
        titleLabel1.layer.borderColor = [UIColor lightGrayColor].CGColor;
        titleLabel1.layer.cornerRadius = 5.0;
        titleLabel1.layer.backgroundColor = [UIColor whiteColor].CGColor;
        titleLabel1.font = [UIFont fontWithName:@"HelveticaNeue" size:10.0];
        titleLabel1.textAlignment = NSTextAlignmentCenter;
        [view addSubview:titleLabel1];
        
        [annotationView addSubview:view];
        
        view.center = annotationView.center;
        
        return annotationView;
    }
    return nil;
}

-(void)mapView:(MKMapView *)mapView1 didSelectAnnotationView:(MKAnnotationView *)view
{
    if (![view.annotation isKindOfClass:[MKUserLocation class]])
    {
        restaurantBottomViewBottomConstraint.constant = 0.0;
        CustomAnnotation *customAnnotation = (CustomAnnotation *)view.annotation;
        NSInteger index = customAnnotation.index;
        [self setUpRestaurantDetailsInBottomViewAtIndex:index];
        
        [self updateBottomViewFrame];
        [mapView1 deselectAnnotation:view.annotation animated:YES];
    }
}

-(void)setUpRestaurantDetailsInBottomViewAtIndex:(NSInteger)index
{
    currentSelectedAnnotationIndex = index;
    Restaurant *restaurantObj = restaurantsArray[index];
    [restaurantBgImageView sd_setImageWithURL:[NSURL URLWithString:restaurantObj.ImageUrl] placeholderImage:[UIImage imageNamed:@"listing_img"]];
    [restaurantLogoImageView sd_setImageWithURL:[NSURL URLWithString:restaurantObj.ImageUrl] placeholderImage:[UIImage imageNamed:@"listing_img"]];
    restaurantNameLabel.text = restaurantObj.name;
    restaurantTypeLbl.text = restaurantObj.restaurantType;
    restaurantTimeLbl.text = [NSString stringWithFormat:@"Timing: %@ - %@",restaurantObj.openingHours, restaurantObj.closingHours];
    rateView.delegate = nil;
    rateView.rate = [restaurantObj.rateCount floatValue];
    rateView.delegate = self;
    if ([restaurantObj.isFavorite integerValue] == 1)
    {
        restaurantFavoriteBtn.selected = YES;
    }
    else
    {
        restaurantFavoriteBtn.selected = NO;
    }
}

-(void)updateBottomViewFrame
{
    [self.view updateConstraintsIfNeeded];
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - UICollectionView Delegates

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    float width = [[UIScreen mainScreen] bounds].size.width;
    NSLog(@"height :%f",(21*(width-30)/2)/29);
    
    return CGSizeMake((width-30)/2, (21*(width-30)/2)/29);
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return restaurantsArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView1 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView1 dequeueReusableCellWithReuseIdentifier:@"restaurantCollectionCell" forIndexPath:indexPath];
    UIImageView *restaurantImageView = (UIImageView *)[cell.contentView viewWithTag:1];
    UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:2];
    UILabel *distanceLabel = (UILabel *)[cell.contentView viewWithTag:3];
    UIButton *favoriteBtn = (UIButton *)[cell.contentView viewWithTag:4];
    UIImageView *checkImageView = (UIImageView *)[cell.contentView viewWithTag:5];
    [favoriteBtn addTarget:self action:@selector(markRestaurantFavoriteInList:) forControlEvents:UIControlEventTouchUpInside];
    Restaurant *restaurantObj = restaurantsArray[indexPath.row];
    [restaurantImageView sd_setImageWithURL:[NSURL URLWithString:restaurantObj.ImageUrl] placeholderImage:[UIImage imageNamed:@"listing_img"]];
    nameLabel.text = restaurantObj.name;
    distanceLabel.text = restaurantObj.distance;
    if ([restaurantObj.isFavorite integerValue] == 1)
    {
        favoriteBtn.selected = YES;
    }
    else
    {
        favoriteBtn.selected = NO;
    }
    
    if ([restaurantObj.isLocallySaved integerValue] == 1)
    {
        checkImageView.hidden = NO;
        selectedRestaurantIndex = indexPath.row;
    }
    else
    {
        checkImageView.hidden = YES;
    }
    
    if (indexPath.row == restaurantsArray.count - 2 && [[UIAppDelegate.searchRestaurantDict objectForKey:@"nextPage"] integerValue] == 1 && (!([searchBar isFirstResponder] || searchBar.text.length != 0)))
    {
        footerView.hidden = NO;
        NSInteger currentPage = [[UIAppDelegate.searchRestaurantDict objectForKey:@"page"] integerValue];
        currentPage = currentPage + 1;
        NSString *page = [NSString stringWithFormat:@"%ld",(long)currentPage];
        [UIAppDelegate.searchRestaurantDict setValue:page forKey:@"page"];
        
        [self loadRestaurantsList];
    }
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView1 didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    selectedRestaurantIndex = indexPath.row;
    
    [self initiateOrderWithDetails];
}

-(void)initiateOrderWithDetails
{
    Restaurant *restaurantObj = restaurantsArray[selectedRestaurantIndex];
    
    if ([restaurantObj.isOpen integerValue] == 1)
    {
        NSDictionary *savedRestaurant = [[Database sharedObject] readRestaurantWithId:restaurantObj.Id];
        if (savedRestaurant.allKeys.count > 0)
        {
            [self performSegueWithIdentifier:@"RestaurantListSegue" sender:nil];
        }
        else
        {
            NSArray *cartItems = [[Database sharedObject] readAllProducts];
            if (cartItems.count > 0)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Do you want to empty your cart" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue", nil];
                alert.tag = 112;
                [alert show];
            }
            else
            {
                [[Database sharedObject] deleteRestaurantDetail];
                [[Database sharedObject] deleteAllProducts];
                NSMutableDictionary *restaurantDetail = [[NSMutableDictionary alloc] init];
                [restaurantDetail setObject:restaurantObj.name forKey:@"name"];
                [restaurantDetail setObject:restaurantObj.Id forKey:@"Id"];
                [restaurantDetail setObject:restaurantObj.address forKey:@"address"];
                [restaurantDetail setObject:restaurantObj.contactNo forKey:@"contactNo"];
                [restaurantDetail setObject:restaurantObj.minimumOrder forKey:@"minimumOrder"];
                [restaurantDetail setObject:restaurantObj.deliveryTime forKey:@"deliveryTime"];
                [restaurantDetail setObject:restaurantObj.serviceTax forKey:@"serviceTax"];
                [restaurantDetail setObject:restaurantObj.vat forKey:@"vat"];
                [restaurantDetail setObject:restaurantObj.cardTypes forKey:@"cardTypes"];
                [restaurantDetail setObject:restaurantObj.defaultTakeAwayTime forKey:@"defaultTakeAwayTime"];
                [restaurantDetail setObject:restaurantObj.defaultReserveaTableTime forKey:@"defaultReserveaTableTime"];
                [restaurantDetail setObject:restaurantObj.defaultDeliveryTime forKey:@"defaultDeliveryTime"];
                [restaurantDetail setObject:restaurantObj.openingHours forKey:@"openingHours"];
                [restaurantDetail setObject:restaurantObj.closingHours forKey:@"closingHours"];
                [restaurantDetail setObject:restaurantObj.maxAmount forKey:@"maxAmount"];
                [restaurantDetail setObject:restaurantObj.maxQty forKey:@"maxQty"];
                
                [restaurantDetail setObject:restaurantObj.isFavorite forKey:@"isfavorite"];
                [restaurantDetail setObject:restaurantObj.ImageUrl forKey:@"imageUrl"];
                [restaurantDetail setObject:restaurantObj.logoUrl forKey:@"logoImage"];
                [restaurantDetail setObject:restaurantObj.latitude forKey:@"latitude"];
                [restaurantDetail setObject:restaurantObj.longitude forKey:@"longitude"];
                [restaurantDetail setObject:restaurantObj.distance forKey:@"restaurantDistance"];
                [restaurantDetail setObject:restaurantObj.rateCount forKey:@"rateCount"];
                [restaurantDetail setObject:restaurantObj.isOpen forKey:@"isOpen"];
                [restaurantDetail setObject:restaurantObj.restaurantType forKey:@"cuisinesType"];
                
                
                NSMutableData *requestBody = [[NSMutableData alloc] initWithData: [NSJSONSerialization dataWithJSONObject:restaurantDetail options:NSJSONWritingPrettyPrinted error:nil]];
                
                NSString *restaurantDetailJson = [[NSString alloc] initWithData:requestBody encoding:NSUTF8StringEncoding];
                
                [[Database sharedObject] addNewRestaurantWithId:restaurantObj.Id DetailDict:restaurantDetailJson];
                
                NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:restaurantsArray];
                for (int i = 0 ; i < tempArray.count ; i ++)
                {
                    Restaurant *restauObj = tempArray[i];
                    if ([restauObj.isLocallySaved integerValue] == 1)
                    {
                        NSInteger index = [tempArray indexOfObject:restauObj];
                        restauObj.isLocallySaved = @"0";
                        [restaurantsArray replaceObjectAtIndex:index withObject:restauObj];
                    }
                }
                restaurantObj.isLocallySaved = @"1";
                [restaurantsArray replaceObjectAtIndex:selectedRestaurantIndex withObject:restaurantObj];
                [collectionView reloadData];
                
                [self performSegueWithIdentifier:@"RestaurantListSegue" sender:nil];
            }
            
        }
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"Closed !" message:@"Restaurant is closed now, please try after some time." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
    

}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView1 viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        
        reusableview = footerview;
    }

    
    return reusableview;
}

#pragma mark - UIAlertView Delegates

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 112)
    {
        if (buttonIndex == 0)
        {
            
        }
        else if (buttonIndex == 1)
        {
            [[Database sharedObject] deleteRestaurantDetail];
            [[Database sharedObject] deleteAllProducts];
            
            Restaurant *restaurantObj = restaurantsArray[selectedRestaurantIndex];
            
            NSMutableDictionary *restaurantDetail = [[NSMutableDictionary alloc] init];
            [restaurantDetail setObject:restaurantObj.name forKey:@"name"];
            [restaurantDetail setObject:restaurantObj.Id forKey:@"Id"];
            [restaurantDetail setObject:restaurantObj.address forKey:@"address"];
            [restaurantDetail setObject:restaurantObj.contactNo forKey:@"contactNo"];
            [restaurantDetail setObject:restaurantObj.minimumOrder forKey:@"minimumOrder"];
            [restaurantDetail setObject:restaurantObj.deliveryTime forKey:@"deliveryTime"];
            [restaurantDetail setObject:restaurantObj.serviceTax forKey:@"serviceTax"];
            [restaurantDetail setObject:restaurantObj.vat forKey:@"vat"];
            [restaurantDetail setObject:restaurantObj.cardTypes forKey:@"cardTypes"];
            [restaurantDetail setObject:restaurantObj.defaultTakeAwayTime forKey:@"defaultTakeAwayTime"];
            [restaurantDetail setObject:restaurantObj.defaultReserveaTableTime forKey:@"defaultReserveaTableTime"];
            [restaurantDetail setObject:restaurantObj.defaultDeliveryTime forKey:@"defaultDeliveryTime"];
            [restaurantDetail setObject:restaurantObj.openingHours forKey:@"openingHours"];
            [restaurantDetail setObject:restaurantObj.closingHours forKey:@"closingHours"];
            [restaurantDetail setObject:restaurantObj.maxAmount forKey:@"maxAmount"];
            [restaurantDetail setObject:restaurantObj.maxQty forKey:@"maxQty"];
            
            [restaurantDetail setObject:restaurantObj.isFavorite forKey:@"isfavorite"];
            [restaurantDetail setObject:restaurantObj.ImageUrl forKey:@"imageUrl"];
            [restaurantDetail setObject:restaurantObj.logoUrl forKey:@"logoImage"];
            [restaurantDetail setObject:restaurantObj.latitude forKey:@"latitude"];
            [restaurantDetail setObject:restaurantObj.longitude forKey:@"longitude"];
            [restaurantDetail setObject:restaurantObj.distance forKey:@"restaurantDistance"];
            [restaurantDetail setObject:restaurantObj.rateCount forKey:@"rateCount"];
            [restaurantDetail setObject:restaurantObj.isOpen forKey:@"isOpen"];
            [restaurantDetail setObject:restaurantObj.restaurantType forKey:@"cuisinesType"];
            
            NSMutableData *requestBody = [[NSMutableData alloc] initWithData: [NSJSONSerialization dataWithJSONObject:restaurantDetail options:NSJSONWritingPrettyPrinted error:nil]];
            
            NSString *restaurantDetailJson = [[NSString alloc] initWithData:requestBody encoding:NSUTF8StringEncoding];
            
            [[Database sharedObject] addNewRestaurantWithId:restaurantObj.Id DetailDict:restaurantDetailJson];
            
            for (Restaurant *restObj in restaurantsArray)
            {
                if ([restObj.isLocallySaved integerValue] == 1)
                {
                    restObj.isLocallySaved = @"0";
                }
            }
            restaurantObj.isLocallySaved = @"1";
            [restaurantsArray replaceObjectAtIndex:selectedRestaurantIndex withObject:restaurantObj];
            [collectionView reloadData];
            
            [self performSegueWithIdentifier:@"RestaurantListSegue" sender:nil];
        }
    }
    else if (alertView.tag == 111)
    {
        if (buttonIndex == 0)
        {
            
        }
        else if (buttonIndex == 1)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"login" object:nil];
        }
    }
    else if (alertView.tag == 110)
    {
        if (buttonIndex == 0)
        {
            
        }
        else if (buttonIndex == 1)
        {
            [self filterBtnAction:nil];
        }
    }
}

#pragma mark - SearchBar Delegates

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar1
{
    [searchBar1 setShowsCancelButton:YES animated:YES];
    UIButton *cancelButton = [searchBar1 valueForKey:@"_cancelButton"];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    if ([cancelButton respondsToSelector:@selector(setEnabled:)])
    {
        [cancelButton setEnabled:YES];
    }
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar1
{
    [searchBar1 setShowsCancelButton:NO animated:YES];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar1
{
    NSLog(@"search btn clicked");
    [self searchLocalRestaurantsWithText:searchBar1.text];
    [searchBar1 resignFirstResponder];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"text did change %@",searchText);
    [self searchLocalRestaurantsWithText:searchText];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar1
{
    NSLog(@"cancel btn clicked");
    [restaurantsArray removeAllObjects];
    [restaurantsArray addObjectsFromArray:searchArray];
    [collectionView reloadData];
    searchBar1.text = @"";
    [searchBar1 resignFirstResponder];
}

-(void)searchLocalRestaurantsWithText:(NSString *)text
{
    NSLog(@"result list btn clicked");
    [restaurantsArray removeAllObjects];
    if (text.length != 0)
    {
        NSMutableArray *namesArray = [[NSMutableArray alloc] initWithArray:searchArray];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@",text];
        namesArray = [[namesArray filteredArrayUsingPredicate:predicate] mutableCopy];
        
        NSMutableArray *addressArray = [[NSMutableArray alloc] initWithArray:searchArray];
        
        NSPredicate *predicate_address = [NSPredicate predicateWithFormat:@"address CONTAINS[cd] %@",text];
        addressArray = [[addressArray filteredArrayUsingPredicate:predicate_address] mutableCopy];
        
        for (int i = 0; i < addressArray.count; i ++) {
            
            if ([namesArray containsObject:addressArray[i]])
            {
                [namesArray removeObject:addressArray[i]];
            }
        }
        
        [restaurantsArray addObjectsFromArray:namesArray];
        [restaurantsArray addObjectsFromArray:addressArray];
    }
    else
    {
        [restaurantsArray addObjectsFromArray:searchArray];
    }
    [collectionView reloadData];
}

#pragma mark - UITextField Delegates

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length > 0)
    {
        [self makeLocationFavoriteAction:nil];
    }
    return YES;
}

#pragma mark - UITouch Delegates

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [searchBar resignFirstResponder];
}

#pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 
     MenuCategoriesViewController *categoryObj = (MenuCategoriesViewController *)[segue destinationViewController];
     categoryObj.restaurantDict = restaurantsArray[selectedRestaurantIndex];
     
 }


@end
