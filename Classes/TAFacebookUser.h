//
//  TAFacebookUser.h
//  TravelApp
//
//  Created by shirish on 23/11/12.
//  Copyright (c) 2012 mutualmobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TAFacebookUser : NSObject

@property (nonatomic, strong) NSString *facebookID;
@property (nonatomic, strong) NSString *emailId;
@property (nonatomic, strong) NSString *facebookAccessToken;

@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSString *gender;
@property (nonatomic, strong) NSDate *dateOfBirth;
@property (nonatomic, strong) NSString *profileDescription;
@property (nonatomic, strong) NSString *profileUrl;

@end
