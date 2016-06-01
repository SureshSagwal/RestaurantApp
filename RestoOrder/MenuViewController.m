//
//  MenuViewController.m
//  RestoOrder
//
//  Created by Suresh Kumar on 14/07/15.
//
//

#import "MenuViewController.h"
#import "RatingView.h"
#import "Constants.h"
#import "WebService.h"
#import "UIImageView+WebCache.h"
#import "MenuItem.h"
#import "UserDetails.h"

#define kTableHeaderHeight  156.0

@interface MenuViewController ()<WebServiceDelegate, RatingViewDelegate>
{    
    __weak IBOutlet UITableView *menuTableView;
    __weak IBOutlet UIView *ratingView;
    UIView *headerView;
    __weak IBOutlet UIImageView *restaurantBgImageView;
    __weak IBOutlet UILabel *restaurantNameLabel;
    
    __weak IBOutlet UIImageView *restaurantLogoImageView;
    
    NSMutableArray *menuArray;
}
- (IBAction)backBtnAction:(id)sender;
-(IBAction)makeRestaurantFavoriteAction:(id)sender;
@end

@implementation MenuViewController
@synthesize restaurantDict, categoryId;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backBtnAction:) name:@"pop_to_menu" object:nil];
    
    menuArray = [[NSMutableArray alloc] init];
    
    menuTableView.estimatedRowHeight = 60.0;
    menuTableView.rowHeight = UITableViewAutomaticDimension;
    headerView = menuTableView.tableHeaderView;
    menuTableView.tableHeaderView = nil;
    
    [self setupRestaurantDetails];
    
    [menuTableView addSubview:headerView];
    
    [self.view updateConstraintsIfNeeded];
    [self.view layoutIfNeeded];
    
    menuTableView.contentInset = UIEdgeInsetsMake(kTableHeaderHeight, 0, 0, 0);
    menuTableView.contentOffset = CGPointMake(0, -kTableHeaderHeight);
    [self updateHeaderView];

    
    [UIAppDelegate showLoaderWithinteractionEnabledOnView:self.view];
    [self loadRestaurantCategoryMenu];
    // Do any additional setup after loading the view.
}

-(void)setupRestaurantDetails
{
    [restaurantBgImageView sd_setImageWithURL:[NSURL URLWithString:restaurantDict.ImageUrl] placeholderImage:[UIImage imageNamed:@"listing_img"]];
    [restaurantLogoImageView sd_setImageWithURL:[NSURL URLWithString:restaurantDict.logoUrl] placeholderImage:[UIImage imageNamed:@"listing_img"]];
    restaurantNameLabel.text = restaurantDict.name;
    
//    if ([restaurantDict.isFavorite integerValue] == 1)
//    {
//        favoriteBtn.selected = YES;
//    }
//    else
//    {
//        favoriteBtn.selected = NO;
//    }
    
    RatingView *rateView = [[RatingView alloc] initWithFrame:CGRectMake(0, (ratingView.frame.size.height - 20)/2, ratingView.frame.size.width, 20)];
    rateView.tag = 100;
    rateView.rate = [restaurantDict.rateCount floatValue];
    rateView.editable = YES;
    rateView.alignment = RateViewAlignmentLeft;
    rateView.delegate = self;
    [ratingView addSubview:rateView];
    
}

-(void)loadRestaurantCategoryMenu
{
    WebService *serviceObj = [[WebService alloc] init];
    serviceObj.delegate = self;
    serviceObj.API_TYPE = CATEGORY_MENU_API;
    serviceObj.API_INDEX = CATEGORY_MENU_API;
    
    NSMutableDictionary *paraDict = [[NSMutableDictionary alloc] init];
    [paraDict setObject:restaurantDict.Id forKey:@"restaurantId"];
    [paraDict setObject:categoryId forKey:@"categoryId"];
    [serviceObj startOperationWithPostParam:paraDict];
}

-(void)updateHeaderView
{
    CGRect headerRect = CGRectMake(0, -kTableHeaderHeight, menuTableView.bounds.size.width, kTableHeaderHeight);
    if (menuTableView.contentOffset.y < -kTableHeaderHeight)
    {
        headerRect.origin.y = menuTableView.contentOffset.y;
        headerRect.size.height = -menuTableView.contentOffset.y;
    }
    headerView.frame = headerRect;
}

#pragma mark - UIScrollView Delegates

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateHeaderView];
}

#pragma mark - UIButtons Actions

- (IBAction)backBtnAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

//- (void)makeRestaurantFavoriteAction:(id)sender {
//    
//    UIButton *btn = sender;
//    if (!btn.selected)
//    {
//        btn.selected = YES;
//    }
//}

#pragma mark - RatingView Delegate

-(void)rateView:(RatingView *)rateView changedToNewRate:(NSNumber *)rate
{
    NSString *rateValue = [NSString stringWithFormat:@"%@",rate];
    restaurantDict.rateCount = rateValue;
    WebService *serviceObj = [[WebService alloc] init];
    serviceObj.delegate = self;
    serviceObj.API_TYPE = RESTAURANT_RATING_API;
    serviceObj.API_INDEX = RESTAURANT_RATING_API;
    
    NSMutableDictionary *paraDict = [[NSMutableDictionary alloc] init];
    [paraDict setObject:restaurantDict.Id forKey:@"RestaurantId"];
    [paraDict setObject:rateValue forKey:@"RateValue"];
    [serviceObj startOperationWithPostParam:paraDict];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateRestaurantInfo" object:restaurantDict];
}

#pragma mark - WebService Delegates

-(void)serviceFinishedWithResult:(id)result API_Index:(NSInteger)index
{
    if (index == CATEGORY_MENU_API)
    {
        [menuArray removeAllObjects];
        [menuArray addObjectsFromArray:result];
        [menuTableView reloadData];
    }
    else if (index == RESTAURANT_RATING_API)
    {
        
    }
    else if (index == MAKE_RESTAURANT_ITEM_FAVORITE_API)
    {
        
    }
    
    [UIAppDelegate hideLoaderWithinteractionEnabledFromView:self.view];
}

-(void)serviceFinishedWithResponse:(id)response API_Index:(NSInteger)index
{
    [UIAppDelegate hideLoaderWithinteractionDisabled];
    [UIAppDelegate hideLoaderWithinteractionEnabledFromView:self.view];
}

-(void)serviceFinishedWithError:(id)error API_Index:(NSInteger)index
{
    [UIAppDelegate hideLoaderWithinteractionDisabled];
    [UIAppDelegate hideLoaderWithinteractionEnabledFromView:self.view];
}


#pragma mark - UITableView Datasource/Delegates

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return menuArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MenuItemCell"];
    
    if (!IS_iOS8)
    {
        cell.contentView.frame = cell.bounds;
        cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    }
    
    UILabel *itemNameLabel = (UILabel *)[cell.contentView viewWithTag:1];
    UILabel *itemPriceLabel = (UILabel *)[cell.contentView viewWithTag:2];
    UIButton *favoriteBtn = (UIButton *)[cell.contentView viewWithTag:3];
    
    MenuItem *menuItemObj = menuArray[indexPath.row];
    itemNameLabel.text = [NSString stringWithFormat:@"%@",menuItemObj.itemName];
    itemPriceLabel.text = [NSString stringWithFormat:@"$ %@",menuItemObj.price];
    
    if ([menuItemObj.isFavorite integerValue] == 1)
    {
        favoriteBtn.selected = YES;
    }
    else
    {
        favoriteBtn.selected = NO;
    }
    [favoriteBtn addTarget:self action:@selector(makeItemFavoriteAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MenuItem *item = menuArray[indexPath.row];
    item.categoryId = categoryId;
    NSMutableDictionary *menuItemDict = [[NSMutableDictionary alloc] init];
    [menuItemDict setObject:categoryId forKey:@"categoryId"];
    [menuItemDict setObject:item.itemId forKey:@"itemId"];
    [menuItemDict setObject:item.itemName forKey:@"itemName"];
    [menuItemDict setObject:item.price forKey:@"price"];
    [menuItemDict setObject:item.addonArray forKey:@"addonArray"];
    [menuItemDict setObject:item.shortDesc forKey:@"shortDesc"];
    
    UIAppDelegate.isMenuScreen = 1;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AddToBasket" object:menuItemDict];
    
}

#pragma mark - Cell Buttons's Actions

-(void)makeItemFavoriteAction:(id)sender
{
    UserDetails *userDetailObj = [UserDetails sharedManager];
    if (userDetailObj.userId != nil)
    {
        CGPoint buttonPosition = [sender convertPoint:CGPointZero
                                               toView:menuTableView];
        NSIndexPath *indexPath = [menuTableView indexPathForRowAtPoint:buttonPosition];
        MenuItem *menuItemObj = menuArray[indexPath.row];
        NSString *isFavorite;
        if ([menuItemObj.isFavorite integerValue] == 1)
        {
            isFavorite = @"0";
            menuItemObj.isFavorite = @"0";
        }
        else
        {
            isFavorite = @"1";
            menuItemObj.isFavorite = @"1";
        }
        
        [menuTableView reloadData];
        WebService *serviceObj = [[WebService alloc] init];
        serviceObj.delegate = self;
        serviceObj.API_TYPE = MAKE_RESTAURANT_ITEM_FAVORITE_API;
        serviceObj.API_INDEX = MAKE_RESTAURANT_ITEM_FAVORITE_API;
        
        NSMutableDictionary *paraDict = [[NSMutableDictionary alloc] init];
        [paraDict setObject:restaurantDict.Id forKey:@"RestaurantId"];
        [paraDict setObject:menuItemObj.itemId forKey:@"ItemId"];
        [paraDict setObject:isFavorite forKey:@"Isfavorite"];
        [serviceObj startOperationWithPostParam:paraDict];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not Login" message:@"Please login to make menu item favorite !" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Login", nil];
        alert.tag = 111;
        [alert show];
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
            [[NSNotificationCenter defaultCenter] postNotificationName:@"login" object:nil];
        }
    }
}

 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }


@end
