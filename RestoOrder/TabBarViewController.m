//
//  TabBarViewController.m
//  RestoOrder
//
//  Created by Suresh Kumar on 14/07/15.
//
//

#import "TabBarViewController.h"
#import "AddToBasketViewController.h"
#import "Constants.h"

@interface TabBarViewController ()
{
    UITabBarController *tabBarController;
    
    __weak IBOutlet UIButton *restaurantBtn;
    __weak IBOutlet UIButton *basketBtn;
    __weak IBOutlet UIButton *settingBtn;
    AddToBasketViewController *addToBasketObj;
}

-(IBAction)selectTabBarButtonAction:(id)sender;

@end

@implementation TabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    tabBarController =  (UITabBarController *)[self.childViewControllers firstObject];
//    tabBarController.tabBar.hidden = YES;
    UIButton *selectedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    if (UIAppDelegate.skipToSettingCheck == 1)
    {
        UIAppDelegate.skipToSettingCheck = 0;
        selectedBtn.tag = 2;
    }
    else
    {
        selectedBtn.tag = 0;
    }
    
    [self selectTabBarButtonAction:selectedBtn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addToBasketAction:) name:@"AddToBasket" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PresentFindRestaurantScreen:) name:@"PresentFindRestaurantScreen" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectHomeTab:) name:@"SelectHomeTab" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(continueOrderAction:) name:@"continue_order" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(skipToSettingAction:) name:@"skip_to_settings" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginAction:) name:@"login" object:nil];
    // Do any additional setup after loading the view.
}

-(void)selectTabBarButtonAction:(id)sender
{
    restaurantBtn.selected = NO;
    basketBtn.selected = NO;
    settingBtn.selected = NO;
    
    switch ([sender tag])
    {
        case 0:
        {
            restaurantBtn.selected = YES;
        }
            break;
        case 1:
        {
            basketBtn.selected = YES;
        }
            break;
        case 2:
        {
            settingBtn.selected = YES;
        }
            break;
            
        default:
            break;
    }
    
    tabBarController.selectedIndex = [sender tag];
}


#pragma mark - NSNotification Handlers

-(void)loginAction:(NSNotification *)notif
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)selectHomeTab:(NSNotification *)notif
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = 0;
    [self selectTabBarButtonAction:btn];
}

-(void)addToBasketAction:(NSNotification *)notif
{
    addToBasketObj = [self.storyboard instantiateViewControllerWithIdentifier:@"AddToBasketControl"];
    addToBasketObj.menuItem = notif.object;

    addToBasketObj.view.alpha = 0.0;
    [self.view addSubview:addToBasketObj.view];
    [UIView animateWithDuration:0.6 animations:^{
        addToBasketObj.view.alpha = 1.0;
    }];
}

-(void)PresentFindRestaurantScreen:(NSNotification *)notif
{
    id findController = [self.storyboard instantiateViewControllerWithIdentifier:@"FindRestaurantControl"];
    
    [self.navigationController presentViewController:findController animated:YES completion:nil];
}

-(void)continueOrderAction:(NSNotification *)notif
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Item successfully added into basket, please keep ordering or visit basket to see your order !" delegate:self cancelButtonTitle:@"Order more" otherButtonTitles:@"Basket", nil];
    alert.tag = 999;
    [alert show];
}

-(void)skipToSettingAction:(NSNotification *)notif
{
    UIButton *btn = [UIButton buttonWithType: UIButtonTypeCustom];
    btn.tag = 2;
    [self selectTabBarButtonAction:btn];
}

#pragma mark - UIAlertView Delegates

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 999)
    {
        if (buttonIndex == 0)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"pop_to_menu" object:nil];
        }
        else if (buttonIndex == 1)
        {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.tag = 1;
            [self selectTabBarButtonAction:btn];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
