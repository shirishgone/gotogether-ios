//
//  GTValidations.m
//  goTogether
//
//  Created by shirish on 15/03/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import "GTValidations.h"
#import "NSString+GTExtensions.h"

@implementation GTValidations


+ (BOOL)validateEmail: (NSString *)email {
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL isValidEmail = [emailPredicate evaluateWithObject:email];
    
    if (isValidEmail) {
        return YES;
    }else{
        return NO;
    }
}

+ (BOOL)isPersonalEmail:(NSString *)email{

    NSArray *personalEmails = @[@"@gmail.com",
                              @"@yahoo.com",
                              @"@outlook.com",
                              @"@facebook.com",
                              @"@iCloud.com"];
    
    BOOL isPersonalEmail = NO;
    for (NSString *personalEmail in personalEmails) {
        
        if ([email rangeOfString:personalEmail].location != NSNotFound) {
            isPersonalEmail = YES;
        }
    }
    return isPersonalEmail;
}

+ (NSString *)phoneNumberWithoutCountryCode:(NSString *)phoneNumber {
    NSString *resultString = phoneNumber;
    NSCharacterSet *cset = [NSCharacterSet characterSetWithCharactersInString:@"+91"];
    NSRange range = [phoneNumber rangeOfCharacterFromSet:cset];
    if (range.location == NSNotFound) {
    } else {
        resultString = [phoneNumber substringFromIndex:3];
    }
    return resultString;
}

+ (BOOL)validatePhoneNumber:(NSString *)phoneNumber {    
    if ([[NSTextCheckingResult phoneNumberCheckingResultWithRange:NSMakeRange(0, [phoneNumber length]) phoneNumber:phoneNumber] resultType] == NSTextCheckingTypePhoneNumber) {
        return YES;
    } else {
        return NO;
    }
}

+ (NSString *)makeInternationalPhoneNumber:(NSString *)phoneNumber {
    return [NSMutableString stringWithFormat:@"+%@%@",
            [GTValidations countryCallingCode], phoneNumber];

}

+ (BOOL)doesPhoneNumberContainCountryCode:(NSString *)phoneNumber {
    NSString *countryCode = [self countryCallingCode];
    if ([phoneNumber hasPrefix:countryCode]) {
        return YES;
    }else {
        return NO;
    }
}

+ (NSString *)countryCallingCode {
    NSString * plistPath = [[NSBundle mainBundle] pathForResource:@"DiallingCodes" ofType:@"plist"];
    NSDictionary *codesDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [[locale objectForKey: NSLocaleCountryCode] lowercaseString];
    
    NSMutableString *callingCode = [[NSMutableString alloc] init];
    [callingCode appendString:[codesDictionary valueForKey:countryCode]];
    return callingCode;
}

+ (BOOL)validatePassword:(NSString *)password {
    if(password.length < 6){
        return NO;
    }else{
        return YES;
    }
}

+ (BOOL)validateUser:(NSString *)userString{
    if ([userString length] > 1) {
        return YES;
    }
    return NO;
}

@end
