//
//  AddressViewController.m
//  RestoOrder
//
//  Created by Suresh Kumar on 12/08/15.
//
//

#import "AddressViewController.h"
#import "Database.h"

@interface AddressViewController ()
{
    
    __weak IBOutlet UITextField *address1TextField;
    __weak IBOutlet UITextField *address2TextField;
    __weak IBOutlet UITextField *pincodeTextField;
}
- (IBAction)backBtnAction:(id)sender;
- (IBAction)saveBtnAction:(id)sender;
@end

@implementation AddressViewController
@synthesize addressDict;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (addressDict != nil)
    {
        address1TextField.text = addressDict[@"address1"];
        address2TextField.text = addressDict[@"address2"];
        pincodeTextField.text = addressDict[@"pin"];
    }
    // Do any additional setup after loading the view.
}


#pragma mark - UIButton Actions

- (IBAction)backBtnAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveBtnAction:(id)sender {
    
    NSString *address1Str = address1TextField.text;
    NSString *address2Str = address2TextField.text;
    NSString *pinStr = pincodeTextField.text;

    if (address1Str.length > 0)
    {
        if (addressDict != nil)
        {
            int addressId = [addressDict[@"id"] intValue];
            int isDefault = [addressDict[@"isDefault"] intValue];
            [[Database sharedObject] updateAddressWithAddress1:address1Str Address2:address2Str pin:pinStr is_Default:isDefault AddressId:addressId];
        }
        else
        {
            NSArray *addresses = [[Database sharedObject] readAllAddresses];
            if (addresses.count == 0)
            {
                [[Database sharedObject] addNewAddressWithAddress1:address1Str Address2:address2Str pin:pinStr is_Default:1];
            }
            else
            {
                [[Database sharedObject] addNewAddressWithAddress1:address1Str Address2:address2Str pin:pinStr is_Default:0];
            }
            
        }
        
        [self backBtnAction:nil];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Please enter Address Line #1 value" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
    
}


#pragma mark - UITouch Delegate

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [address1TextField resignFirstResponder];
    [address2TextField resignFirstResponder];
    [pincodeTextField resignFirstResponder];
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
