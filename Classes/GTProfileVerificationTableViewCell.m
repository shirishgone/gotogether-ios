//
//  GTProfileVerificationTableViewCell.m
//  goTogether
//
//  Created by shirish gone on 13/09/14.
//  Copyright (c) 2014 gotogether. All rights reserved.
//

#import "GTProfileVerificationTableViewCell.h"

@interface GTProfileVerificationTableViewCell()

@property (nonatomic, weak) IBOutlet UILabel *verifiedByLabel;

@end

@implementation GTProfileVerificationTableViewCell

- (void)setVerificationType:(UserVerification)verificationType {
    _verificationType = verificationType;
    [self setColorForVerificationType:verificationType];
    [self.verifiedByLabel setText:[self verifiedByString:verificationType]];
}

- (NSString *)verifiedByString:(UserVerification)verificationType {

    NSString *verifiedByString = nil;
    switch (verificationType) {
        case UserPhoneNotVerified:
            verifiedByString = @"Not Verified";
            break;
            
        case UserPhoneVerified:
            verifiedByString = @"Verified";
            break;

        case UserPhoneVerifyNow:
            verifiedByString = @"Verify Now";
            break;

        default:
            break;
    }
   return verifiedByString;
}


- (void)setColorForVerificationType:(UserVerification)verificationType {
    if (verificationType == UserPhoneVerifyNow) {
        [self.verifiedByLabel setTextColor:[UIColor redColor]];
    }else if(verificationType == UserPhoneVerified) {
        [self.verifiedByLabel setTextColor:kColorPalette_baseColor];
    }else{
        [self.verifiedByLabel setTextColor:[UIColor grayColor]];
    }
}

@end
