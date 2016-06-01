//
//  FindRestaurantsViewController.m
//  RestoOrder
//
//  Created by Suresh Kumar on 14/07/15.
//
//

#import "FindRestaurantsViewController.h"
#import "RestaurantsListViewController.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "UserDetails.h"
#import "WebService.h"
#import "FilterObject.h"

@interface FindRestaurantsViewController ()<UITextFieldDelegate, UIAlertViewDelegate, WebServiceDelegate, UITableViewDelegate, UITableViewDataSource>
{
    __weak IBOutlet UITextField *locationTextField;
    __weak IBOutlet UIView *chooseLocationView;
    __weak IBOutlet NSLayoutConstraint *locationViewBottomConstraint;
    __weak IBOutlet NSLayoutConstraint *suggestionTableHeightConstraint;
    __weak IBOutlet UITableView *suggestionTableView;
    
    NSMutableArray *suggestionArray;
}
- (IBAction)goBtnAction:(id)sender;
- (IBAction)favoriteRestaurantsBtnAction:(id)sender;
- (IBAction)nearMeBtnAction:(id)sender;
- (IBAction)skipToSettingsBtnAction:(id)sender;

@end

@implementation FindRestaurantsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    suggestionArray = [[NSMutableArray alloc] init];
    
    [self performSelector:@selector(presentLocationView) withObject:nil afterDelay:0.3];
    // Do any additional setup after loading the view.
}

-(void)presentLocationView
{
    locationViewBottomConstraint.constant = 0;
    [self.view updateConstraintsIfNeeded];
    [UIView animateWithDuration:0.6 animations:^{
        
        [self.view layoutIfNeeded];
    }];
}

-(void)fetchSuggestionListAction:(NSString *)suggestionStr
{
    [UIAppDelegate.searchRestaurantDict setObject:@"2" forKey:@"searchType"];
    [UIAppDelegate.searchRestaurantDict setObject:suggestionStr forKey:@"searchText"];
    NSLog(@"search text: %@",suggestionStr);
    WebService *serviceObj = [[WebService alloc] init];
    serviceObj.delegate = self;
    serviceObj.API_TYPE = SUGGESTION_LIST;
    serviceObj.API_INDEX = SUGGESTION_LIST;
    
    [serviceObj startOperationWithPostParam:UIAppDelegate.searchRestaurantDict];
}

-(void)showSuggestionViewList
{
    if (suggestionArray.count > 4)
    {
        suggestionTableHeightConstraint.constant = 140;
    }
    else
    {
        suggestionTableHeightConstraint.constant = 35*suggestionArray.count;
    }
    
    [self.view updateConstraintsIfNeeded];
    
    [UIView animateWithDuration:0.4 animations:^{
        
        [self.view layoutIfNeeded];
    }];
    
}

-(void)hideSuggestionViewList
{
    suggestionTableHeightConstraint.constant = 0;
    [self.view updateConstraintsIfNeeded];
    
    [UIView animateWithDuration:0.4 animations:^{
        
        [self.view layoutIfNeeded];
    }];
}

- (void)resetFilterBtnAction
{
    FilterObject *filterObj = [FilterObject sharedManager];
    [filterObj.cuisineIndexes removeAllObjects];
    [filterObj.cuisineIndexes addObject:@"0"];
    [filterObj.selectedIds removeAllObjects];
    [filterObj.selectedIds addObject:@"0"];
    filterObj.distanceCountStr = @"0";
    filterObj.preDistanceCountStr = @"0";
}

#pragma mark - UIButtons Actions

- (IBAction)goBtnAction:(id)sender {
    
    if (suggestionTableHeightConstraint.constant > 0)
    {
        [self hideSuggestionViewList];
    }
    
    NSString *trimmedString = [locationTextField.text stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceCharacterSet]];
    
    if (trimmedString.length > 0)
    {
        [self resetFilterBtnAction];
        [locationTextField resignFirstResponder];
        [UIAppDelegate.searchRestaurantDict setObject:@"2" forKey:@"searchType"];
        [UIAppDelegate.searchRestaurantDict setObject:trimmedString forKey:@"searchText"];
        [UIAppDelegate.searchRestaurantDict setObject:@"0" forKey:@"page"];
        [UIAppDelegate.searchRestaurantDict setObject:trimmedString forKey:@"title"];
        [self displayTabBarControlAction];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Please enter location name!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
    
}

- (IBAction)favoriteRestaurantsBtnAction:(id)sender {
    UserDetails *userDetailObj = [UserDetails sharedManager];
    if (userDetailObj.userId != nil)
    {
        [UIAppDelegate.searchRestaurantDict setObject:@"1" forKey:@"searchType"];
        [UIAppDelegate.searchRestaurantDict setObject:@"0" forKey:@"page"];
        [UIAppDelegate.searchRestaurantDict setObject:@"Favorite" forKey:@"title"];
        [self displayTabBarControlAction];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not Login" message:@"Please login to see your favorite restaurant list !" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Login", nil];
        alert.tag = 111;
        [alert show];
    }
}

- (IBAction)nearMeBtnAction:(id)sender {
    
    [UIAppDelegate.searchRestaurantDict setObject:@"0" forKey:@"searchType"];
    [UIAppDelegate.searchRestaurantDict setObject:@"0" forKey:@"page"];
    [UIAppDelegate.searchRestaurantDict setObject:@"Near Me" forKey:@"title"];
    [self displayTabBarControlAction];
    
}

- (IBAction)skipToSettingsBtnAction:(id)sender {
    
    UIAppDelegate.skipToSettingCheck = 1;
    [UIAppDelegate.searchRestaurantDict setObject:@"0" forKey:@"searchType"];
    [UIAppDelegate.searchRestaurantDict setObject:@"0" forKey:@"page"];
    [UIAppDelegate.searchRestaurantDict setObject:@"Near Me" forKey:@"title"];
    [self displayTabBarControlAction];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"skip_to_settings" object:nil];
}

-(void)displayTabBarControlAction
{
    if (self.navigationController.topViewController == self)
    {
        [self performSegueWithIdentifier:@"FindRestaurantSegue" sender:nil];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshList" object:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


#pragma mark - WebService Delegates

-(void)serviceFinishedWithResult:(id)result API_Index:(NSInteger)index
{
    if (index == SUGGESTION_LIST)
    {
        if ([result isKindOfClass:[NSArray class]])
        {
            NSArray *resultArray = [NSArray arrayWithArray:(NSArray *)result];
            NSLog(@"resultArray: %@",resultArray);
            [suggestionArray removeAllObjects];
            [suggestionArray addObjectsFromArray:resultArray];
            
            [suggestionTableView reloadData];
            [self showSuggestionViewList];
            
        }
        
    }
}

-(void)serviceFinishedWithResponse:(id)response API_Index:(NSInteger)index
{
    if (index == SUGGESTION_LIST)
    {
        [self hideSuggestionViewList];
    }
}

-(void)serviceFinishedWithError:(id)error API_Index:(NSInteger)index
{
    if (index == SUGGESTION_LIST)
    {
        [self hideSuggestionViewList];
    }
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
    return suggestionArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"suggestionCell"];
    
    UILabel *suggestionNameLabel = (UILabel *)[cell.contentView viewWithTag:1];
    suggestionNameLabel.text = suggestionArray[indexPath.row][@"searchText"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    locationTextField.text = suggestionArray[indexPath.row][@"searchText"];
    [locationTextField resignFirstResponder];
    
    [self hideSuggestionViewList];
}


#pragma mark - UIAlertView Delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 111)
    {
        if (buttonIndex == 0)
        {
            
        }
        else if (buttonIndex == 1)
        {
            if (self.navigationController.topViewController == self)
            {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
            else
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"login" object:nil];
                [self dismissViewControllerAnimated:NO completion:nil];
            }
            
        }
    }
}

#pragma mark - UITextField Delegates

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    locationViewBottomConstraint.constant = -240;
    [self.view updateConstraintsIfNeeded];
    
    [UIView animateWithDuration:0.4 animations:^{
        
        [self.view layoutIfNeeded];
    }];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    locationViewBottomConstraint.constant = 0;
    [self.view updateConstraintsIfNeeded];
    
    [UIView animateWithDuration:0.4 animations:^{
        
        [self.view layoutIfNeeded];
    }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return true;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *suggestionStr = [locationTextField.text stringByReplacingCharactersInRange:range withString:string];
    
    [self fetchSuggestionListAction:suggestionStr];
    
    return true;
}

#pragma mark - UITouch Delegates

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [locationTextField resignFirstResponder];
}


 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}
 
@end
