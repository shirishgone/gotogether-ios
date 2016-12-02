//
//  GTMyEventsViewController.m
//  goTogether
//
//  Created by shirish on 22/04/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import "GTMyRidesViewController.h"
#import "goTogetherAppDelegate.h"
#import "GTRideDetailsParentViewController.h"
#import "GTProfileParentViewController.h"
#import "GTMyRideCell.h"

#define kTableCellHeight 60.0

@interface GTMyRidesViewController ()

@property (nonatomic, strong) NSArray *myRides;
@property (nonatomic, strong) Event *selectedEvent;
@property (nonatomic, assign) BOOL reloading;

@end

@implementation GTMyRidesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:kColorGlobalBackground];
    self.title = @"My Rides";

    [self setupPullToRefresh];
    [self addNotificationHandlers];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self trackScreenName:@"MyRides"];
    [self refresh:nil];
}

- (void)addNotificationHandlers {
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(newRideCreated:)
     name:kNotificaionType_newEventCreated
     object:nil
     ];


    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(eventUpdated:)
     name:kNotificaionType_eventUpdated
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(eventDeleted:)
     name:kNotificationType_eventDeleted
     object:nil
     ];
}

#pragma mark - Fetch MyEvents

- (void)loadEventsForUserId:(NSString *)userId {
    if (self.appDelegate.netStatus != kNotReachable) {
        [self displayActivityIndicatorViewWithMessage:@"Loading your rides..."];
        
        [Event
         obtainRidesForUserId:userId
         success:^(NSArray *rides) {
             [self doneLoadingTableViewData];
             self.myRides = rides;
             if(rides.count == 0){
                 NSString *noResultsString = @"Ahh!!! You haven't shared your first ride yet. Come, lets do it together.";                 
                 [self displayNoResultsLabelWithMessage:noResultsString];
                        
             }else{
                 [self removeNoResultsLabel];
             }
             [self hideStatusMessage];
             [self.tableView reloadData];
             
         }failure:^(NSError *error) {
             [self doneLoadingTableViewData];
             [self displayFailureMessage:@"Loading rides failed."];
         }];
    }else {
        [self doneLoadingTableViewData];
        [self displayNoInternetMessage];
    }
}

#pragma mark - TableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;{
    return [[self myRides] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    GTMyRideCell *cell = nil;
    cell = [self.tableView dequeueReusableCellWithIdentifier:kCellIdentifier_myride
                         forIndexPath:indexPath
                         ];
    Event *eventDetails = nil;
    eventDetails = [self.myRides objectAtIndex:indexPath.row];

    [cell setEvent:eventDetails];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kTableCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    self.selectedEvent = [self.myRides objectAtIndex:indexPath.row];
    
    UIStoryboard *storyBoard =
    [UIStoryboard storyboardWithName:kStoryBoardIdentifier_rideDetails bundle:[NSBundle mainBundle]];
    
    GTRideDetailsParentViewController *detailsViewController =
    [storyBoard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_rideDetailsParent];
    
    [detailsViewController setEvent:self.selectedEvent];
    [self.navigationController pushViewController:detailsViewController animated:YES];
}

#pragma mark - event updated handler

- (void)newRideCreated:(id)sender{
    [self refresh:nil];
}

- (void)eventDeleted:(id)sende{
    [self refresh:nil];
}

- (void)eventUpdated:(id)sender{
    NSNotification *notification = sender;
    if ([[notification name] isEqualToString:kNotificaionType_eventUpdated])
    {
        NSDictionary* userInfo = [notification userInfo];
        Event *event= [userInfo objectForKey:kNotificaionObject_updatedEvent];
        [self replaceUpdatedEventInMyRides:event];
        [self.tableView reloadData];
    }
}

- (void)replaceUpdatedEventInMyRides:(Event *)updatedEvent{

    NSInteger index = NSIntegerMax;
    for (int i = 0; i< [self.myRides count]; i++) {
        Event *obj = [self.myRides objectAtIndex:i];
        if ([updatedEvent.eventId isEqualToString:obj.eventId]) {
            index = i;
        }
    }
    
    if (index!=NSIntegerMax) {
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.myRides];
        [tempArray replaceObjectAtIndex:index withObject:updatedEvent];
        self.myRides = tempArray;
    }
}

#pragma mark - PullToRefresh

- (void)refresh:(id)sender {
    if (_reloading == NO) {
        NSString *userId = [User getUserId];
        if (userId != nil) {
            _reloading = YES;
            [self loadEventsForUserId:userId];
        }
    }
}

- (void)doneLoadingTableViewData {
    _reloading = NO;
    [self stopRefreshing];
}

#pragma mark - push to event details.

- (void)pushToEventDetailsWithData:(Event *)eventDetails {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:kStoryBoardIdentifier_rideDetails
                                                             bundle:[NSBundle mainBundle]];
    GTRideDetailsParentViewController *rideDetailsViewController =
    [mainStoryboard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_rideDetailsParent];
    [rideDetailsViewController setEvent:eventDetails];
    [self.navigationController pushViewController:rideDetailsViewController animated:YES];
}

@end
