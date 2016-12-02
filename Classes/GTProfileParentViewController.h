//
//  GTProfileParentViewController.h
//  goTogether
//
//  Created by Pavan Krishna on 24/04/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
@class User;

@interface GTProfileParentViewController : TABaseViewController

@property (nonatomic, strong) User *user;
@property (nonatomic, assign) BOOL canShowPhoneNumber;

- (void)pushToEventDetailsWithData:(Event *)eventDetails ;

- (void)showUserDetailsForUserId:(NSString *)userId;
- (void)showCurrentUser;

@end
