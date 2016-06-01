//
//  FavoriteLocationViewController.m
//  RestoOrder
//
//  Created by Suresh Kumar on 14/07/15.
//
//

#import "FavoriteLocationViewController.h"
#import "Constants.h"
#import "WebService.h"
#import "Location.h"
#import "AppDelegate.h"


@interface FavoriteLocationViewController ()<WebServiceDelegate>
{
    NSMutableArray *locationsArray;
    __weak IBOutlet UITableView *locationTableView;
}
- (IBAction)backBtnAction:(id)sender;
@end

@implementation FavoriteLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    locationsArray = [[NSMutableArray alloc] init];
    [UIAppDelegate showLoaderWithinteractionDisabled];
    [self loadFavoriteLocations];
    // Do any additional setup after loading the view.
}

-(void)loadFavoriteLocations
{
    WebService *serviceObj = [[WebService alloc] init];
    serviceObj.delegate = self;
    serviceObj.API_TYPE = FAVORITE_LOCATION_API;
    serviceObj.API_INDEX = FAVORITE_LOCATION_API;
    [serviceObj startOperationWithPostParam:nil];
}

#pragma mark - UIButton Action

- (IBAction)backBtnAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - WebService Delegates

-(void)serviceFinishedWithResult:(id)result API_Index:(NSInteger)index
{
    [locationsArray removeAllObjects];
    [locationsArray addObjectsFromArray:result];
    [locationTableView reloadData];
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
    return locationsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FavoriteLocationCell"];
    if (!IS_iOS8)
    {
        cell.contentView.frame = cell.bounds;
        cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    }
    UILabel *locationNameLabel = (UILabel *)[cell.contentView viewWithTag:2];
    UILabel *dateLabel = (UILabel *)[cell.contentView viewWithTag:3];
    Location *locObj = locationsArray[indexPath.row];
    locationNameLabel.text = [NSString stringWithFormat:@"%@ - %@",locObj.locationType,locObj.locationName];
    dateLabel.text = locObj.favoriteCreationDate;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Location *locObj = locationsArray[indexPath.row];
    [UIAppDelegate.searchRestaurantDict setObject:@"2" forKey:@"searchType"];
    [UIAppDelegate.searchRestaurantDict setObject:locObj.locationName forKey:@"searchText"];
    [UIAppDelegate.searchRestaurantDict setObject:@"0" forKey:@"page"];
    [UIAppDelegate.searchRestaurantDict setObject:locObj.locationName forKey:@"title"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UseFavoriteLocation" object:locObj];
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
