//
//  PersonalInfoViewController.m
//  RestoOrder
//
//  Created by Suresh Kumar on 14/07/15.
//
//

#import "PersonalInfoViewController.h"
#import "WebService.h"
#import "Constants.h"
#import "UserDetails.h"

#import "TooltipView.h"
#import "InvalidTooltipView.h"

@interface PersonalInfoViewController ()<UIAlertViewDelegate, UITextFieldDelegate, WebServiceDelegate>
{
    
    __weak IBOutlet UITextField *firstNameTextField;
    __weak IBOutlet UITextField *lastNameTextField;
    __weak IBOutlet UITextField *emailTextField;
    __weak IBOutlet UITextField *phoneTextField;
    
    TooltipView *toolTipView;
}
- (IBAction)backBtnAction:(id)sender;
- (IBAction)saveBtnAction:(id)sender;
@end

@implementation PersonalInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UserDetails *userDetailObj = [UserDetails sharedManager];
    NSString *name = userDetailObj.name;
    NSString *email = userDetailObj.email;
    NSString *mobile = userDetailObj.mobile;
    
    if (name.length > 0)
    {
        NSMutableArray *components = [NSMutableArray arrayWithArray:[name componentsSeparatedByString:@" "]];
        if (components.count > 1)
        {
            lastNameTextField.text = [components lastObject];
            [components removeLastObject];
            firstNameTextField.text = [components componentsJoinedByString:@" "];
        }
        else
        {
            firstNameTextField.text = name;
        }
    }
    if (email.length > 0)
    {
        emailTextField.text = email;
    }
    if (mobile.length > 0)
    {
        phoneTextField.text = mobile;
    }
    
    // Do any additional setup after loading the view.
}

#pragma mark - UIButtons Actions

- (IBAction)backBtnAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveBtnAction:(id)sender {
    
    [self validateBeforeSaveProfileRequest];
}

#pragma mark - Local Actions

-(void)validateBeforeSaveProfileRequest
{
    if (toolTipView != nil)
    {
        [toolTipView removeFromSuperview];
        toolTipView = nil;
    }
    
    Validator *validator = [[Validator alloc] init];
    validator.delegate   = self;
    
    [validator putRule:[Rules isBlank:@"Enter first name !" forTextField:firstNameTextField]];
    [validator putRule:[Rules isBlank:@"Enter email address !" forTextField:emailTextField]];
    [validator putRule:[Rules checkIsValidEmailWithFailureString:@"Enter valid email !" forTextField:emailTextField]];
    [validator putRule:[Rules isBlank:@"Enter mobile number !" forTextField:phoneTextField]];
    if (phoneTextField.text.length > 0)
    {
        [validator putRule:[Rules checkIfNumericWithFailureString:@"Enter numeric value !" forTextField:phoneTextField]];
        [validator putRule:[Rules checkIfPhoneNumberIsValidForTextField:phoneTextField FailureString:@"Enter valid phone number !"]];
    }
    
    
    [validator validate];
}

-(void)sendSaveProfileRequest
{
    [self.view endEditing:YES];
    
    [UIAppDelegate showLoaderWithinteractionDisabled];
    WebService *serviceObj = [[WebService alloc] init];
    serviceObj.delegate = self;
    serviceObj.API_TYPE = UPDATE_USER_INFO_API;
    serviceObj.API_INDEX = UPDATE_USER_INFO_API;
    
    NSMutableDictionary *paraDict = [[NSMutableDictionary alloc] init];
    [paraDict setObject:firstNameTextField.text forKey:@"firstName"];
    [paraDict setObject:lastNameTextField.text forKey:@"lastName"];
    [paraDict setObject:emailTextField.text forKey:@"email"];
    [paraDict setObject:phoneTextField.text forKey:@"phone"];
    [serviceObj startOperationWithPostParam:paraDict];
}

#pragma mark- ValidatorDelegate - Delegate methods

-(void)preValidation
{
    //    for (UITextField *textField in self.view.subviews) {
    //        textField.layer.borderWidth = 0;
    //    }
    
    NSLog(@"Called before the validation begins");
}

- (void)onSuccess
{
    if (toolTipView != nil)
    {
        [toolTipView removeFromSuperview];
        toolTipView  = nil;
    }
    
    [self performSelector:@selector(sendSaveProfileRequest) withObject:nil afterDelay:0.1];
    
    NSLog(@"Success");
    
}

- (void)onFailure:(Rule *)failedRule
{
    CGPoint point           = [failedRule.textField convertPoint:CGPointMake(0.0, failedRule.textField.frame.size.height - 20.0) toView:self.view];
    CGRect tooltipViewFrame = CGRectMake(failedRule.textField.frame.origin.x, point.y, failedRule.textField.frame.size.width, toolTipView.frame.size.height);
    
    toolTipView       = [[InvalidTooltipView alloc] init];
    toolTipView.frame = tooltipViewFrame;
    toolTipView.text  = [NSString stringWithFormat:@"%@",failedRule.failureMessage];
    toolTipView.rule  = failedRule;
    
    [self.view addSubview:toolTipView];
}

#pragma mark - WebService Delegates

-(void)serviceFinishedWithResult:(id)result API_Index:(NSInteger)index
{
    [UIAppDelegate hideLoaderWithinteractionDisabled];
    
    UserDetails *userDetailsObj = [UserDetails sharedManager];
    userDetailsObj.email = emailTextField.text;
    userDetailsObj.mobile = phoneTextField.text;    
    if (lastNameTextField.text.length > 0)
    {
        userDetailsObj.name = [NSString stringWithFormat:@"%@ %@",firstNameTextField.text, lastNameTextField.text];
    }
    else
    {
        userDetailsObj.name = firstNameTextField.text;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Profile has been updated successfully" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alert.tag = 101;
    [alert show];
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
        [self backBtnAction:nil];
    }
}


#pragma mark - UITextField Delegates

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (toolTipView != nil)
    {
        [toolTipView removeFromSuperview];
        toolTipView  = nil;
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (toolTipView != nil)
    {
        [toolTipView removeFromSuperview];
        toolTipView  = nil;
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == firstNameTextField)
    {
        [lastNameTextField becomeFirstResponder];
    }
    else if (textField == lastNameTextField)
    {
        [emailTextField becomeFirstResponder];
    }
    else if (textField == emailTextField)
    {
        [phoneTextField becomeFirstResponder];
    }
    else if (textField == phoneTextField)
    {
        [phoneTextField resignFirstResponder];
    }
    return YES;
}

#pragma mark - UITouch Delegate

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [firstNameTextField resignFirstResponder];
    [lastNameTextField resignFirstResponder];
    [emailTextField resignFirstResponder];
    [phoneTextField resignFirstResponder];
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
