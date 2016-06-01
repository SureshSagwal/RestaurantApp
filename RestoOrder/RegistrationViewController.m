//
//  RegistrationViewController.m
//  RestoOrder
//
//  Created by Suresh Kumar on 14/07/15.
//
//

#import "RegistrationViewController.h"
#import "WebService.h"
#import "Constants.h"

#import "TooltipView.h"
#import "InvalidTooltipView.h"

@interface RegistrationViewController ()<UITextFieldDelegate, WebServiceDelegate>
{
    
    __weak IBOutlet UITextField *nameTextField;
    __weak IBOutlet UITextField *emailTextField;
    __weak IBOutlet UITextField *passwordTextField;
    __weak IBOutlet UITextField *confirmPasswordTextField;
    __weak IBOutlet UITextField *phoneNoTextField;
    __weak IBOutlet UIScrollView *scrollView;
    BOOL isKeyboardShown;
    
    UIGestureRecognizer *tapper;
    
    TooltipView *toolTipView;
    
}
- (IBAction)backBtnAction:(id)sender;
- (IBAction)signUpBtnAction:(id)sender;
@end

@implementation RegistrationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isKeyboardShown = NO;
    
    tapper = [[UITapGestureRecognizer alloc]
              initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
    
    // Do any additional setup after loading the view.
}

#pragma mark - UIButtons Action

- (IBAction)backBtnAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)signUpBtnAction:(id)sender {
    
    [self validateBeforeSignUpRequest];
}

#pragma mark - Local Actions

-(void)validateBeforeSignUpRequest
{
    if (toolTipView != nil)
    {
        [toolTipView removeFromSuperview];
        toolTipView = nil;
    }
    
    Validator *validator = [[Validator alloc] init];
    validator.delegate   = self;
    
    [validator putRule:[Rules isBlank:@"Enter user's name !" forTextField:nameTextField]];
    [validator putRule:[Rules isBlank:@"Enter email address !" forTextField:emailTextField]];
    [validator putRule:[Rules checkIsValidEmailWithFailureString:@"Enter valid email !" forTextField:emailTextField]];
    [validator putRule:[Rules isBlank:@"Enter password !" forTextField:passwordTextField]];
    [validator putRule:[Rules isBlank:@"Confirm password !" forTextField:confirmPasswordTextField]];
    [validator putRule:[Rules isBlank:@"Enter Phone number !" forTextField:phoneNoTextField]];
    [validator putRule:[Rules checkIfStringEqualToString:passwordTextField.text forTextField:confirmPasswordTextField]];
    
    [validator validate];
}

-(void)sendSignUpRequest
{
    [UIAppDelegate showLoaderWithinteractionDisabled];
    
    WebService *serviceObj = [[WebService alloc] init];
    serviceObj.delegate = self;
    serviceObj.API_TYPE = SIGNUP_API;
    serviceObj.API_INDEX = SIGNUP_API;
    
    NSMutableDictionary *paraDict = [[NSMutableDictionary alloc] init];
    [paraDict setObject:@"" forKey:@"facebookId"];
    [paraDict setObject:nameTextField.text forKey:@"name"];
    [paraDict setObject:emailTextField.text forKey:@"email"];
    [paraDict setObject:passwordTextField.text forKey:@"password"];
    [paraDict setObject:phoneNoTextField.text forKey:@"mobile"];
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
    
    [self performSelector:@selector(sendSignUpRequest) withObject:nil afterDelay:0.1];
    
    NSLog(@"Success");
    
}

- (void)onFailure:(Rule *)failedRule
{
    CGPoint point           = [failedRule.textField convertPoint:CGPointMake(0.0, failedRule.textField.frame.size.height) toView:scrollView];
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
    
    [self performSegueWithIdentifier:@"RegistrationSegue" sender:nil];
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


#pragma mark - TextField delegates

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
    if (textField == nameTextField)
    {
        [emailTextField becomeFirstResponder];
    }
    else if (textField == emailTextField)
    {
        [passwordTextField becomeFirstResponder];
    }
    else if (textField == passwordTextField)
    {
        [confirmPasswordTextField becomeFirstResponder];
    }
    else if (textField == confirmPasswordTextField)
    {
        [phoneNoTextField becomeFirstResponder];
    }
    else if (textField == phoneNoTextField)
    {
        [phoneNoTextField resignFirstResponder];
        [scrollView setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
    }
    return YES;
}

#pragma mark - UITapGesture action

- (void)handleSingleTap:(UIGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}

#pragma mark - UITouch Delegates

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [nameTextField resignFirstResponder];
    [emailTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];
    [confirmPasswordTextField resignFirstResponder];
    [phoneNoTextField resignFirstResponder];
}

#pragma mark - Keyboard Delegate

- (void)keyboardWillHide:(NSNotification *)n
{
    isKeyboardShown = NO;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    [UIView commitAnimations];
    
}

- (void)keyboardWillShow:(NSNotification *)n
{
    if (isKeyboardShown == YES)
    {
        return;
    }
    isKeyboardShown = YES;
    NSDictionary* userInfo = [n userInfo];
    
    // get the size of the keyboard
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height - 50, 0.0);
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    
    [UIView commitAnimations];
    
    CGRect rect = scrollView.frame; rect.size.height -= keyboardSize.height; rect.origin.y = 0;
    
    if ([nameTextField isFirstResponder])
    {
        if (!CGRectContainsPoint(rect, nameTextField.frame.origin))
        {
            CGPoint scrollPoint = CGPointMake(0.0, 0.0);
            [scrollView setContentOffset:scrollPoint animated:YES];
        }
        
    }
    
    if ([emailTextField isFirstResponder])
    {
        if (!CGRectContainsPoint(rect, emailTextField.frame.origin))
        {
            CGPoint scrollPoint = CGPointMake(0.0, emailTextField.frame.origin.y - (keyboardSize.height - emailTextField.frame.size.height));
            [scrollView setContentOffset:scrollPoint animated:YES];
        }
        
    }
    
    if ([passwordTextField isFirstResponder])
    {
        if (!CGRectContainsPoint(rect, passwordTextField.frame.origin))
        {
            CGPoint scrollPoint = CGPointMake(0.0, passwordTextField.frame.origin.y - (keyboardSize.height - passwordTextField.frame.size.height));
            [scrollView setContentOffset:scrollPoint animated:YES];
        }
        
    }
    
    if ([confirmPasswordTextField isFirstResponder])
    {
        if (!CGRectContainsPoint(rect, confirmPasswordTextField.frame.origin))
        {
            CGPoint scrollPoint = CGPointMake(0.0, confirmPasswordTextField.frame.origin.y - (keyboardSize.height - confirmPasswordTextField.frame.size.height));
            [scrollView setContentOffset:scrollPoint animated:YES];
        }
        
    }
    
    if ([phoneNoTextField isFirstResponder])
    {
        if (!CGRectContainsPoint(rect, phoneNoTextField.frame.origin))
        {
            CGPoint scrollPoint = CGPointMake(0.0, phoneNoTextField.frame.origin.y - (keyboardSize.height - phoneNoTextField.frame.size.height));
            [scrollView setContentOffset:scrollPoint animated:YES];
        }
        
    }
    
    
}


#pragma mark -
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    //    if ([segue.identifier isEqualToString:@""])
    //    {
    //        RegistrationViewController *regisObj = segue.destinationViewController;
    //    }
}

@end
