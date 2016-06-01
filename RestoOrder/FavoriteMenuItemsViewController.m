//
//  FavoriteMenuItemsViewController.m
//  RestoOrder
//
//  Created by Suresh Kumar on 18/07/15.
//
//

#import "FavoriteMenuItemsViewController.h"
#import "Constants.h"
#import "WebService.h"
#import "MenuItem.h"
#import "Database.h"

@interface FavoriteMenuItemsViewController ()<WebServiceDelegate, UIAlertViewDelegate>
{
    __weak IBOutlet UITableView *menuTableView;
    NSMutableArray *menuItemsArray;
    NSInteger selectedFavItemIndex;
}
- (IBAction)backBtnAction:(id)sender;
@end

@implementation FavoriteMenuItemsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    menuItemsArray = [[NSMutableArray alloc] init];
    [UIAppDelegate showLoaderWithinteractionDisabled];
    [self loadFavoriteMenuItems];
    // Do any additional setup after loading the view.
}

-(void)loadFavoriteMenuItems
{
    WebService *serviceObj = [[WebService alloc] init];
    serviceObj.delegate = self;
    serviceObj.API_TYPE = FAVORITE_MENU_ITEMS_API;
    serviceObj.API_INDEX = FAVORITE_MENU_ITEMS_API;
    [serviceObj startOperationWithPostParam:nil];
}

#pragma mark - UIButton Action

- (IBAction)backBtnAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - WebService Delegates

-(void)serviceFinishedWithResult:(id)result API_Index:(NSInteger)index
{
    [menuItemsArray removeAllObjects];
    [menuItemsArray addObjectsFromArray:result];
    [menuTableView reloadData];
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
    return menuItemsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FavoriteItemCell"];
    
    if (!IS_iOS8)
    {
        cell.contentView.frame = cell.bounds;
        cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    }
    UILabel *itemNameLabel = (UILabel *)[cell.contentView viewWithTag:2];
    UILabel *dateLabel = (UILabel *)[cell.contentView viewWithTag:3];
    MenuItem *itemObj = menuItemsArray[indexPath.row];
    itemNameLabel.text = itemObj.itemName;
    dateLabel.text = itemObj.favoriteCreationDate;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedFavItemIndex = indexPath.row;
    
    MenuItem *item = menuItemsArray[indexPath.row];
    item.categoryId = item.categoryId;
    
    NSDictionary *restaurantDict = item.restaurantDict;
    
    if ([restaurantDict[@"isOpen"] integerValue] == 1)
    {
        NSDictionary *savedRestaurant = [[Database sharedObject] readRestaurantWithId:restaurantDict[@"Id"]];
        
        NSMutableDictionary *menuItemDict = [[NSMutableDictionary alloc] init];
        [menuItemDict setObject:item.categoryId forKey:@"categoryId"];
        [menuItemDict setObject:item.itemId forKey:@"itemId"];
        [menuItemDict setObject:item.itemName forKey:@"itemName"];
        [menuItemDict setObject:item.price forKey:@"price"];
        [menuItemDict setObject:item.addonArray forKey:@"addonArray"];
        [menuItemDict setObject:item.shortDesc forKey:@"shortDesc"];
        
        
        if (savedRestaurant.allKeys.count > 0)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AddToBasket" object:menuItemDict];
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
                
                NSMutableData *requestBody = [[NSMutableData alloc] initWithData: [NSJSONSerialization dataWithJSONObject:restaurantDict options:NSJSONWritingPrettyPrinted error:nil]];
                
                NSString *restaurantDetailJson = [[NSString alloc] initWithData:requestBody encoding:NSUTF8StringEncoding];
                
                [[Database sharedObject] addNewRestaurantWithId:restaurantDict[@"Id"] DetailDict:restaurantDetailJson];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"AddToBasket" object:menuItemDict];
            }
            
        }
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"Closed !" message:@"Restaurant is closed now, please try after some time." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
   
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
            
            MenuItem *item = menuItemsArray[selectedFavItemIndex];
            item.categoryId = item.categoryId;
            NSDictionary *restaurantDict = item.restaurantDict;
            
            NSMutableDictionary *menuItemDict = [[NSMutableDictionary alloc] init];
            [menuItemDict setObject:item.categoryId forKey:@"categoryId"];
            [menuItemDict setObject:item.itemId forKey:@"itemId"];
            [menuItemDict setObject:item.itemName forKey:@"itemName"];
            [menuItemDict setObject:item.price forKey:@"price"];
            [menuItemDict setObject:item.addonArray forKey:@"addonArray"];
            [menuItemDict setObject:item.shortDesc forKey:@"shortDesc"];
            
            NSMutableData *requestBody = [[NSMutableData alloc] initWithData: [NSJSONSerialization dataWithJSONObject:restaurantDict options:NSJSONWritingPrettyPrinted error:nil]];
            
            NSString *restaurantDetailJson = [[NSString alloc] initWithData:requestBody encoding:NSUTF8StringEncoding];
            
            [[Database sharedObject] addNewRestaurantWithId:restaurantDict[@"Id"] DetailDict:restaurantDetailJson];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AddToBasket" object:menuItemDict];
            
        }
    }
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
