//
//  FavoriteRestaurantsViewController.m
//  RestoOrder
//
//  Created by Suresh Kumar on 18/07/15.
//
//

#import "FavoriteRestaurantsViewController.h"
#import "Constants.h"
#import "WebService.h"
#import "Restaurant.h"
#import "Database.h"

@interface FavoriteRestaurantsViewController ()<WebServiceDelegate>
{
    NSMutableArray *restaurantsArray;
    __weak IBOutlet UITableView *restaurantsTableView;
    NSInteger selectedRestaurantIndex;
}
- (IBAction)backBtnAction:(id)sender;
@end

@implementation FavoriteRestaurantsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    restaurantsArray = [[NSMutableArray alloc] init];
    [UIAppDelegate showLoaderWithinteractionDisabled];
    [self loadFavoriteRestaurants];
    // Do any additional setup after loading the view.
}

-(void)loadFavoriteRestaurants
{
    WebService *serviceObj = [[WebService alloc] init];
    serviceObj.delegate = self;
    serviceObj.API_TYPE = FIND_RESTAURANTS_API;
    serviceObj.API_INDEX = FIND_RESTAURANTS_API;
    
    [UIAppDelegate.searchRestaurantDict setObject:@"1" forKey:@"searchType"];
//    [UIAppDelegate.searchRestaurantDict setObject:@"0" forKey:@"page"];
    [serviceObj startOperationWithPostParam:UIAppDelegate.searchRestaurantDict];
}

#pragma mark - UIButton Action

- (IBAction)backBtnAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - WebService Delegates

-(void)serviceFinishedWithResult:(id)result API_Index:(NSInteger)index
{
    NSArray *resultArray = [NSArray arrayWithArray:(NSArray *)result];
    if (resultArray.count > 0)
    {
        if ([[UIAppDelegate.searchRestaurantDict objectForKey:@"page"] integerValue] == 0)
        {
            [restaurantsArray removeAllObjects];
        }
        [restaurantsArray addObjectsFromArray:resultArray];
    }
    [restaurantsTableView reloadData];

    [UIAppDelegate hideLoaderWithinteractionDisabled];
}

-(void)serviceFinishedWithResponse:(id)response API_Index:(NSInteger)index
{
    [UIAppDelegate hideLoaderWithinteractionDisabled];
    [UIAppDelegate displayAlertWithMessage:response];
}

-(void)serviceFinishedWithError:(id)error API_Index:(NSInteger)index
{
    [UIAppDelegate hideLoaderWithinteractionDisabled];
    [UIAppDelegate displayAlertWithMessage:error];
}


#pragma mark - UITableView Datasource/Delegates

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return restaurantsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FavoriteRestaurantCell"];
    
    if (!IS_iOS8)
    {
        cell.contentView.frame = cell.bounds;
        cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    }
    UILabel *restaurantNameLabel = (UILabel *)[cell.contentView viewWithTag:2];
    UILabel *dateLabel = (UILabel *)[cell.contentView viewWithTag:3];
    Restaurant *restaurantObj = restaurantsArray[indexPath.row];
    restaurantNameLabel.text = restaurantObj.name;
    dateLabel.text = restaurantObj.favoriteCreationDate;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Restaurant *restaurantObj = restaurantsArray[indexPath.row];
    selectedRestaurantIndex = indexPath.row;
    NSDictionary *savedRestaurant = [[Database sharedObject] readRestaurantWithId:restaurantObj.Id];
    if (savedRestaurant.allKeys.count > 0)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectHomeTab" object:nil];
        [self performSelector:@selector(useFavoriteRestaurant:) withObject:restaurantObj afterDelay:0.2];
    }
    else
    {
        NSArray *cartItems = [[Database sharedObject] readAllProducts];
        if (cartItems.count > 0)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Do you want to empty your cart" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue", nil];
            alert.tag = 111;
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
            
//            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:restaurantsArray];
//            for (int i = 0 ; i < tempArray.count ; i ++)
//            {
//                Restaurant *restauObj = tempArray[i];
//                if ([restauObj.isLocallySaved integerValue] == 1)
//                {
//                    NSInteger index = [tempArray indexOfObject:restauObj];
//                    restauObj.isLocallySaved = @"0";
//                    [restaurantsArray replaceObjectAtIndex:index withObject:restauObj];
//                }
//            }
//            restaurantObj.isLocallySaved = @"1";
//            [restaurantsArray replaceObjectAtIndex:selectedRestaurantIndex withObject:restaurantObj];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectHomeTab" object:nil];
            
            [self performSelector:@selector(useFavoriteRestaurant:) withObject:restaurantObj afterDelay:0.2];
            
        }
        
    }

}

#pragma mark - UIAlertView Delegates

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 111)
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
            
//            for (Restaurant *restObj in restaurantsArray)
//            {
//                if ([restObj.isLocallySaved integerValue] == 1)
//                {
//                    restObj.isLocallySaved = @"0";
//                }
//            }
//            restaurantObj.isLocallySaved = @"1";
//            [restaurantsArray replaceObjectAtIndex:selectedRestaurantIndex withObject:restaurantObj];
//            
//            [self performSegueWithIdentifier:@"RestaurantListSegue" sender:nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectHomeTab" object:nil];
            [self performSelector:@selector(useFavoriteRestaurant:) withObject:restaurantObj afterDelay:0.2];
        }
    }
}

-(void)useFavoriteRestaurant:(Restaurant *)restaurantObj
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UseFavoriteRestaurant" object:restaurantObj];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
