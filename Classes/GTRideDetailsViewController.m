//
//  TALiveTrackingViewController.m
//  goTogether
//
//  Created by Sunil Gandham on 04/02/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import "GTRideDetailsViewController.h"
#import <MapKit/MapKit.h>
#import "GTEventDetailsHeaderView.h"
#import <GoogleMaps/GoogleMaps.h>
#import "GTRideDetailsParentViewController.h"
#import "GTPhoneNumberVerificationController.h"
#import "GTProfileViewController.h"

#define kCellHeight_rideAction 47.0f
#define kSectionHeader_height  30.0
#define kTableHeader_height  172.0

@interface GTRideDetailsViewController ()
<MKMapViewDelegate,
UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UIButton *bookSeatButton;
@property (nonatomic, strong) IBOutlet UIButton *callButton;
@property (nonatomic, strong) IBOutlet GTRouteMapView *mapView;
@property (nonatomic, strong) IBOutlet GTEventDetailsHeaderView *headerView;
@property (nonatomic, strong) GTProfileViewController *profileViewController;


- (IBAction)userProfileTouched:(id)sender;

@end

@implementation GTRideDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:kColorGlobalBackground];
    
    [self loadEventDetails:self.event];
}

- (void)setEvent:(Event *)event {
    _event = event;
    [self loadEventDetails:event];
}

- (void)loadEventDetails:(Event *)event {
    if (event !=nil) {
        [self setupMapView];
        [self setDataForHeaderView:self.event];
        [self setBookSeatButton];
        if ([self canShowCallButton]){
            [self showCallButton:YES];
        }else {
            [self showCallButton:NO];
        }        
    }
}

- (BOOL)canShowCallButton {
    NSString *currentUserId = [[User currentUser] userId];
    if ([self.event isUserInTravellersList:currentUserId]) {
        if ([self.event.userId isEqualToString:currentUserId]) {
            return NO;
        }else {
            return YES;
        }
    }else{
        return NO;
    }
}

- (void)showCallButton:(BOOL)show {
    if (show) {
        self.callButton.hidden = NO;
    }else {
        self.callButton.hidden = YES;
    }
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark -

- (void)setDataForHeaderView:(Event *)event {
    [self.headerView setEventInfo:event];
}

- (void)setBookSeatButton {
    BOOL canShow = [self canShowRequestButton];
    if (canShow == NO) {
        [self.bookSeatButton setHidden:YES];
    }else {
        [self.bookSeatButton setHidden:NO];
        [self.view bringSubviewToFront:self.bookSeatButton];
    }
    
    [self updateBookSeatButtonTitle];
}

- (void)updateBookSeatButtonTitle {
    if ([self canShowRequestButton]) {
        if ([_event isUserInRequestedList:[[User currentUser] userId]]) {
            [self.bookSeatButton setTitle:@"REQUEST SENT" forState:UIControlStateNormal];
        }else {
            [self.bookSeatButton setTitle:@"REQUEST SEAT" forState:UIControlStateNormal];
        }
    }
}

#pragma mark -

- (BOOL)canShowRequestButton {
    BOOL canShow = NO;
    User *currentUser = [User currentUser];
    if ([_event isOlderEvent] == NO &&
        [_event isUserInTravellersList:currentUser.userId] == NO)
    {
        canShow = YES;
    }
    return canShow;
}

- (BOOL)alreadyGotASeat {
    if ([[self.event travellers_list] count] < 2) {
        return NO;
    }else{
        return YES;
    }
}

#pragma mark - Requesting methods
- (void)presentPhoneVerificationView {
    goTogetherAppDelegate *appDelegate = (goTogetherAppDelegate *)
    [[UIApplication sharedApplication] delegate];
    
    [appDelegate.rootViewController presentPhoneVerificationView];
}

- (IBAction)bookSeatButtonTouched:(id)sender {
    
    if ([self.event isUserInRequestedList:[[User currentUser] userId]]) {
        return;
    }
    
    if ([User isPhoneVerified] == NO) {
        NSString *message = @"Please verify your phone, before requesting for a ride.";
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil andMessage:message];
        [alertView addButtonWithTitle:@"Cancel" type:SIAlertViewButtonTypeDestructive handler:nil];
        [alertView addButtonWithTitle:@"Verify" type:SIAlertViewButtonTypeDefault handler:^
         (SIAlertView *alertView) {
             [self presentPhoneVerificationView];
        }];
        
        [alertView setTransitionStyle:SIAlertViewTransitionStyleDropDown];
        [alertView setBackgroundStyle:SIAlertViewBackgroundStyleSolid];
        [alertView show];

        
        return;
    }
    
    NSString *titleString = NSLocalizedString(@"requestride_title", nil);
    NSString *messageString = [NSString stringWithFormat:NSLocalizedString(@"requestride_message", nil),
                               [NSDate display_onlyDateStringFromDate:self.event.dateTime],
                               self.event.sourceName,
                               self.event.destinationName,
                               self.event.userName,
                               self.event.userName];

    SIAlertView *confirmationAlert = [[SIAlertView alloc]
                                      initWithTitle:titleString
                                      andMessage:messageString];
    
    [confirmationAlert setTransitionStyle:SIAlertViewTransitionStyleDropDown];
    [confirmationAlert setBackgroundStyle:SIAlertViewBackgroundStyleSolid];
    
    [confirmationAlert
     addButtonWithTitle:@"Cancel"
     type:SIAlertViewButtonTypeDestructive
     handler:nil];
    
    [confirmationAlert
     addButtonWithTitle:@"Request Now"
     type:SIAlertViewButtonTypeDefault
     handler:^(SIAlertView *alertView) {
         [self requestRide];
    }];
    [confirmationAlert show];
}

- (void)requestRide {
    goTogetherAppDelegate *appDelegate = (goTogetherAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.netStatus != kNotReachable) {
        
        [self displayActivityIndicatorViewWithMessage:@"Requesting Ride..."];
        NSInteger totalSeats = 1;
        [Event
         bookASeatinEventWithId:_event.eventId
         seatCount:totalSeats
         sucess:^(id response) {

             [self updateEvent];
             [self displaySucessMessage:@"Request sent!"];

         } failure:^(NSError *error) {
             [self hideStatusMessage];
             [self displayFailureMessage:@"Request failed."];
         }];

    }else{
        [self displayNoInternetMessage];
    }
}

- (void)setupMapView {
    CLLocationCoordinate2D sourceCoordinate =
    CLLocationCoordinate2DMake(self.event.sourceLatitudeValue,
                               self.event.sourceLongitudeValue);
    
    CLLocationCoordinate2D destinationCoordinate =
    CLLocationCoordinate2DMake(self.event.destinationLatitudeValue, self.event.destinationLongitudeValue);
    
    [self.mapView setSourceCoordinate:sourceCoordinate
             andDestinationCoordinate:destinationCoordinate
     ];
}

- (void)updateEvent {
    GTRideDetailsParentViewController *rideDetailsParentViewController = (GTRideDetailsParentViewController *)[self parentViewController];
    [rideDetailsParentViewController updateEvent];
}

- (IBAction)callButtonTouched:(id)sender {
    
    NSString *phoneNumberString;
    for (GTTravellerDetails *travellerDetail in self.event.travellersListDetails) {
        if ([travellerDetail.userId isEqualToString:self.event.userId]) {
            phoneNumberString = travellerDetail.phoneNumber;
        }
    }
    
    if (phoneNumberString != nil) {
        NSString *totalString = [@"telprompt://" stringByAppendingString:phoneNumberString];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:totalString]];
    }else {
        [self displayFailureMessage:@"Phone unavailable"];
    }
}

- (IBAction)userProfileTouched:(id)sender {
    [self loadUserProfileWithUserId:self.event.userId];
}

- (void)loadUserProfileWithUserId:(NSString *)userId {
    User *user = [User userForUserId:userId];
    if (user == nil) {
        [User
         getProfileDetailsForUserId:userId
         sucess:^(User *user) {
             [self loadTravellerProfileWithUserDetails:user];
         } failure:^(NSError *error) {
             [self displayFailureMessage:@"User details request failed!"];
         }];
        
    }else{
        [self loadTravellerProfileWithUserDetails:user];
        
        [User
         getProfileDetailsForUserId:userId
         sucess:^(User *user) {
             [self.profileViewController setUser:user];
         } failure:^(NSError *error) {
         }];
    }
}

- (void)loadTravellerProfileWithUserDetails:(User *)user {
    
    UIStoryboard *storyBoard =
    [UIStoryboard storyboardWithName:kStoryBoardIdentifier
                              bundle:[NSBundle mainBundle]];
    
    self.profileViewController =
    [storyBoard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_profile];
    [_profileViewController setUser:user];
    [self.navigationController pushViewController:_profileViewController
                                         animated:YES];
}

@end
