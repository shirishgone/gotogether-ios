//
//  GTProfileVerificationTableViewCell.h
//  goTogether
//
//  Created by shirish gone on 13/09/14.
//  Copyright (c) 2014 gotogether. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    UserPhoneNotVerified,
    UserPhoneVerified,
    UserPhoneVerifyNow
} UserVerification;

@interface GTProfileVerificationTableViewCell : UITableViewCell

@property (nonatomic)UserVerification verificationType;

@end
