//
//  AddToBasketViewController.m
//  RestoOrder
//
//  Created by Suresh Kumar on 14/07/15.
//
//

#import "AddToBasketViewController.h"
#import "Constants.h"
#import "Database.h"


#define DESC_HEIGHT_CONSTRAINT  @"DescHeightConstraint"

@interface AddToBasketViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    
    __weak IBOutlet UILabel *itemPriceLabel;
    __weak IBOutlet UILabel *itemNameLabel;
    __weak IBOutlet UITableView *addonTableView;
    __weak IBOutlet UILabel *quantityLabel;
    __weak IBOutlet UILabel *longDescLabel;
    __weak IBOutlet UIButton *hideShowBtn;
    __weak IBOutlet NSLayoutConstraint *addonTableHeightConstraint;
    NSMutableArray *addonArray;
    NSMutableArray *selectedAddonIds;
    
    NSDictionary *restaurantDict;
}
- (IBAction)addToBasketBtnAction:(id)sender;
- (IBAction)minusBtnAction:(id)sender;
- (IBAction)plusBtnAction:(id)sender;
-(IBAction)dismissViewAction:(id)sender;
-(IBAction)hideShowDescViewAction:(id)sender;

@end

@implementation AddToBasketViewController
@synthesize menuItem;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    itemNameLabel.text = menuItem[@"itemName"];
    longDescLabel.text = menuItem[@"shortDesc"];
    
    itemPriceLabel.text = [NSString stringWithFormat:@"$ %@",menuItem[@"price"]];
    addonArray = [[NSMutableArray alloc] initWithArray:menuItem[@"addonArray"]];
    selectedAddonIds = [[NSMutableArray alloc] init];
    NSInteger itemQuantity = 1;
    
    NSDictionary *itemDict = [[Database sharedObject] readProductWithId:menuItem[@"itemId"]];
    if (itemDict.allKeys > 0)
    {
        NSString *addonIds = itemDict[@"addonIds"];
        if (addonIds.length > 0)
        {
            [selectedAddonIds addObjectsFromArray:[addonIds componentsSeparatedByString:@","]];
        }
        itemQuantity = [itemDict[@"quantity"] integerValue];
    }
    
    quantityLabel.text = [NSString stringWithFormat:@"Quantity %ld",(long)itemQuantity];
    
    [self updateItemDetailsWithItemPrice:menuItem[@"price"] Quantity:itemQuantity AddonArray:selectedAddonIds];
    
    [self updateTableHeightConstraint];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    NSDictionary *savedRestDict = [[Database sharedObject] readRestaurant];
    if (savedRestDict.allKeys.count > 0)
    {
        NSString *jsonDictStr = savedRestDict[@"detailDict"];
        
        NSData *data = [jsonDictStr dataUsingEncoding:NSUTF8StringEncoding];
        restaurantDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSLog(@"restaurant Dict:%@",restaurantDict);
    
    }
}

-(void)updateItemDetailsWithItemPrice:(NSString *)itemPrice Quantity:(NSInteger)itemQuantity AddonArray:(NSArray *)AddonIds
{
    float addonPrice = 0.0;
    for (NSDictionary *addonDict in addonArray)
    {
        if ([AddonIds containsObject:addonDict[@"AddonId"]])
        {
            addonPrice = addonPrice + [addonDict[@"AddonPrice"] floatValue];
        }
    }
    
    float price = ([itemPrice floatValue] + addonPrice) * itemQuantity;
    
    itemPriceLabel.text = [NSString stringWithFormat:@"$ %0.2f",price];
}

-(void)updateTableHeightConstraint
{
    if (addonArray.count >= 4)
    {
        addonTableHeightConstraint.constant = 40 * 4;
    }
    else
    {
        addonTableHeightConstraint.constant = 40 * addonArray.count;
    }
    
    [self.view updateConstraintsIfNeeded];
    [self.view layoutIfNeeded];
    
    [addonTableView reloadData];
}

#pragma mark - UIButtons Actions

-(void)hideShowDescViewAction:(id)sender
{
    if (hideShowBtn.selected == true)
    {
        hideShowBtn.selected = false;
        [hideShowBtn setTitle:@"Hide" forState:UIControlStateNormal];
        
        for (NSLayoutConstraint *constraint in longDescLabel.constraints)
        {
            if ([constraint.identifier isEqualToString:DESC_HEIGHT_CONSTRAINT])
            {
                [longDescLabel removeConstraint:constraint];
                break;
            }
        }
    }
    else
    {
        hideShowBtn.selected = true;
        [hideShowBtn setTitle:@"Show" forState:UIControlStateNormal];
        
        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:longDescLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
        heightConstraint.identifier = DESC_HEIGHT_CONSTRAINT;
        [longDescLabel addConstraint:heightConstraint];
    }
    
    [self.view updateConstraintsIfNeeded];
    
    
    [UIView animateWithDuration:0.45 animations:^{
        
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction)addToBasketBtnAction:(id)sender
{
    NSDictionary *itemDict = [[Database sharedObject] readProductWithId:menuItem[@"itemId"]];
    
    int itemId = [menuItem[@"itemId"] intValue];
    int quantity = [[NSString stringWithFormat:@"%@",[[quantityLabel.text componentsSeparatedByString:@" "] lastObject]] intValue];
    float price = [menuItem[@"price"] floatValue];
    NSString *addonIds = [selectedAddonIds componentsJoinedByString:@","];
    
    double totalPrice = [[NSString stringWithFormat:@"%@",[[itemPriceLabel.text componentsSeparatedByString:@" "] lastObject]] doubleValue];
    int maxQty = [restaurantDict[@"maxQty"] intValue];
    NSLog(@"maxQty:%d \n quantity :%d",maxQty,quantity);
    if (maxQty >= quantity)
    {
        if (itemDict.allKeys.count > 0)     // update
        {
            [[Database sharedObject] updateProductWithId:itemId quantity:quantity price:price TotalPrice:totalPrice addon_Ids:addonIds];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateOrder" object:nil];
        }
        else        // add new item
        {
            NSMutableData *requestBody = [[NSMutableData alloc] initWithData: [NSJSONSerialization dataWithJSONObject:menuItem options:NSJSONWritingPrettyPrinted error:nil]];
            
            NSString *itemDictJson = [[NSString alloc] initWithData:requestBody encoding:NSUTF8StringEncoding];
            
            [[Database sharedObject] addNewProductWithName:menuItem[@"itemName"] server_Id:menuItem[@"itemId"] quantity:quantity price:price TotalPrice:totalPrice addon_Ids:addonIds CategoryId:menuItem[@"categoryId"] ItemDict:itemDictJson];
            
        }
        if (UIAppDelegate.isMenuScreen == 1)
        {
            UIAppDelegate.isMenuScreen = 0;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"continue_order" object:nil];
        }
        [self dismissViewAction:nil];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"You are not allowed to order more than %d quantity of an item",maxQty] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
}

-(void)dismissViewAction:(id)sender
{
    self.view.alpha = 1.0;
    [UIView animateWithDuration:0.6 animations:^{
        self.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
}

- (IBAction)minusBtnAction:(id)sender {
    
    NSInteger quantity = [[NSString stringWithFormat:@"%@",[[quantityLabel.text componentsSeparatedByString:@" "] lastObject]] integerValue];
    if (quantity > 1)
    {
        quantity--;
    }
    quantityLabel.text = [NSString stringWithFormat:@"Quantity %ld",(long)quantity];
    
    [self updateItemDetailsWithItemPrice:menuItem[@"price"] Quantity:quantity AddonArray:selectedAddonIds];
}

- (IBAction)plusBtnAction:(id)sender {
    
    NSInteger quantity = [[NSString stringWithFormat:@"%@",[[quantityLabel.text componentsSeparatedByString:@" "] lastObject]] integerValue];
    if (quantity >= 0)
    {
        quantity++;
    }
    quantityLabel.text = [NSString stringWithFormat:@"Quantity %ld",(long)quantity];
    [self updateItemDetailsWithItemPrice:menuItem[@"price"] Quantity:quantity AddonArray:selectedAddonIds];
}


-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return addonArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddonCell"];
    
    if (!IS_iOS8)
    {
        cell.contentView.frame = cell.bounds;
        cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    }
    UIButton *checkBtn = (UIButton *)[cell.contentView viewWithTag:1];
    UILabel *addonNameLabel = (UILabel *)[cell.contentView viewWithTag:2];
    UILabel *addonPriceLabel = (UILabel *)[cell.contentView viewWithTag:3];
    addonNameLabel.text = addonArray[indexPath.row][@"AddonName"];
    addonPriceLabel.text = [NSString stringWithFormat:@"$ %@",addonArray[indexPath.row][@"AddonPrice"]];
    [checkBtn addTarget:self action:@selector(selectAddonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([selectedAddonIds containsObject:addonArray[indexPath.row][@"AddonId"]])
    {
        checkBtn.selected = YES;
    }
    else
    {
        checkBtn.selected = NO;
    }
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self selectAddonAtIndexPath:indexPath];
}

#pragma mark - Cell Button Actions

-(void)selectAddonAction:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero
                                           toView:addonTableView];
    NSIndexPath *indexPath = [addonTableView indexPathForRowAtPoint:buttonPosition];
    [self selectAddonAtIndexPath:indexPath];
}

-(void)selectAddonAtIndexPath:(NSIndexPath *)indexPath
{
    if ([selectedAddonIds containsObject:addonArray[indexPath.row][@"AddonId"]])
    {
        [selectedAddonIds removeObject:addonArray[indexPath.row][@"AddonId"]];
    }
    else
    {
        [selectedAddonIds addObject:addonArray[indexPath.row][@"AddonId"]];
    }
    
    [addonTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    NSInteger quantity = [[NSString stringWithFormat:@"%@",[[quantityLabel.text componentsSeparatedByString:@" "] lastObject]] integerValue];
    [self updateItemDetailsWithItemPrice:menuItem[@"price"] Quantity:quantity AddonArray:selectedAddonIds];
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
