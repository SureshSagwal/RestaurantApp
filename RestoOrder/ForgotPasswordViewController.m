//
//  ForgotPasswordViewController.m
//  RestoOrder
//
//  Created by Suresh Kumar on 14/07/15.
//
//

#import "ForgotPasswordViewController.h"
#import "WebService.h"
#import "Constants.h"

#import "TooltipView.h"
#import "InvalidTooltipView.h"

@interface ForgotPasswordViewController ()<UITextFieldDelegate, UIAlertViewDelegate, WebServiceDelegate>
{
    __weak IBOutlet UITextField *emailTextField;
    TooltipView *toolTipView;
}
- (IBAction)getPasswordBtnAction:(id)sender;
- (IBAction)backBtnAction:(id)sender;
@end

@implementation ForgotPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - UIButtons Actions

- (IBAction)getPasswordBtnAction:(id)sender {
    
    [self validateBeforeForgotPasswordRequest];
}

- (IBAction)backBtnAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Local Actions

-(void)validateBeforeForgotPasswordRequest
{
    if (toolTipView != nil)
    {
        [toolTipView removeFromSuperview];
        toolTipView = nil;
    }
    
    Validator *validator = [[Validator alloc] init];
    validator.delegate   = self;
    
    [validator putRule:[Rules isBlank:@"Enter email address !" forTextField:emailTextField]];
    [validator putRule:[Rules checkIsValidEmailWithFailureString:@"Enter valid email !" forTextField:emailTextField]];
    
    [validator validate];
}

-(void)sendForgotPasswordRequest
{
    [UIAppDelegate showLoaderWithinteractionDisabled];
    
    [emailTextField resignFirstResponder];
    WebService *serviceObj = [[WebService alloc] init];
    serviceObj.delegate = self;
    serviceObj.API_TYPE = FORGOT_PASSWORD_API;
    serviceObj.API_INDEX = FORGOT_PASSWORD_API;
    NSMutableDictionary *paraDict = [[NSMutableDictionary alloc] init];
    [paraDict setObject:emailTextField.text forKey:@"email"];
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
    
    [self performSelector:@selector(sendForgotPasswordRequest) withObject:nil afterDelay:0.1];
    
    NSLog(@"Success");
    
}

- (void)onFailure:(Rule *)failedRule
{
    CGPoint point           = [failedRule.textField convertPoint:CGPointMake(0.0, failedRule.textField.frame.size.height-20.0) toView:self.view];
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
    
    NSString *responseStr = (NSString *)response;
    [UIAppDelegate displayAlertWithMessage:responseStr];
}

-(void)serviceFinishedWithError:(id)error API_Index:(NSInteger)index
{
    [UIAppDelegate hideLoaderWithinteractionDisabled];
    
    NSString *errorStr = (NSString *)error;
    [UIAppDelegate displayAlertWithMessage:errorStr];
}


#pragma mark - UIAlertView Delegates

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
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
    [textField resignFirstResponder];
    return true;
}

#pragma mark - UITouch Delegates

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [emailTextField resignFirstResponder];
}


@end
