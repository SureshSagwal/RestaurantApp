//
//  ViewController.m
//  RestoOrder
//
//  Created by Suresh Kumar on 05/07/15.
//
//

#import "LoginViewController.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "WebService.h"
#import "Constants.h"

#import "TooltipView.h"
#import "InvalidTooltipView.h"

@interface LoginViewController ()<WebServiceDelegate,UITextFieldDelegate>
{
    
    __weak IBOutlet UIScrollView *scrollView;
    __weak IBOutlet UITextField *emailTextField;
    __weak IBOutlet UITextField *passwordTextField;
    BOOL isKeyboardShown;
    
    UIGestureRecognizer *tapper;        // identify the touch in scrollview
    
    TooltipView *toolTipView;
}
- (IBAction)loginBtnAction:(id)sender;
- (IBAction)loginWithFacebookBtnAction:(id)sender;

@end

@implementation LoginViewController

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
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)viewWillAppear:(BOOL)animated
{
    
}

#pragma mark - UIButton Actions

- (IBAction)loginBtnAction:(id)sender {
    
    [self validateBeforeLoginRequest];
}

- (IBAction)loginWithFacebookBtnAction:(id)sender {
    
    if ([FBSDKAccessToken currentAccessToken])
    {
        [self AccessFacebookProfile];
    }
    else
    {
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        
        login.loginBehavior = FBSDKLoginBehaviorSystemAccount;
        
        [login logInWithReadPermissions:@[@"public_profile",@"email"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            if (error) {
                // Process error
            } else if (result.isCancelled) {
                // Handle cancellations
            } else {
                // If you ask for multiple permissions at once, you
                // should check if specific permissions missing
                if ([result.grantedPermissions containsObject:@"email"]) {
                    // Do work
                }
                [self AccessFacebookProfile];
            }
        }];
    }
}

-(void)AccessFacebookProfile
{
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"email, name, id"}];
//    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"first_name, last_name, picture.type(large), email, name, id, gender, birthday"}];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result is a dictionary with the user's Facebook data
            NSDictionary *userData = (NSDictionary *)result;
            
            NSString *facebookID = userData[@"id"];
            NSString *name = userData[@"name"];
            NSString *email = userData[@"email"];
            
//            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
            
            [UIAppDelegate showLoaderWithinteractionDisabled];
            WebService *serviceObj = [[WebService alloc] init];
            serviceObj.delegate = self;
            serviceObj.API_TYPE = SIGNUP_API;
            serviceObj.API_INDEX = SIGNUP_API;
            NSMutableDictionary *paraDict = [[NSMutableDictionary alloc] init];
            [paraDict setObject:facebookID forKey:@"facebookId"];
            [paraDict setObject:name forKey:@"name"];
            [paraDict setObject:email forKey:@"email"];
            [paraDict setObject:@"" forKey:@"password"];
            [serviceObj startOperationWithPostParam:paraDict];
            
        }
        else
        {
            NSLog(@"error: %@",error.localizedDescription);
        }
    }];
}

#pragma mark - Local Actions

-(void)validateBeforeLoginRequest
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
    [validator putRule:[Rules isBlank:@"Enter password !" forTextField:passwordTextField]];
    
    [validator validate];
}

-(void)sendLoginRequest
{
    [UIAppDelegate showLoaderWithinteractionDisabled];
    WebService *serviceObj = [[WebService alloc] init];
    serviceObj.delegate = self;
    serviceObj.API_TYPE = LOGIN_API;
    serviceObj.API_INDEX = LOGIN_API;
    NSMutableDictionary *paraDict = [[NSMutableDictionary alloc] init];
    [paraDict setObject:emailTextField.text forKey:@"email"];
    [paraDict setObject:passwordTextField.text forKey:@"password"];
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
    
    [self performSelector:@selector(sendLoginRequest) withObject:nil afterDelay:0.1];
    
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
    if (index == SIGNUP_API)
    {
        
    }
    else if (index == LOGIN_API)
    {
        
    }
    
    [self performSegueWithIdentifier:@"LoginSegue" sender:nil];
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
    if (textField == emailTextField)
    {
        [passwordTextField becomeFirstResponder];
    }
    else if (textField == passwordTextField)
    {
        [passwordTextField resignFirstResponder];
        [scrollView setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
    }

    return true;
}

#pragma mark - UITapGesture action

- (void)handleSingleTap:(UIGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}

#pragma mark - UITouch Delegates

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [emailTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];
}
@end
