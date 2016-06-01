


#import <Foundation/Foundation.h>
#import "Rule.h"

@interface Rules : NSObject

+(id)sharedInstance;

+(Rule *)maxLength:(int)maxLength withFailureString:(NSString *)failureString forTextField:(UITextField *)textField;
+(Rule *)minLength:(int)minLength withFailureString:(NSString *)failureString forTextField:(UITextField *)textField;
+(Rule *)checkRange:(NSRange )range withFailureString:(NSString *)failureString forTextField:(UITextField *)textField;
+(Rule *)checkIfNumericWithFailureString:(NSString *)failureString forTextField:(UITextField *)textField;
+(Rule *)checkIfAlphaNumericWithFailureString:(NSString *)failureString forTextField:(UITextField *)textField;
+(Rule *)checkIfAlphabeticalWithFailureString:(NSString *)failureString forTextField:(UITextField *)textField;
+(Rule *)checkIsValidEmailWithFailureString:(NSString *)failureString forTextField:(UITextField *)textField;
+(Rule *)checkIfURLWithFailureString:(NSString *)failureString forTextField:(UITextField *)textField;
+(Rule *)checkIfShortandURLWithFailureString:(NSString *)failureString forTextField:(UITextField *)textField;

+(Rule *)checkIfStringEqualToString:(NSString *)String forTextField:(UITextField *)textField;
+(Rule *)isBlank:(NSString *)failureString forTextField:(UITextField *)textField;
+(Rule *)checkAgeLimitWithFailureString:(NSString *)failureString forTextField:(UITextField *)textField;

+(Rule *)checkIfPhoneNumberIsValidForTextField:(UITextField *)textField FailureString:(NSString *)failureString;
@end
