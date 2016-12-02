//
//  GTRootViewController.h
//  goTogether
//
//  Created by shirish gone on 23/03/14.
//  Copyright (c) 2014 gotogether. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GTRootViewController : UITabBarController

@property (strong, nonatomic) NSCache *imageCache;
@property (nonatomic, readwrite) BOOL didShowInviteAlert;

- (void)loadLoginViewControllerIfnotLoggedIn;
- (void)loadVerifyPhoneView;

- (void)showCreatedRide:(Event *)event;
- (void)showNotificationAlertWithMessage:(NSString *)message
                              andEventId:(NSString *)eventId
                          andViewHandler:(void(^)(NSString *eventId))handleView;

- (void)fetchEventDetailsAndShowForNotification:(Notification *)notification;

- (void)updateNotificationBadgeCount;
- (void)presentPhoneVerificationView ;

//- (void)showLocationAccessAlert ;
- (void)showLocationDisabledAlert ;

- (void)startServicesForLoggedInUser;

- (void)showInviteAlertWithMessage:(NSString *)message;

@end

