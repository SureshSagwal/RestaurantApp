//
//  RootNavigationController.m
//  RestoOrder
//
//  Created by Suresh Kumar on 14/07/15.
//
//

#import "RootNavigationController.h"
#import "UserDetails.h"
#import "FilterObject.h"

@interface RootNavigationController ()

@end

@implementation RootNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    FilterObject *filterObj = [FilterObject sharedManager];
    [filterObj unarchiveFilterObject];
    
    if (filterObj.cuisineIndexes.count == 0 || filterObj.cuisineIndexes == nil)
    {
        filterObj.cuisineIndexes = [[NSMutableArray alloc] init];
        filterObj.cuisinesArray = [[NSMutableArray alloc] init];
        filterObj.selectedIds = [[NSMutableArray alloc] init];
        
        [filterObj.selectedIds addObject:@"0"];
        [filterObj.cuisineIndexes addObject:@"0"];
        filterObj.distanceCountStr = @"0";
    }
    
    UserDetails *userDetailObj = [UserDetails sharedManager];
    [userDetailObj unarchiveUserDetail];
    if(userDetailObj.userId != nil)
    {
        self.viewControllers = [NSArray arrayWithObject:[self.storyboard instantiateViewControllerWithIdentifier:@"FindRestaurantControl"]];
    }
    else
    {
        self.viewControllers = [NSArray arrayWithObject:[self.storyboard instantiateViewControllerWithIdentifier:@"LoginControl"]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
