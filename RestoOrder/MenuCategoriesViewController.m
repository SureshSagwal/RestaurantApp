//
//  MenuCategoriesViewController.m
//  RestoOrder
//
//  Created by Suresh Kumar on 14/07/15.
//
//

#import "MenuCategoriesViewController.h"
#import "RatingView.h"
#import "Constants.h"
#import "WebService.h"
#import "MenuViewController.h"
#import "UIImageView+WebCache.h"
#import "UserDetails.h"

#define kTableHeaderHeight  156.0

@interface MenuCategoriesViewController ()<UITableViewDelegate, UITableViewDataSource, WebServiceDelegate, RatingViewDelegate, UIScrollViewDelegate>
{    
    __weak IBOutlet UITableView *categoryTableView;
    
    __weak IBOutlet UIView *ratingView;
    UIView *headerView;
    RatingView *rateView;
    NSMutableArray *categoryArray;
    NSInteger currentSelectedIndex;
    
    __weak IBOutlet UIImageView *restaurantBgImageView;
    __weak IBOutlet UIImageView *restaurantLogoImageView;
    __weak IBOutlet UILabel *restaurantNameLabel;
    __weak IBOutlet UIButton *favoriteBtn;
}

- (IBAction)backBtnAction:(id)sender;
-(IBAction)makeRestaurantFavoriteAction:(id)sender;
@end

@implementation MenuCategoriesViewController
@synthesize restaurantDict;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRestaurantDict:) name:@"updateRestaurantInfo" object:nil];      // update current selcted restaurant info like rating from menu screen.
    categoryArray = [[NSMutableArray alloc] init];
    
    headerView = categoryTableView.tableHeaderView;
    categoryTableView.tableHeaderView = nil;
    
    [self setupRestaurantDetails];
    
    [categoryTableView addSubview:headerView];
    
    [self.view updateConstraintsIfNeeded];
    [self.view layoutIfNeeded];

    categoryTableView.contentInset = UIEdgeInsetsMake(kTableHeaderHeight, 0, 0, 0);
    categoryTableView.contentOffset = CGPointMake(0, -kTableHeaderHeight);
    [self updateHeaderView];
    
    if (IS_iOS8)
    {
        categoryTableView.estimatedRowHeight = 55.0;
        categoryTableView.rowHeight = UITableViewAutomaticDimension;
    }
    
    [UIAppDelegate showLoaderWithinteractionEnabledOnView:self.view];
    [self loadRestaurantCategories];
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
//    [self setupRestaurantDetails];
}

-(void)setupRestaurantDetails
{
    [restaurantBgImageView sd_setImageWithURL:[NSURL URLWithString:restaurantDict.ImageUrl] placeholderImage:[UIImage imageNamed:@"listing_img"]];
    [restaurantLogoImageView sd_setImageWithURL:[NSURL URLWithString:restaurantDict.logoUrl] placeholderImage:[UIImage imageNamed:@"listing_img"]];
    restaurantNameLabel.text = restaurantDict.name;
    
    if ([restaurantDict.isFavorite integerValue] == 1)
    {
        favoriteBtn.selected = YES;
    }
    else
    {
        favoriteBtn.selected = NO;
    }
    
    rateView = [[RatingView alloc] initWithFrame:CGRectMake(0, (ratingView.frame.size.height - 20)/2, ratingView.frame.size.width, 20)];
    rateView.tag = 100;
    rateView.rate = [restaurantDict.rateCount floatValue];
    rateView.editable = YES;
    rateView.alignment = RateViewAlignmentLeft;
    rateView.delegate = self;
    [ratingView addSubview:rateView];
    
}

-(void)loadRestaurantCategories
{
    WebService *serviceObj = [[WebService alloc] init];
    serviceObj.delegate = self;
    serviceObj.API_TYPE = RESTAURANT_CATEGORIES_API;
    serviceObj.API_INDEX = RESTAURANT_CATEGORIES_API;
    NSMutableDictionary *paraDict = [[NSMutableDictionary alloc] init];
    [paraDict setObject:restaurantDict.Id forKey:@"restaurantId"];
    [serviceObj startOperationWithPostParam:paraDict];
}

-(void)updateHeaderView
{
    CGRect headerRect = CGRectMake(0, -kTableHeaderHeight, categoryTableView.bounds.size.width, kTableHeaderHeight);
    if (categoryTableView.contentOffset.y < -kTableHeaderHeight)
    {
        headerRect.origin.y = categoryTableView.contentOffset.y;
        headerRect.size.height = -categoryTableView.contentOffset.y;
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

- (void)makeRestaurantFavoriteAction:(id)sender {
    
    UserDetails *userDetailObj = [UserDetails sharedManager];
    if (userDetailObj.userId != nil)
    {
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
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateRestaurantInfo" object:restaurantDict];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not Login" message:@"Please login to make restaurant favorite !" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Login", nil];
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

#pragma mark - RatingView Delegate

-(void)rateView:(RatingView *)rateView changedToNewRate:(NSNumber *)rate
{
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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateRestaurantInfo" object:restaurantDict];
}

#pragma mark - NSNotification Action

-(void)updateRestaurantDict:(NSNotification *)notif
{
    restaurantDict = notif.object;
    rateView.delegate = nil;
    rateView.rate = [restaurantDict.rateCount floatValue];
    rateView.delegate = self;
}

#pragma mark - WebService Delegates

-(void)serviceFinishedWithResult:(id)result API_Index:(NSInteger)index
{
    NSLog(@"results :%@",result);
    
    if (index == MAKE_RESTAURANT_FAVORITE_API)
    {
    }
    else if (index == RESTAURANT_CATEGORIES_API)
    {
        [categoryArray removeAllObjects];
        [categoryArray addObjectsFromArray:result];
        [categoryTableView reloadData];
    }
    else if (index == RESTAURANT_RATING_API)
    {
        
    }
    
    [UIAppDelegate hideLoaderWithinteractionEnabledFromView:self.view];
}

-(void)serviceFinishedWithResponse:(id)response API_Index:(NSInteger)index
{
    [UIAppDelegate displayAlertWithMessage:response];
    [UIAppDelegate hideLoaderWithinteractionEnabledFromView:self.view];
}

-(void)serviceFinishedWithError:(id)error API_Index:(NSInteger)index
{
    [UIAppDelegate displayAlertWithMessage:error];
    [UIAppDelegate hideLoaderWithinteractionEnabledFromView:self.view];
}


#pragma mark - UITableView Datasource/Delegates

- (BOOL)respondsToSelector:(SEL)selector
{
    if (selector == @selector(tableView:heightForRowAtIndexPath:))
    {
        if (IS_iOS8)
            return 0;
        else
            return 1;
    }
    
    return [super respondsToSelector:selector];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return categoryArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menuCategoryCell"];
    
//    if (cell != nil)
//    {
//        return cell;
//    }
//    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"menuCategoryCell"];
    
    UILabel *categoryNameLabel = (UILabel *)[cell.contentView viewWithTag:1];
    categoryNameLabel.text = [NSString stringWithFormat:@"%@: %@",categoryArray[indexPath.row][@"categoryName"],categoryArray[indexPath.row][@"categoryType"]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    currentSelectedIndex = indexPath.row;
    [self performSegueWithIdentifier:@"MenuCategorySegue" sender:nil];
}


 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MenuViewController *menuObj = (MenuViewController *)[segue destinationViewController];
    menuObj.categoryId = categoryArray[currentSelectedIndex][@"categoryId"];
    menuObj.restaurantDict = restaurantDict;
}


@end
