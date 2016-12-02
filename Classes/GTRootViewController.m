//
//  GTRootViewController.m
//  goTogether
//
//  Created by shirish gone on 23/03/14.
//  Copyright (c) 2014 gotogether. All rights reserved.
//

#import "GTRootViewController.h"
#import "GTPhoneNumberVerificationController.h"
#import "SVProgressHUD.h"
#import "GTNotificationsViewController.h"
#import "GTProfileViewController.h"
#import "GTRideDetailsParentViewController.h"
#import "TAFacebookManager.h"
#import "GTPushNotificationManager.h"
#import "GTMyRidesViewController.h"
#import "GTAWSManager.h"
#import "TALocationManager.h"
#import "GTInviteFriendsViewController.h"

@interface GTRootViewController () <UITabBarControllerDelegate>

@end

@implementation GTRootViewController

- (void)awakeFromNib {
    [self handleSIAlertViewDismissNotification];
    self.imageCache = [[NSCache alloc] init];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.delegate = self;
    [self addNotificationHandlers];
}

#pragma mark -

- (void)addNotificationHandlers {
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(loggedInSuccessfully:)
     name:kNotificationType_loginSuccessful
     object:nil
     ];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(loggedOutSuccessfully:)
     name:kNotificaionType_loggedOut
     object:nil
     ];
}

- (void)loadLoginViewControllerIfnotLoggedIn{
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:kLoginStoryBoardIdentifier
                                                             bundle:[NSBundle mainBundle]];
    
    UINavigationController *loginNavigationController =
    [mainStoryboard instantiateViewControllerWithIdentifier:@"GTLoginNavigationController"];
    
    
    [self presentViewController:loginNavigationController
                       animated:NO
                     completion:nil];
}

- (void)loadVerifyPhoneView {
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:kStoryBoardIdentifier
                                                             bundle:[NSBundle mainBundle]];
    
    GTPhoneNumberVerificationController *phoneNumberVerificationController =
    [mainStoryboard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_phoneNumberVerify];
    
    UINavigationController *navController = [[UINavigationController alloc]
                                             initWithRootViewController:phoneNumberVerificationController];
    
    [self presentViewController:navController
                       animated:YES
                     completion:nil];
}

- (void)updateNotificationBadgeCount {
    UITabBarItem *notificationsTab = [self.tabBar.items objectAtIndex:1];
    int count = [Notification unreadNotificationsCount];
    if (count > 0) {
        [notificationsTab setBadgeValue:[NSString stringWithFormat:@"%d",count]];
    }else{
        [notificationsTab setBadgeValue:nil];
    }
}

#pragma mark - Notifications

- (void)showError:(NSError *)error{
    [self displayFailureMessage:error.description];
}

#pragma mark - Notification Alerts

- (void)showNotificationAlertWithMessage:(NSString *)message
                              andEventId:(NSString *)eventId
                          andViewHandler:(void(^)(NSString *eventId))handleView{
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil andMessage:message];
    [alertView
     addButtonWithTitle:@"View"
     type:SIAlertViewButtonTypeDefault
     handler:^(SIAlertView *alertView) {
         handleView(eventId);
     }];
    
    [alertView
     addButtonWithTitle:@"Cancel"
     type:SIAlertViewButtonTypeDestructive
     handler:^(SIAlertView *alertView) {
     }];
    
    [alertView show];
}

- (void)handleSIAlertViewDismissNotification{
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(SIAlertViewDismissed:)
     name:SIAlertViewWillDismissNotification
     object:nil];
}

- (void)SIAlertViewDismissed:(id)sender{
    
    goTogetherAppDelegate *appDelegate = (goTogetherAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.window makeKeyAndVisible];
}

#pragma mark - fetch event details

- (void)fetchEventDetailsAndShowForNotification:(Notification *)notification{
    
    NSString *eventId = notification.eventId;
    
    [self displayActivityIndicatorViewWithMessage:@"Loading ..."];
    [Event
     getEventDetailsWithEventId:eventId
     sucess:^(Event *event) {
         
         [self hideStatusMessage];
         NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
         [userInfo setObject:event
                      forKey:kNotificaionObject_updatedEvent];
         [[NSNotificationCenter defaultCenter]
          postNotificationName:kNotificaionType_eventUpdated
          object:nil
          userInfo:userInfo];
         
         [self showEventDetailsWithData:event];
         
     } failure:^(NSError *error) {
         [self displayFailureMessage:error.description];
     }];
}

- (void)showCreatedRide:(Event *)event {
    self.selectedIndex = 3;
    
    UINavigationController *navController = (UINavigationController *)self.selectedViewController;
    [navController popToRootViewControllerAnimated:NO];
    
    GTMyRidesViewController *myridesViewController = (GTMyRidesViewController *)[navController topViewController];
    [myridesViewController pushToEventDetailsWithData:event];
}

- (void)showEventDetailsWithData:(Event *)eventDetails {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:kStoryBoardIdentifier_rideDetails                                                             bundle:[NSBundle mainBundle]];
    GTRideDetailsParentViewController *rideDetailsViewController =
    [mainStoryboard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_rideDetailsParent];
    [rideDetailsViewController setEvent:eventDetails];
    rideDetailsViewController.isPresented = YES;
    
    UINavigationController *rideDetailsNavController = [[UINavigationController alloc] initWithRootViewController:rideDetailsViewController];
    [self presentViewController:rideDetailsNavController animated:YES completion:nil];
}

- (void)presentPhoneVerificationView {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:kStoryBoardIdentifier
                                                         bundle:[NSBundle mainBundle]];
    GTPhoneNumberVerificationController *phoneNumberVerificationController =
    [storyBoard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_phoneNumberVerify];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:phoneNumberVerificationController];
    
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)presentInviteContacts {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:kStoryBoardIdentifier
                                                         bundle:[NSBundle mainBundle]];
    GTInviteFriendsViewController *inviteController =
    [storyBoard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_inviteFriends];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:inviteController];
    
    [self presentViewController:navController animated:YES completion:nil];
    
}

#pragma mark - Loading Indicator

- (void)displayLoadingView {
    [SVProgressHUD show];
}

- (void)displayNoInternetMessage {
    
    [SVProgressHUD showErrorWithStatus:@"No Internet!"];
}

- (void)displaySucessMessage:(NSString *)message{
    
    [SVProgressHUD showSuccessWithStatus:message];
}

- (void)displayFailureMessage:(NSString *)message{
    
    [SVProgressHUD showErrorWithStatus:message];
}

- (void)displayActivityIndicatorViewWithMessage:(NSString *)messageString{
    
    [SVProgressHUD showWithStatus:messageString];
}

- (void)hideStatusMessage {
    double delayInSeconds = 2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [SVProgressHUD dismiss];
    });
}

#pragma mark - tab bar delegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        id profileViewController = [[(UINavigationController *)viewController viewControllers] objectAtIndex:0];
        if ([profileViewController isKindOfClass:[GTProfileViewController class]]) {
            GTProfileViewController *profileController = (GTProfileViewController *)profileViewController;
            [profileController showCurrentUser];
        }
    }
}

#pragma mark - login & logout

- (void)startServicesForLoggedInUser {
    [[TALocationManager sharedInstance] startLocationManager];
    [[GTPushNotificationManager sharedInstance] updatePushToken];
}

- (void)stopServicesForLoggedOutUser {
    [[TALocationManager sharedInstance] stopUpdatingLocationManager];
}

- (void)loggedInSuccessfully:(id)sender {
    
    dispatch_async(dispatch_get_main_queue()
                   , ^{
                       [self startServicesForLoggedInUser];
                       [self showInviteAlertWithMessage:kInviteMessage_login];
                       
                       [[TAFacebookManager sharedInstance]
                        updateFacebookPictureToServerForUser:[User currentUser]
                        failure:^(NSError *error) {
                            [self displayFailureMessage:@"Failed to upload Facebook picture.."];
                        }];
                       [self fetchCompleteUserDetails];

                   });
}

- (void)loggedOutSuccessfully:(id)sender {
    [self stopServicesForLoggedOutUser];
    
    // CLEAR ALL DATA
    [[FBSession activeSession] closeAndClearTokenInformation];
    [[GTDataManager sharedInstance] cleanupDatabase];

    [self resetTabBar];
    [self loadLoginViewControllerIfnotLoggedIn];
    
}

- (void)resetTabBar {
    for (id controller in self.viewControllers) {
        if ([controller isMemberOfClass:[UINavigationController class]]) {
            UINavigationController *navController = (UINavigationController *)controller;
            [navController popToRootViewControllerAnimated:NO];
            [navController.topViewController.view layoutSubviews];
        }
    }
    self.selectedIndex = 0;
}

- (void)fetchCompleteUserDetails {
    // PULL COMPLETE USER DETAILS
    [User
     getProfileDetailsForUserId:[User getUserId]
     sucess:^(User *user) {
         if (user.facebookId != nil) {
             [[TAFacebookManager sharedInstance] updateFriendsOnGTServer];
         }
     } failure:^(NSError *error) {
         // Throw an error saying that unable to fetch user details.
     }];
}

#pragma mark - Location

- (void)showLocationDisabledAlert {
    SIAlertView *alert = [[SIAlertView alloc] initWithTitle:@"Location Access Disabled"
                                                 andMessage:kLocationServicesDisabledMessage];
    
    [alert setTransitionStyle:SIAlertViewTransitionStyleDropDown];
    [alert setBackgroundStyle:SIAlertViewBackgroundStyleSolid];
    [alert addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeCancel handler:nil];
    [alert show];
}

#pragma mark - Invite

- (void)showInviteAlertWithMessage:(NSString *)message {
    
    if (self.didShowInviteAlert == NO) {
        self.didShowInviteAlert = YES;
        SIAlertView *alert = [[SIAlertView alloc] initWithTitle:nil
                                                     andMessage:message];
        
        [alert setTransitionStyle:SIAlertViewTransitionStyleDropDown];
        [alert setBackgroundStyle:SIAlertViewBackgroundStyleSolid];
        [alert addButtonWithTitle:@"Later" type:SIAlertViewButtonTypeDestructive handler:nil];
        [alert addButtonWithTitle:@"Invite Now"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView) {
                              [self presentInviteContacts];
                          }];
        [alert show];
    }
}

@end
