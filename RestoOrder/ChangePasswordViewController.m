//
//  ChangePasswordViewController.m
//  RestoOrder
//
//  Created by Suresh Kumar on 14/07/15.
//
//

#import "ChangePasswordViewController.h"
#import "WebService.h"
#import "Constants.h"

#import "TooltipView.h"
#import "InvalidTooltipView.h"

@interface ChangePasswordViewController ()<UITextFieldDelegate, WebServiceDelegate>
{
    __weak IBOutlet UITextField *currentPasswordTextField;
    __weak IBOutlet UITextField *newPasswordTextField;
    __weak IBOutlet UITextField *confirmPasswordTextField;
    
    TooltipView *toolTipView;
}
- (IBAction)changePasswordBtnAction:(id)sender;

- (IBAction)backBtnAction:(id)sender;

@end

@implementation ChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - UIButtons Actions

- (IBAction)changePasswordBtnAction:(id)sender {
    
    [self validateBeforeChangePasswordRequest];
}

- (IBAction)backBtnAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Local Actions

-(void)validateBeforeChangePasswordRequest
{
    if (toolTipView != nil)
    {
        [toolTipView removeFromSuperview];
        toolTipView = nil;
    }
    
    Validator *validator = [[Validator alloc] init];
    validator.delegate   = self;
    
    [validator putRule:[Rules isBlank:@"Enter old password !" forTextField:currentPasswordTextField]];
    [validator putRule:[Rules isBlank:@"Enter new password !" forTextField:newPasswordTextField]];
    [validator putRule:[Rules isBlank:@"Confirm password !" forTextField:confirmPasswordTextField]];
    [validator putRule:[Rules checkIfStringEqualToString:newPasswordTextField.text forTextField:confirmPasswordTextField]];
    [validator validate];
}

-(void)sendChangePasswordRequest
{
    [UIAppDelegate showLoaderWithinteractionDisabled];
    WebService *serviceObj = [[WebService alloc] init];
    serviceObj.delegate = self;
    serviceObj.API_TYPE = CHANGE_PASSWORD_API;
    serviceObj.API_INDEX = CHANGE_PASSWORD_API;
    NSMutableDictionary *paraDict = [[NSMutableDictionary alloc] init];
    [paraDict setObject:currentPasswordTextField.text forKey:@"OldPassword"];
    [paraDict setObject:newPasswordTextField.text forKey:@"NewPassword"];
    [serviceObj startOperationWithPostParam:paraDict];
}

#pragma mark- ValidatorDelegate - Delegate methods

-(void)preValidation
{
    NSLog(@"Called before the validation begins");
}

- (void)onSuccess
{
    if (toolTipView != nil)
    {
        [toolTipView removeFromSuperview];
        toolTipView  = nil;
    }
    
    [self performSelector:@selector(sendChangePasswordRequest) withObject:nil afterDelay:0.1];
    
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
    
    [UIAppDelegate displayAlertWithMessage:result];
    [self backBtnAction:nil];
}

-(void)serviceFinishedWithResponse:(id)response API_Index:(NSInteger)index
{
    [UIAppDelegate hideLoaderWithinteractionDisabled];
    [UIAppDelegate displayAlertWithMessage:response];
}

-(void)serviceFinishedWithError:(id)error API_Index:(NSInteger)index
{
    [UIAppDelegate hideLoaderWithinteractionDisabled];
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
    if (textField == currentPasswordTextField)
    {
        [newPasswordTextField becomeFirstResponder];
    }
    else if (textField == newPasswordTextField)
    {
        [confirmPasswordTextField becomeFirstResponder];
    }
    else if (textField == confirmPasswordTextField)
    {
        [confirmPasswordTextField resignFirstResponder];
    }
    
    return YES;
}

#pragma mark - UITouch Delegates

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [currentPasswordTextField resignFirstResponder];
    [newPasswordTextField resignFirstResponder];
    [confirmPasswordTextField resignFirstResponder];
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
