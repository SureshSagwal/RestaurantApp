

#import "Rules.h"
#import "ValidatorRules.h"

@implementation Rules

static Rules *sharedInstance = nil;

+ (Rules *)sharedInstance 
{
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    return sharedInstance;
}

+ (Rule *)maxLength:(int)maxLength withFailureString:(NSString *)failureString forTextField:(UITextField *)textField
{
    Rule *resultRule = [[Rule alloc] init];
    resultRule.failureMessage = failureString;
    resultRule.textField = textField;
    if (textField.text.length > maxLength) {
        
        resultRule.isValid = NO;
    } else {
        
        resultRule.isValid = YES;
    }
    return resultRule;
}

+ (Rule *)minLength:(int)minLength withFailureString:(NSString *)failureString forTextField:(UITextField *)textField
{
    Rule *resultRule = [[Rule alloc] init];
    resultRule.failureMessage = failureString;
    resultRule.textField = textField;
    if (textField.text.length < minLength) {
        
        resultRule.isValid = NO;
    } else {
        
        resultRule.isValid = YES;
    }
    
    return resultRule;
}

+ (Rule *)checkRange:(NSRange )range withFailureString:(NSString *)failureString forTextField:(UITextField *)textField 
{
    
    Rule *resultRule = [[Rule alloc] init];
    resultRule.failureMessage = failureString;
    resultRule.textField = textField;
    resultRule.isValid = [NSString checkIfInRange:textField.text WithRange:range];
    
    return resultRule;
}

+ (Rule *)checkIfNumericWithFailureString:(NSString *)failureString forTextField:(UITextField *)textField
{
    
    Rule *resultRule = [[Rule alloc] init];
    resultRule.failureMessage = failureString;
    resultRule.textField = textField;
    resultRule.isValid = [NSString checkNumeric:textField.text];
    return resultRule;
}

+ (Rule *)checkIfAlphaNumericWithFailureString:(NSString *)failureString forTextField:(UITextField *)textField
{
    
    Rule *resultRule = [[Rule alloc] init];
    resultRule.failureMessage = failureString;
    resultRule.textField = textField;
    resultRule.isValid = [NSString checkIfAlphaNumeric:textField.text];
    return resultRule;
}

+ (Rule *)checkIfAlphabeticalWithFailureString:(NSString *)failureString forTextField:(UITextField *)textField
{
    
    Rule *resultRule = [[Rule alloc] init];
    resultRule.failureMessage = failureString;
    resultRule.textField = textField;
    resultRule.isValid = [NSString checkIfAlphabetical:textField.text];
    return resultRule;
}

+ (Rule *)checkIsValidEmailWithFailureString:(NSString *)failureString forTextField:(UITextField *)textField
{

    Rule *resultRule = [[Rule alloc] init];
    resultRule.failureMessage = failureString;
    resultRule.textField = textField;
    resultRule.isValid = [NSString checkIfEmailId:textField.text];
    return resultRule;
}

+ (Rule *)checkIfURLWithFailureString:(NSString *)failureString forTextField:(UITextField *)textField
{

    Rule *resultRule = [[Rule alloc] init];
    resultRule.failureMessage = failureString;
    resultRule.textField = textField;
    resultRule.isValid = [NSString checkIfURL:textField.text];
    return resultRule;
}

+ (Rule *)checkIfShortandURLWithFailureString:(NSString *)failureString forTextField:(UITextField *)textField
{
    
    Rule *resultRule = [[Rule alloc] init];
    resultRule.failureMessage = failureString;
    resultRule.textField = textField;
    resultRule.isValid = [NSString checkIfShorthandURL:textField.text];
    return resultRule;
}

+ (Rule *)checkIfStringEqualToString:(NSString *)String forTextField:(UITextField *)textField
{
    Rule *resultRule = [[Rule alloc] init];
    resultRule.failureMessage = @"Password mismatch !";
    resultRule.textField = textField;
    resultRule.isValid = [String isEqualToString:textField.text] ? YES : NO;
    return resultRule;
}
+ (Rule *)isBlank:(NSString *)failureString forTextField:(UITextField *)textField
{
Rule *resultRule = [[Rule alloc] init];
    if (textField.text.length ==0) {
        
      resultRule.failureMessage = failureString;
      resultRule.isValid=NO;
        resultRule.textField = textField;
        
    }else{
        resultRule.isValid=YES;
    }
    return resultRule;


}

+(Rule *)checkAgeLimitWithFailureString:(NSString *)failureString forTextField:(UITextField *)textField
{
    Rule *resultRule = [[Rule alloc] init];
    resultRule.failureMessage = failureString;
    resultRule.textField = textField;
    
    // Convert string to date object
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMM dd,yyyy"];
    NSDate *date = [dateFormat dateFromString:textField.text];
    
    int age=(int)[self age:date];
    
    if (age <= 13)
    {
        resultRule.isValid=NO;
    }
    else
    {
        resultRule.isValid=YES;
    }
    
    return resultRule;
}

+(NSInteger)age:(NSDate *)dateOfBirth
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *dateComponentsNow = [calendar components:unitFlags fromDate:[NSDate date]];
    NSDateComponents *dateComponentsBirth = [calendar components:unitFlags fromDate:dateOfBirth];
    
    if (([dateComponentsNow month] < [dateComponentsBirth month]) ||
        (([dateComponentsNow month] == [dateComponentsBirth month]) && ([dateComponentsNow day] < [dateComponentsBirth day]))) {
        return [dateComponentsNow year] - [dateComponentsBirth year] - 1;
    } else {
        return [dateComponentsNow year] - [dateComponentsBirth year];
    }
}

+(Rule *)checkIfPhoneNumberIsValidForTextField:(UITextField *)textField FailureString:(NSString *)failureString
{
    Rule *resultRule = [[Rule alloc] init];
    resultRule.failureMessage = failureString;
    resultRule.textField = textField;
    
    if ((textField.text.length >= 10) && (textField.text.length <= 15))
    {
        resultRule.isValid = YES;
    }
    else
    {
        resultRule.isValid = NO;
    }
    
    return resultRule;
}

@end
