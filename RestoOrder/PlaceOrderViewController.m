//
//  PlaceOrderViewController.m
//  RestoOrder
//
//  Created by Suresh Kumar on 14/07/15.
//
//

#import "PlaceOrderViewController.h"
#import "WebService.h"
#import "Constants.h"
#import "Database.h"
#import "UserDetails.h"
#import "AddressViewController.h"

#define kScreenHeight   self.view.frame.size.height

@interface PlaceOrderViewController ()<UIAlertViewDelegate, UITextFieldDelegate, WebServiceDelegate, UITableViewDataSource, UITableViewDelegate>
{
    __weak IBOutlet UILabel *totalPriceLabel;
    
    __weak IBOutlet UIButton *placeOrderBtn;
    __weak IBOutlet UILabel *cardTypeLabel;
    __weak IBOutlet UILabel *restaurantNameLabel;
    __weak IBOutlet UITextField *firstNameTextField;
    __weak IBOutlet UITextField *lastNameTextField;
    __weak IBOutlet UITextField *emailTextField;
    __weak IBOutlet UITextField *mobileTextField;
    __weak IBOutlet UITableView *addressTableView;
    
    __weak IBOutlet UIButton *addAddressBtn;
    __weak IBOutlet NSLayoutConstraint *addressTableHeightConstraint;
    
    __weak IBOutlet UIImageView *bgImageView;
    __weak IBOutlet NSLayoutConstraint *passwordViewBottomConstraint;
    __weak IBOutlet UITextField *passwordTxtFld;
    
    NSMutableArray *addressArray;
    NSInteger selectedAddressIndex;
    NSInteger addressMode;          // 1 if editing the address , 0 if adding new address
    NSInteger editIndex;
    NSInteger canPlaceOrder;
    
    NSDictionary *restaurantDict;
    NSDictionary *selectedAddressDict;
}
- (IBAction)backBtnAction:(id)sender;
- (IBAction)addNewAddressBtnAction:(id)sender;
- (IBAction)placeOrderBtnAction:(id)sender;
- (IBAction)authenticateBtnAction:(id)sender;
-(IBAction)tapGestureAction:(id)sender;

@end

@implementation PlaceOrderViewController
@synthesize orderDict;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    canPlaceOrder = 1;
    restaurantDict = [[NSDictionary alloc] init];
    selectedAddressDict = [[NSDictionary alloc] init];
    selectedAddressIndex = -1;
    addressMode = 0;
    addressArray = [[NSMutableArray alloc] init];
    
    addressTableView.estimatedRowHeight = 45.0;
    addressTableView.rowHeight = UITableViewAutomaticDimension;
    
    NSInteger checkoutType = [orderDict[@"CheckoutType"] integerValue];
//    NSLog(@"order Dict :%@ \n checkoutType :%ld",orderDict, checkoutType);
    if (checkoutType != 2)
    {
        addressTableHeightConstraint.constant = 0.0;
    }
        // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [self fillPersonalDetails];
    [self updateOrderDetails];
    
    [addressArray removeAllObjects];
    [addressArray addObjectsFromArray:[[Database sharedObject] readAllAddresses]];
    
    NSInteger checkoutType = [orderDict[@"CheckoutType"] integerValue];
    
    if (checkoutType == 2)
    {
        if (addressArray.count == 0)
        {
            addressTableHeightConstraint.constant = 50.0;
        }
        else if (addressArray.count >= 3)
        {
            addAddressBtn.hidden = YES;
            addressTableHeightConstraint.constant = 50.0 + 45*3;
        }
        else
        {
            addressTableHeightConstraint.constant = 50.0 + 45*addressArray.count;
        }
    }
    
    [addressTableView reloadData];
    
    [self.view updateConstraintsIfNeeded];
    [self.view layoutIfNeeded];
}

-(void)viewWillAppear:(BOOL)animated
{
    
    
}


#pragma mark - Local Actions

-(void)fillPersonalDetails
{
    UserDetails *userObject = [UserDetails sharedManager];
    NSString *nameStr = userObject.name;
    NSMutableArray *components = [[NSMutableArray alloc] initWithArray:[nameStr componentsSeparatedByString:@" "]];
    if (components.count > 1)
    {
        lastNameTextField.text = [components lastObject];
        [components removeLastObject];
        firstNameTextField.text = [components componentsJoinedByString:@" "];
    }
    else
    {
        firstNameTextField.text = nameStr;
    }
    
    emailTextField.text = userObject.email;
    NSLog(@"mobile :%@",userObject.mobile);
    if (![userObject.mobile isEqualToString:@"(null)"] && userObject.mobile != nil)
    {
        mobileTextField.text = userObject.mobile;
    }
    
    
}

-(void)updateOrderDetails
{
    NSArray *orderItemsArray = [[Database sharedObject] readAllProducts];
    
    if (orderItemsArray.count > 0)
    {
        NSDictionary *savedRestDict = [[Database sharedObject] readRestaurant];
        if (savedRestDict.allKeys.count > 0)
        {
            NSString *jsonDictStr = savedRestDict[@"detailDict"];
            
            NSData *data = [jsonDictStr dataUsingEncoding:NSUTF8StringEncoding];
            restaurantDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSLog(@"restaurant Dict:%@",restaurantDict);
            
            restaurantNameLabel.text = restaurantDict[@"name"];
            
            totalPriceLabel.text = [NSString stringWithFormat:@"$ %@",orderDict[@"TotalPrice"]];
            cardTypeLabel.text = [NSString stringWithFormat:@"We accept : %@",restaurantDict[@"cardTypes"]];
        }
        
        canPlaceOrder = 1;
        double subTotal = 0.0;
        
        for (NSDictionary *dict in orderItemsArray)
        {
            subTotal = subTotal + [dict[@"totalPrice"] doubleValue];
        }
        
        double vat = [restaurantDict[@"vat"] doubleValue];
        vat = (vat/100) * subTotal;
        
        double tax = [restaurantDict[@"serviceTax"] doubleValue];
        tax = (tax/100) * subTotal;
        
        double total = subTotal + vat + tax;
        
        // update order dict
        
        [orderDict setObject:restaurantDict[@"Id"] forKey:@"RestaurantId"];
        [orderDict setObject:[NSString stringWithFormat:@"%0.2f",total] forKey:@"TotalPrice"];
        [orderDict setObject:[NSString stringWithFormat:@"%0.2f",subTotal] forKey:@"SubTotal"];
        [orderDict setObject:[NSString stringWithFormat:@"%0.2f",vat] forKey:@"VatPrice"];
        [orderDict setObject:[NSString stringWithFormat:@"%0.2f",tax] forKey:@"TaxPrice"];
        
        [self generateJsonStringFromItemsArray:orderItemsArray];
        
    }
    else
    {
        restaurantNameLabel.text = @"";
        totalPriceLabel.text = @"";
        cardTypeLabel.text = @"";
        canPlaceOrder = 0;
        [[[UIAlertView alloc] initWithTitle:@"Basket Empty !" message:@"Please add some items into basket before placing order !" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
}

-(NSString *)generateJsonStringFromItemsArray:(NSArray *)itemsArr
{
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (NSDictionary *itemDict in itemsArr)
    {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:itemDict[@"serverId"] forKey:@"ItemId"];
        [dict setObject:itemDict[@"categoryId"] forKey:@"CategoryId"];
        [dict setObject:itemDict[@"productName"] forKey:@"ItemName"];
        [dict setObject:itemDict[@"price"] forKey:@"ItemPrice"];
        [dict setObject:itemDict[@"quantity"] forKey:@"ItemQuantity"];
        
        NSArray *addonIds = [itemDict[@"addonIds"] componentsSeparatedByString:@","];
        NSMutableArray *addons = [[NSMutableArray alloc] init];
        for (NSString *addonId in addonIds)
        {
            NSDictionary *addonDict = [[NSDictionary alloc] initWithObjectsAndKeys:addonId, @"AddonId", nil];
            [addons addObject:addonDict];
        }
        [dict setObject:addons forKey:@"Addon"];
        
        [items addObject:dict];
    }
    
    NSMutableData *requestBody = [[NSMutableData alloc] initWithData: [NSJSONSerialization dataWithJSONObject:items options:NSJSONWritingPrettyPrinted error:nil]];
    
    NSString *itemsJson = [[NSString alloc] initWithData:requestBody encoding:NSUTF8StringEncoding];
    [orderDict setObject:itemsJson forKey:@"Items"];
    
    return itemsJson;
}

-(void)showHideAuthenticationView
{
    if (passwordViewBottomConstraint.constant == - 200.0)
    {
        bgImageView.alpha = 0.0;
        bgImageView.hidden = NO;
        [UIView animateWithDuration:0.25 animations:^{
            bgImageView.alpha = 0.65;
        } completion:^(BOOL finished) {
            
        }];
        passwordViewBottomConstraint.constant = kScreenHeight/2 - 100;
    }
    else
    {
        passwordViewBottomConstraint.constant = - 200.0;
        [UIView animateWithDuration:0.25 animations:^{
            bgImageView.alpha = 0.0;
        } completion:^(BOOL finished) {
            bgImageView.hidden = YES;
        }];
    }
    [self.view updateConstraintsIfNeeded];
    [UIView animateWithDuration:0.45 animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}


#pragma mark - UIButton Actions

- (IBAction)backBtnAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addNewAddressBtnAction:(id)sender {
    
    [self performSegueWithIdentifier:@"AddressSegue" sender:nil];
}

- (IBAction)placeOrderBtnAction:(id)sender {
    
    if (canPlaceOrder == 1)
    {
        BOOL proceed = TRUE;
        NSInteger checkoutType = [orderDict[@"CheckoutType"] integerValue];
        if (checkoutType == 2)
        {
            if (selectedAddressDict.allKeys.count == 0)
            {
                proceed = FALSE;
                [[[UIAlertView alloc] initWithTitle:@"Delivery Adress" message:@"Please select delivery address!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            }
            else
            {
                NSString *addressStr;
                NSString *address1 = selectedAddressDict[@"address1"];
                NSString *address2 = selectedAddressDict[@"address2"];
                NSString *pin = selectedAddressDict[@"pin"];
                
                if (address1.length > 0)
                {
                    addressStr = address1;
                }
                if (address2.length > 0)
                {
                    addressStr = [NSString stringWithFormat:@"%@, %@",addressStr,address2];
                }
                if (pin.length > 0)
                {
                    addressStr = [NSString stringWithFormat:@"%@, %@",addressStr,pin];
                }

                [orderDict setObject:addressStr forKey:@"deliveryAddress"];
                proceed = TRUE;
            }
        }
        else
        {
            [orderDict setObject:@"" forKey:@"deliveryAddress"];
        }

        if (proceed == TRUE)
        {
            NSInteger userType = [[[UserDetails sharedManager] userType] integerValue];
            if (userType != 1)
            {
                [self showHideAuthenticationView];
            }
            else
            {
                [self placeOrderAPI];
            }
            
        }
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"Basket Empty !" message:@"Please add some items into basket before placing order !" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
    
}



- (IBAction)authenticateBtnAction:(id)sender {
    
    passwordTxtFld.text = [passwordTxtFld.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (passwordTxtFld.text.length == 0)
    {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Please enter password !" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
    }
    
    [UIAppDelegate showLoaderWithinteractionDisabled];
    WebService *serviceObj = [[WebService alloc] init];
    serviceObj.delegate = self;
    serviceObj.API_TYPE = AUTHENTICATE_API;
    serviceObj.API_INDEX = AUTHENTICATE_API;
    
    NSMutableDictionary *paraDict = [[NSMutableDictionary alloc] init];
    [paraDict setObject:passwordTxtFld.text forKey:@"password"];
    
    [serviceObj startOperationWithPostParam:paraDict];
    
}

-(void)tapGestureAction:(id)sender
{
    [self showHideAuthenticationView];
}

-(void)placeOrderAPI
{
    [UIAppDelegate showLoaderWithinteractionDisabled];
    WebService *serviceObj = [[WebService alloc] init];
    serviceObj.delegate = self;
    serviceObj.API_TYPE = CREATE_ORDER_API;
    serviceObj.API_INDEX = CREATE_ORDER_API;
    
//    NSMutableDictionary *paraDict = [[NSMutableDictionary alloc] init];
    [serviceObj startOperationWithPostParam:orderDict];

}

#pragma mark - WebService Delegates

-(void)serviceFinishedWithResult:(id)result API_Index:(NSInteger)index
{
    [UIAppDelegate hideLoaderWithinteractionDisabled];
    
    if (index == AUTHENTICATE_API)
    {
        [self showHideAuthenticationView];
        
        [self placeOrderAPI];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Your order has been placed successfully !" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        alert.tag = 101;
        [alert show];
    }
    

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

#pragma mark - UIAlertView Delegates

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 101)
    {
//        [[Database sharedObject] deleteRestaurantDetail];
        [[Database sharedObject] deleteAllProducts];
        [self.navigationController popToRootViewControllerAnimated:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectHomeTab" object:nil];
    }
}


#pragma mark - UITableView Datasource/Delegates


-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return addressArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addressCell"];
    
    if (!IS_iOS8)
    {
        cell.contentView.frame = cell.bounds;
        cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    }
    [self setUpAddressCellDetails:cell AtIndexPath:indexPath];
    
    return cell;
}

-(void)setUpAddressCellDetails: (UITableViewCell *)cell AtIndexPath:(NSIndexPath *)indexPath
{
    UIButton *radioBtn = (UIButton *)[cell.contentView viewWithTag:1];
    UILabel *addressLabel = (UILabel *)[cell.contentView viewWithTag:2];
    UIButton *editBtn = (UIButton *)[cell.contentView viewWithTag:3];
    UIButton *deleteBtn = (UIButton *)[cell.contentView viewWithTag:4];
    
    [radioBtn addTarget:self action:@selector(radioBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [editBtn addTarget:self action:@selector(editBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [deleteBtn addTarget:self action:@selector(deleteBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    NSDictionary *addressDict = addressArray[indexPath.row];
    NSString *address1 = addressDict[@"address1"];
    NSString *address2 = addressDict[@"address2"];
    NSString *pin = addressDict[@"pin"];
    
    if (address1.length > 0)
    {
        addressLabel.text = address1;
    }
    if (address2.length > 0)
    {
        addressLabel.text = [NSString stringWithFormat:@"%@, %@",addressLabel.text,address2];
    }
    if (pin.length > 0)
    {
        addressLabel.text = [NSString stringWithFormat:@"%@, %@",addressLabel.text,pin];
    }
    
    if (indexPath.row == selectedAddressIndex || [addressDict[@"isDefault"] integerValue] == 1)
    {
        radioBtn.selected = YES;
        selectedAddressIndex = indexPath.row;
        selectedAddressDict = addressDict;
    }
    else
    {
        radioBtn.selected = NO;
    }

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}


#pragma mark - UITableViewCell's Button Actions

-(void)radioBtnAction:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:addressTableView];
    NSIndexPath *indexPath = [addressTableView indexPathForRowAtPoint:buttonPosition];
    
    if (indexPath.row != selectedAddressIndex)
    {
        selectedAddressIndex = indexPath.row;
        
        for (NSDictionary *addDict in addressArray)
        {
            if ([addDict[@"isDefault"] integerValue] == 1)
            {
                NSInteger currentIndex = [addressArray indexOfObject:addDict];
                NSMutableDictionary *updatedDict = [[NSMutableDictionary alloc] initWithDictionary:addDict];
                int addressId = [updatedDict[@"id"] intValue];
                [[Database sharedObject] updateAddressWithAddress1:updatedDict[@"address1"] Address2:updatedDict[@"address2"] pin:updatedDict[@"pin"] is_Default:0 AddressId:addressId];
                [updatedDict setObject:@"0" forKey:@"isDefault"];
                [addressArray replaceObjectAtIndex:currentIndex withObject:updatedDict];
                break;
            }
        }
        
        NSInteger currentIndex = [addressArray indexOfObject:addressArray[selectedAddressIndex]];
        NSMutableDictionary *updatedDict = [[NSMutableDictionary alloc] initWithDictionary:addressArray[selectedAddressIndex]];
        int addressId = [updatedDict[@"id"] intValue];
        [[Database sharedObject] updateAddressWithAddress1:updatedDict[@"address1"] Address2:updatedDict[@"address2"] pin:updatedDict[@"pin"] is_Default:1 AddressId:addressId];
        [updatedDict setObject:@"1" forKey:@"isDefault"];
        [addressArray replaceObjectAtIndex:currentIndex withObject:updatedDict];
        [addressTableView reloadData];
    }
}

-(void)editBtnAction:(id)sender
{
    addressMode = 1;
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:addressTableView];
    NSIndexPath *indexPath = [addressTableView indexPathForRowAtPoint:buttonPosition];
    editIndex = indexPath.row;
    [self performSegueWithIdentifier:@"AddressSegue" sender:nil];
}

-(void)deleteBtnAction:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:addressTableView];
    NSIndexPath *indexPath = [addressTableView indexPathForRowAtPoint:buttonPosition];
    
    if (indexPath.row == selectedAddressIndex)
    {
        selectedAddressIndex = -1;
    }
    
    int addressId = [[addressArray[indexPath.row] valueForKey:@"id"] intValue];
    [[Database sharedObject] deleteAddressWithId:addressId];
    
    [addressArray removeObjectAtIndex:indexPath.row];
    
    [addressTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    if (addressArray.count < 3)
    {
        addAddressBtn.hidden = NO;
    }
    
    addressTableHeightConstraint.constant = 50.0 + 45*addressArray.count;
}


#pragma mark - UItextfield Delegates

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"identifier :%@",[segue destinationViewController]);
    if ([[segue destinationViewController] isKindOfClass:[AddressViewController class]])
    {
        if (addressMode == 1)
        {
            AddressViewController *addressCtrlObj = (AddressViewController *)[segue destinationViewController];
            addressCtrlObj.addressDict = addressArray[editIndex];
            
        }
    }
}


@end
