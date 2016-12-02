//
//  GTTravellersListViewController.m
//  goTogether
//
//  Created by shirish gone on 09/07/14.
//  Copyright (c) 2014 gotogether. All rights reserved.
//

#import "GTTravellersListViewController.h"
#import "GTEventDetailsTravellersCell.h"
#import "GTProfileViewController.h"
#import "GTEventDetail_RideRequestCell.h"
#import "GTRideDetailsParentViewController.h"

#define kCellHeight_travellerCell 60.0f
#define kCellHeight_notificationCell 80.0f

@interface GTTravellersListViewController () <GTEventDetail_RideRequestCell_delegate>
@property (nonatomic, strong) GTProfileViewController *profileViewController;
@end

@implementation GTTravellersListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupPullToRefresh];
    [self.view setBackgroundColor:kColorGlobalBackground];
}

- (void)setEvent:(Event *)event {
    _event = event;
    [self.tableView reloadData];
}

#pragma mark - pull to refresh

- (void)refresh:(id)sender {
    self.event = [Event eventForEventId:self.event.eventId];
    [self.tableView reloadData];
}

- (void)stopRefreshing {
    [self.refreshControl endRefreshing];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.event isCurrentUserEvent]) {
        return 2;
    }else{
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [[self.event travellersListDetails] count];
    }else {
        return [[self.event requestedUserDetails] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        NSString *cell_resuableIdentifier = @"TravellersListCell";
        UITableViewCell *cell = [tableView
                                 dequeueReusableCellWithIdentifier:cell_resuableIdentifier
                                 ];

        GTTravellerDetails *travellerDetail = [[self.event travellersListDetails]
                                               objectAtIndex:indexPath.row];
        
        GTEventDetailsTravellersCell *travellerCell = (GTEventDetailsTravellersCell *)cell;
        [travellerCell setTravellerDetail:travellerDetail];

        NSString *currentUserId = [[User currentUser] userId];
        if ([currentUserId isEqualToString:self.event.userId]) {
            if ([travellerDetail.userId isEqualToString:currentUserId]) {
                travellerCell.canShowCallButton = NO;
            }else {
                travellerCell.canShowCallButton = YES;
            }
        }else{
            travellerCell.canShowCallButton = NO;
        }

        return cell;
    }else {
        NSString *cell_resuableIdentifier = @"cellIdentifierEventDetails_bookSeat";
        UITableViewCell *cell = [tableView
                                 dequeueReusableCellWithIdentifier:cell_resuableIdentifier
                                 forIndexPath:indexPath
                                 ];
        GTTravellerDetails *requestedUserDetail = [[self.event requestedUserDetails]
                                                   objectAtIndex:indexPath.row];

        [(GTEventDetail_RideRequestCell *)cell setRequestedUserDetail:requestedUserDetail];
        [(GTEventDetail_RideRequestCell *)cell setEvent_createdUserType:_event.userTypeValue];
        [(GTEventDetail_RideRequestCell *)cell setDelegate:self];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return kCellHeight_travellerCell;
    }else {
        return kCellHeight_notificationCell;
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NSString *userId = [[self.event travellers_list] objectAtIndex:indexPath.row];
        [self loadUserProfileWithUserId:userId];
    }else {
        NSString *userId = [[self.event requestedUsers] objectAtIndex:indexPath.row];
        [self loadUserProfileWithUserId:userId];
    }
}

#pragma mark Accept/ Reject methods

- (void)viewProfileButtonTouchedWithUsedId:(NSString *)userId {
    [self loadUserProfileWithUserId:userId];
}

- (void)acceptButtonTouchedForRequestedUserId:(NSString *)userId{
    
    NSString *titleString = NSLocalizedString(@"confirmride_title", nil);
    NSString *messageString = [NSString stringWithFormat:NSLocalizedString(@"confirmride_message", nil),
                               userId];
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
     addButtonWithTitle:@"Confirm Now"
     type:SIAlertViewButtonTypeDefault
     handler:^(SIAlertView *alertView) {
         [self confirmNowWithUserId:userId];
     }];
    [confirmationAlert show];

}
- (void)confirmNowWithUserId:(NSString *)userId {
    [self displayActivityIndicatorViewWithMessage:@"Confirming seat."];
    
    [Event
     confirmSeatWithEventId:_event.eventId
     requestUserId:userId
     seatCount:1
     userType:self.event.userTypeValue
     sucess:^(id response) {
         
         [self updateEvent];
     } failure:^(NSError *error) {
         [self displayFailureMessage:@"Failed to confirm the request."];
     }];
}

- (void)rejectButtonTouchedForRequestedUserId:(NSString *)userId{
    [self updateEvent];
}

- (void)updateEvent {
    GTRideDetailsParentViewController *rideDetailsParentViewController = (GTRideDetailsParentViewController *)[self parentViewController];
    [rideDetailsParentViewController updateEvent];
}

- (void)loadUserProfileWithUserId:(NSString *)userId {
    User *user = [User userForUserId:userId];
    if (user == nil) {
        [self displayActivityIndicatorViewWithMessage:@"Fetching user details..."];
        [User
         getProfileDetailsForUserId:userId
         sucess:^(User *user) {
             [self hideStatusMessage];
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

#pragma mark - user details navigation

- (void)loadTravellerProfileWithUserDetails:(User *)user{
    
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
