

#import <Foundation/Foundation.h>

@interface NSString (ValidatorRules)

+ (BOOL)checkIfAlphaNumeric:(NSString *)string;
+ (BOOL)checkIfAlphabetical:(NSString *)string;
+ (BOOL)checkIfEmailId:(NSString *)string;
+ (BOOL)checkNumeric:(NSString *)string;
+ (BOOL)checkPostCodeUK:(NSString *)string;
+ (BOOL)checkIfURL:(NSString *)string;
+ (BOOL)checkIfShorthandURL:(NSString *)string;
+ (BOOL)checkIfInRange:(NSString *)string WithRange:(NSRange)_range;
- (BOOL)isNotEqualToString:(NSString *)string;
- (BOOL)containsString:(NSString *)string;
- (NSString *)stringBetweenString:(NSString *)start andString:(NSString*)end;

@end
