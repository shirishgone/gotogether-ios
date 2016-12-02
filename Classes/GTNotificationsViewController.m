//
//  GTNotificationsViewController.m
//  goTogether
//
//  Created by shirish on 17/12/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import "GTNotificationsViewController.h"
#import "GTRideDetailsParentViewController.h"
#import "GTNotificationsManager.h"
#import "GTNotificationTableViewCell.h"

static const NSInteger kCellHeight_default = 60.0f;

@interface GTNotificationsViewController ()

@property (nonatomic, strong) NSArray *allNotifications;
@property (nonatomic, assign) BOOL reloading;
@end

@implementation GTNotificationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:kColorGlobalBackground];
    [self setupPullToRefresh];
    [self setupClearButton];
    [self setupCancelButton];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self trackScreenName:@"Notifications"];
    [self updateNotifications];
}

- (void)updateNotifications {
    self.allNotifications = [Notification allNotifications];
    if (self.allNotifications.count == 0) {
        [self displayNoResultsLabelWithMessage:@"No new notifications!"];
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }else {
        [self removeNoResultsLabel];
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    [self.tableView reloadData];
    [self doneLoadingTableViewData];
}

- (void)setupCancelButton {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonTouched:)];
}

- (void)cancelButtonTouched:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setupClearButton {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStylePlain target:self action:@selector(clearNotifications:)];
}

- (void)clearNotifications:(id)sender {
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Confirmation" andMessage:@"Do you want to clear all your notifications."];
    [alertView addButtonWithTitle:@"Clear" type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView *alertView) {
        [Notification clearAllNotifications];
        [self updateNotifications];
    }];
    [alertView addButtonWithTitle:@"Cancel" type:SIAlertViewButtonTypeCancel handler:nil];
    [alertView setTransitionStyle:SIAlertViewTransitionStyleDropDown];
    [alertView setBackgroundStyle:SIAlertViewBackgroundStyleSolid];
    [alertView show];
}

- (void)updateNotificationCounterOnTab {
    goTogetherAppDelegate *appDelegate = (goTogetherAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.rootViewController updateNotificationBadgeCount];
}

#pragma mark - PullToRefresh
- (void)refresh:(id)sender {
    if (_reloading == NO) {
        _reloading = YES;
        [self updateNotifications];
    }
}

- (void)doneLoadingTableViewData {
    _reloading = NO;
    [self stopRefreshing];
}

#pragma mark - table datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.allNotifications.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GTNotificationTableViewCell *cell = nil;
    Notification *notification = [self.allNotifications objectAtIndex:indexPath.row];
    NSString *cellIdentifier = kCellIdentifier_notification;
    cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier
                                                forIndexPath:indexPath
            ];
    
    cell.notification = notification;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    Notification *notification = [self.allNotifications objectAtIndex:indexPath.row];
    [notification setNotificationAsRead:YES];
    GTNotificationTableViewCell *cell = (GTNotificationTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell setReadMode:YES];
    Event *eventDetails = [Event eventForEventId:notification.eventId];
    [self pushToEventDetailsWithData:eventDetails];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kCellHeight_default;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

#pragma mark - push to event Details

- (void)pushToEventDetailsWithData:(Event *)eventDetails {
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:kStoryBoardIdentifier_rideDetails
                                                             bundle:[NSBundle mainBundle]];
    GTRideDetailsParentViewController *rideDetailsViewController =
    [mainStoryboard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_rideDetailsParent];
    [rideDetailsViewController setEvent:eventDetails];
    [self.navigationController pushViewController:rideDetailsViewController animated:YES];
}

@end
