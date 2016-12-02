//
//  GTSearchResultsViewController.m
//  goTogether
//
//  Created by shirish on 23/03/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import "GTSearchResultsViewController.h"
#import "GTSearchResultTableCell.h"
#import "GTRideDetailsParentViewController.h"
#import "goTogetherAppDelegate.h"
#import "TALocationManager.h"
#import "GTAddViewController.h"

@interface GTSearchResultsViewController ()

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, copy) NSArray *riderRides;

@property (nonatomic, strong) Event *selectedEvent;
@property (nonatomic) GTUserType searchUserType;
@property (nonatomic, assign) BOOL reloading;

@end

@implementation GTSearchResultsViewController

- (void)viewDidLoad{

    [super viewDidLoad];
    [self setTitle];
    [self setupPullToRefreshForTableView:self.tableView];
    [self searchEvents];
}

- (void)setTitle {
    NSString *titleString = [NSString stringWithFormat:@"%@ to %@",_searchObject.sourcePlace.displayName, _searchObject.destinationPlace.displayName];
    [self setTitle:titleString];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self trackScreenName:@"SearchResults"];
}

#pragma mark - table datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.riderRides count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    GTSearchResultTableCell *cell = nil;
    cell = [self.tableView dequeueReusableCellWithIdentifier:kCellIdentifier_searchResult
                        forIndexPath:indexPath
                        ];
    
    Event *eventDetails = [self.riderRides objectAtIndex:indexPath.row];
    [cell setEventDetails:eventDetails];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedEvent = [self.riderRides objectAtIndex:indexPath.row];
    UIStoryboard *storyBoard =
    [UIStoryboard storyboardWithName:kStoryBoardIdentifier_rideDetails bundle:[NSBundle mainBundle]];
    
    GTRideDetailsParentViewController *rideDetailsViewController =
    [storyBoard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_rideDetailsParent];
    [rideDetailsViewController setEvent:self.selectedEvent];
    [self.navigationController pushViewController:rideDetailsViewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 75.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

#pragma mark - PullToRefresh
- (void)refresh:(id)sender {
    if (_reloading == NO) {
        _reloading = YES;
        [self searchEvents];
    }
}

- (void)doneLoadingTableViewData {
    _reloading = NO;
    [self stopRefreshing];
}

#pragma mark - Search Rides/Requests API Call

- (void)searchEvents {
    goTogetherAppDelegate *appDelegate = (goTogetherAppDelegate *)
    [[UIApplication sharedApplication] delegate];
    if (appDelegate.netStatus != kNotReachable) {
        [self displayActivityIndicatorViewWithMessage:@"Searching for rides..."];
        
        [Event
         searchEventForSearchType:userType_driving
         withSource:_searchObject.sourcePlace
         destination:_searchObject.destinationPlace
         date:_searchObject.date
         sucess:^(NSArray *rides) {

             if ([rides count] == 0) {
                 [self handleNoResultsForSearch];
             }
             
             [self hideStatusMessage];
             _riderRides = rides;
             
             [self.tableView reloadData];
             [self doneLoadingTableViewData];
         } failure:^(NSError *error) {
             [self doneLoadingTableViewData];
             [self hideStatusMessage];
             [self displayFailureMessage:@"Searching for rides failed. Please try again."];
         }];

    }else {
        [self displayNoInternetMessage];
    }
}

- (void)handleNoResultsForSearch {
    NSString *overlayString = nil;
    if ([_riderRides count] == 0) {
        overlayString = @"No rides avialable :(";
        [self displayNoResultsLabelWithMessage:overlayString];
        
        goTogetherAppDelegate *appDelegate = (goTogetherAppDelegate *)
        [[UIApplication sharedApplication] delegate];
        
        GTRootViewController *rootViewController = appDelegate.rootViewController;
        [rootViewController showInviteAlertWithMessage:kInviteMessage_noresults];

    }else {
        [self removeNoResultsLabel];
    }
}

@end
