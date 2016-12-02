//
//  GTValidations.h
//  goTogether
//
//  Created by shirish on 15/03/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTValidations : NSObject

+ (BOOL)validateEmail: (NSString *)email;
+ (BOOL)validatePhoneNumber:(NSString *)phoneNumber;
+ (BOOL)validatePassword:(NSString *)password;
+ (BOOL)validateUser:(NSString *)userString;

+ (NSString *)countryCallingCode;
+ (BOOL)doesPhoneNumberContainCountryCode:(NSString *)phoneNumber;
+ (NSString *)makeInternationalPhoneNumber:(NSString *)phoneNumber;

@end
