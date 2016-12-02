//
//  TAHomeScreenViewController.m
//  TravelApp
//
//  Created by shirish on 23/11/12.
//  Copyright (c) 2012 mutualmobile. All rights reserved.
//

#import "GTBrowseRidesViewController.h"
#import "goTogetherAppDelegate.h"
#import "GTRideDetailsParentViewController.h"
#import "Event.h"
#import "GTRideDetailCell.h"
#import "GTGoogleMapsRouteViewController.h"
#import "TALocationManager.h"
#import "TAFacebookManager.h"
#import "GTFriendsListViewController.h"
#import "GTInviteFriendsViewController.h"
#import <MessageUI/MessageUI.h>
#import "GTNotificationsViewController.h"

NSString *noRidesDisclaimerString = @"If you want to go fast, go alone. If you want to go far, gotogether - An African Proverb";

typedef enum {
    rides_browse,
    rides_friends,
    rides_nearby
}GTRidesMode;

#define kFriendFeedCellHeight 75.0f

@interface GTBrowseRidesViewController ()
<UITableViewDataSource,
UITableViewDelegate, MFMailComposeViewControllerDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) NSMutableArray *browseRides;
@property (strong, nonatomic) NSMutableArray *friendRides;
@property (strong, nonatomic) NSMutableArray *nearByRides;

@property (strong, nonatomic) Event *selectedEvent;

@property (strong, nonatomic) UIView *connectToFacebookView;
@property (readwrite, nonatomic) BOOL reloading;
@property (strong, nonatomic) GTNotificationsViewController *notificationsController;

@property (nonatomic, assign) BOOL isLoading;
@property (assign, nonatomic) BOOL hasNextPage;
@property (assign, nonatomic) int currentPage;
@property (assign, nonatomic) int totalPages;
@property (nonatomic, readwrite) float radius;

@property (nonatomic, assign) GTRidesMode mode;
@end

@implementation GTBrowseRidesViewController

- (void)awakeFromNib {
    [self initialiseData];
}

- (void)initialiseData {
    self.currentPage = 1;
    self.totalPages = 1;
    self.radius = kNearByRadius;
    self.mode = rides_browse;
    _browseRides = [[NSMutableArray alloc] init];
    _friendRides = [[NSMutableArray alloc] init];
    _nearByRides = [[NSMutableArray alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:kColorGlobalBackground];
    [self setupPullToRefresh];
    [self addNotificationHandlers];
    [self setupFilterButton];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self trackScreenName:@"Browse"];
}

- (void)addNotificationHandlers {
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(appOpenedNotificationHandler:)
     name:kNotificaionType_appOpened
     object:nil];

    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(eventUpdated:)
     name:kNotificaionType_eventUpdated
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(newRideCreated:)
     name:kNotificaionType_newEventCreated
     object:nil
     ];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(eventDeleted:)
     name:kNotificationType_eventDeleted
     object:nil
     ];

    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(userLoggedIn:)
     name:kNotificationType_loginSuccessful
     object:nil
     ];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(userLoggedOut:)
     name:kNotificaionType_loggedOut
     object:nil
     ];
}

- (void)userLoggedIn:(id)sender {
    [self refresh:nil];
}

- (void)userLoggedOut:(id)sender {
    [self initialiseData];
}

#pragma mark - Filter rides

- (void)setupFilterButton {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_filter"] style:UIBarButtonItemStylePlain target:self action:@selector(filterButtonTouched:)];
}

- (void)filterButtonTouched:(id)sender {
    UIActionSheet *optionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"All rides", @"Friend rides", @"Nearby rides", nil];
    [optionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    
    goTogetherAppDelegate *appDelegate = (goTogetherAppDelegate *)[[UIApplication sharedApplication] delegate];
    [optionSheet showInView:appDelegate.rootViewController.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {
        self.title = @"All Rides";
        _mode = rides_browse;
    }else if (buttonIndex == 1){
        self.title = @"Friend Rides";
        _mode = rides_friends;
    }else if (buttonIndex == 2){
        self.title = @"Nearby Rides";
        _mode = rides_nearby;
    }
    [self reloadRides];
}

#pragma mark - browse rides

- (void)loadBrowseRidesForPage:(NSInteger )pageNumber {
    goTogetherAppDelegate *appDelegate = (goTogetherAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.netStatus != kNotReachable) {
        
        [self displayActivityIndicatorViewWithMessage:@"Loading rides..."];
        
        [Event browseRidesForPage:pageNumber
                      WithSuccess:^(NSArray *rides, NSInteger totalPages) {
                          self.totalPages = totalPages;
                          self.isLoading = NO;
                          
                          if(rides.count == 0){
                              [self displayNoResultsLabelWithMessage:noRidesDisclaimerString];
                              
                              goTogetherAppDelegate *appDelegate = (goTogetherAppDelegate *)
                              [[UIApplication sharedApplication] delegate];
                              
                              GTRootViewController *rootViewController = appDelegate.rootViewController;
                              [rootViewController showInviteAlertWithMessage:kInviteMessage_noresults];
                              
                          }
                          else {
                              [self removeNoResultsLabel];
                          }
                          
                          [self replaceRides:rides forPageNumber:pageNumber];
                          [self.tableView reloadData];
                          [self doneLoadingTableViewData];
                          [self hideStatusMessage];
                          
                      } failure:^(NSError *error) {
                          self.isLoading = NO;
                          [self.tableView reloadData];
                          [self hideStatusMessage];
                          [self doneLoadingTableViewData];
                          [self displayFailureMessage:@"Loading rides failed. Please try again."];
                      }];
    }
    else {
        [self displayNoInternetMessage];
    }
}

- (void)replaceRides:(NSArray *)rides forPageNumber:(NSInteger)pageNumber {
    if ([_browseRides count] == 0) {
        [_browseRides addObjectsFromArray:rides];
    }else {
        for (int i = (pageNumber-1)*10 ; i < [rides count]; i ++) {
            [_browseRides replaceObjectAtIndex:i withObject:[rides objectAtIndex:i]];
        }
    }
}

#pragma mark - friend rides

- (void)loadFriendRides {
    User *currentUser = [User currentUser];
    if (currentUser.facebookId == nil){
        [self.tableView reloadData];
    }else {
        [self fetchFriendRides];
    }
}

- (void)fetchFriendRides {
    goTogetherAppDelegate *appDelegate = (goTogetherAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.netStatus != kNotReachable) {
        
        [self displayActivityIndicatorViewWithMessage:@"Loading your friends' rides..."];
        
        [Event fetchFriendFeed:^(NSArray *rides) {
            self.isLoading = NO;
            if(rides.count == 0){
                [self displayNoResultsLabelWithMessage:noRidesDisclaimerString];
            }
            else {
                [self removeNoResultsLabel];
            }
            [self.friendRides removeAllObjects];
            [self.friendRides addObjectsFromArray:rides];
            [self.tableView reloadData];
            [self doneLoadingTableViewData];
            [self hideStatusMessage];
 
        } failure:^(NSError *error) {
            self.isLoading = NO;
            [self.tableView reloadData];
            [self hideStatusMessage];
            [self doneLoadingTableViewData];
            [self displayFailureMessage:@"Loading rides failed. Please try again."];
        }];
    }
    else {
        [self displayNoInternetMessage];
    }
}

#pragma mark - near by rides

- (void)loadNearbyRides {

    if ([[TALocationManager sharedInstance] isLocationAccessGranted]){
        CLLocation *currentLocation = [[TALocationManager sharedInstance] currentLocation];
        if (_isLoading == NO && currentLocation!= nil) {
            [self fetchRidesAroundLocation:currentLocation.coordinate
                                withRadius:self.radius
             ];
        }
    }else{
        goTogetherAppDelegate *appDelegate = (goTogetherAppDelegate *)[[UIApplication sharedApplication] delegate];
        GTRootViewController *rootViewController = [appDelegate rootViewController];
        [rootViewController showLocationDisabledAlert];
        
        [self displayNoResultsLabelWithMessage:@"Location Services Disabled. Allow gotogether to access your location to show rides near you."];
    }
}

#pragma mark - Around Me API Call

- (void)fetchRidesAroundLocation:(CLLocationCoordinate2D)coordinate
                      withRadius:(float)radius{
    
    goTogetherAppDelegate *appDelegate = (goTogetherAppDelegate *)
    [[UIApplication sharedApplication] delegate];
    
    if (appDelegate.netStatus != kNotReachable) {
        
        
        TALocationManager *locationManager = [TALocationManager sharedInstance];
        CLLocation *currentLocation = locationManager.currentLocation;
        
        if (currentLocation!=nil && [User currentUser]!=nil) {
            _isLoading = YES;
            [self displayActivityIndicatorViewWithMessage:@"Loading rides near you..."];
            
            [Event
             aroundMeForLatitude:currentLocation.coordinate.latitude
             longitude:currentLocation.coordinate.longitude
             date:[NSDate date]
             radius:radius
             sucess:^(NSArray *rides) {
                 [self hideStatusMessage];
                 
                 [self.nearByRides removeAllObjects];
                 self.nearByRides = [rides copy];

                 if ([rides count] == 0) {
                     [self displayNoResultsLabelWithMessage:noRidesDisclaimerString];
                 }
                 _isLoading = NO;
                 [self.tableView reloadData];
             } failure:^(NSError *error) {
                 [self hideStatusMessage];
                 _isLoading = NO;
                 [self.tableView reloadData];
             }];
        }
    }
    else {
        [self displayNoInternetMessage];
    }
}

#pragma mark - PullToRefresh

- (void)refresh:(id)sender {
    if (_reloading == NO) {
        _reloading = YES;
        [self reloadRides];
    }
}

- (void)doneLoadingTableViewData {
    _reloading = NO;
    [self stopRefreshing];
}

- (void)reloadRides {
    if ([[User currentUser] isUserLoggedIn]) {
        if (self.mode == rides_browse) {
            [self resetBrowseRides];
            [self loadBrowseRidesForPage:_currentPage];
        }else if (self.mode == rides_friends) {
            [self loadFriendRides];
        }else {
            [self loadNearbyRides];
        }
        [self.tableView reloadData];
    }
}

- (void)resetBrowseRides {
    _currentPage = 1;
    _totalPages = 1;
    [_browseRides removeAllObjects];
}

#pragma mark - scroll delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_mode == rides_browse) {
        CGFloat yOffset = tableView.contentOffset.y;
        CGFloat height = tableView.contentSize.height - tableView.frame.size.height;
        CGFloat scrolledPercentage = yOffset / height;
        if (scrolledPercentage > .6f && !self.isLoading){
            [self loadNextPage:++self.currentPage];
        }
    }
}

- (void)loadNextPage:(int)pageNumber {
    if (self.isLoading) return;

    if (_currentPage <= _totalPages) {
        self.isLoading = YES;
        [self loadBrowseRidesForPage:_currentPage];
    }
}

#pragma mark -

- (NSArray *)visualRides {
    if (self.mode == rides_browse) {
        return self.browseRides;
    }else if (self.mode == rides_friends) {
        return self.friendRides;
    }else {
        return self.nearByRides;
    }
}

#pragma mark - TableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;{
    return [[self visualRides] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GTRideDetailCell *cell = nil;
    cell = [self.tableView
            dequeueReusableCellWithIdentifier:kCellIdentifier_friendFeed
                                forIndexPath:indexPath
            ];
    [cell setEvent:[[self visualRides] objectAtIndex:indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kFriendFeedCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Event *event = nil;
    event = [[self visualRides] objectAtIndex:indexPath.row];
    [self setSelectedEvent:event];
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:kStoryBoardIdentifier_rideDetails
                                                         bundle:nil];

    GTRideDetailsParentViewController *rideDetailsParentViewController = [storyBoard instantiateViewControllerWithIdentifier:@"controller_ridedetails_parent"];
    [rideDetailsParentViewController setEvent:self.selectedEvent];
    [self.navigationController pushViewController:rideDetailsParentViewController animated:YES];
}

#pragma mark - event updated handler

- (void)appOpenedNotificationHandler:(id)sender {
    // Reload only if this view is visible
    if ([User currentUser] != nil) {
        goTogetherAppDelegate *appDelegate =
        (goTogetherAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        GTRootViewController *rootViewController = (GTRootViewController *)appDelegate.rootViewController;
        
        if (rootViewController.selectedIndex == 0){
            if ([[rootViewController.viewControllers lastObject]
                 isKindOfClass:[UINavigationController class]]) {
                UINavigationController *browseNavController = [rootViewController.viewControllers lastObject];
                [browseNavController popToRootViewControllerAnimated:YES];
                [self refresh:nil];
            }
        }        
    }
}

- (void)eventDeleted:(id)sender{
    [self refresh:nil];
}

- (void)newRideCreated:(id)sender{
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
    for (int i = 0; i< [[self visualRides] count]; i++) {
        Event *obj = [[self visualRides] objectAtIndex:i];
        if ([updatedEvent.eventId isEqualToString:obj.eventId]) {
            index = i;
        }
    }
    
    if (index!=NSIntegerMax) {
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:[self visualRides]];
        [tempArray replaceObjectAtIndex:index withObject:updatedEvent];
        if (self.mode == rides_browse) {
            self.browseRides = tempArray;
        }else if(self.mode == rides_friends){
            self.friendRides = tempArray;
        }else {
            self.nearByRides = tempArray;
        }
    }
}

/*
#pragma mark - Notifications

- (void)setupNotificationsButton {
    UIBarButtonItem *notificationsButton =
    [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_notification"]
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(notificationsButtonTouched:)];
    self.navigationItem.rightBarButtonItem = notificationsButton;
}

- (void)notificationsButtonTouched:(id)sender {
    self.notificationsController = [self notificationsViewController];
    UINavigationController *notificationsNavController = [[UINavigationController alloc]
                                                          initWithRootViewController:_notificationsController];
    [self presentViewController:notificationsNavController
                       animated:YES
                     completion:nil];
}

- (GTNotificationsViewController *)notificationsViewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kStoryBoardIdentifier
                                                         bundle:[NSBundle mainBundle]];
    GTNotificationsViewController *notificationsController = [storyboard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_notifications];
    return notificationsController;
}

*/

/*
#pragma mark - Connect to Facebook methods

- (void)facebookButtonTapped:(id)sender {
    [self displayActivityIndicatorViewWithMessage:@"Connecting Facebook..."];
    [[TAFacebookManager sharedInstance] connectToFacebookWithHandleSuccess:^(id successMessage) {
        [self displaySucessMessage:@"Facebook connected!"];
    } andFailure:^(NSError *error) {
        [self displayFailureMessage:@"Failed to connect to Facebook"];
    }];
}

- (void)facebookConnected:(id)sender {
    NSNotification *notification = sender;
    if ([[notification name] isEqualToString:kNotificationType_facebookConnected])
    {
        NSDictionary* userInfo = [notification userInfo];
        TAFacebookUser *facebookUser= [userInfo objectForKey:kFacebookConnected_sendObject];
        TALog(@"Successfully received the test notification! %@", facebookUser);
        [[TAFacebookManager sharedInstance] updateUserOnGTServer:facebookUser];
        [[TAFacebookManager sharedInstance] updateFriendsOnGTServer];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(facebookDetailsUpdatedOnGT:)
         name:kNotificationType_facebookDetailsUpdatedOnGT
         object:nil];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(facebookFriendsUpdatedOnGT:)
         name:kNotificationType_facebookFriendsUpdatedOnGT
         object:nil];
    }
}

- (void)facebookDetailsUpdatedOnGT:(id)sender {
    [[NSNotificationCenter defaultCenter]
     removeObserver:self name:kNotificationType_facebookDetailsUpdatedOnGT object:nil];
    [self checkAndRemoveConnectToFacebookViewIfConnected];
}

- (void)facebookFriendsUpdatedOnGT:(id)sender {
    [[NSNotificationCenter defaultCenter]
     removeObserver:self name:kNotificationType_facebookFriendsUpdatedOnGT object:nil];
    
    [self loadRidesIfFacebookConnected];
}

- (void)loadRidesIfFacebookConnected {
    if ([[User currentUser] facebookId] != nil) {
        [self loadFriendRides];
    }
}

- (void)showConnectToFacebookView {
    self.connectToFacebookView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    [_connectToFacebookView setBackgroundColor:[UIColor clearColor]];
    
    UILabel *label = [self noResultsLabel];
    label.center = CGPointMake(_connectToFacebookView.center.x, _connectToFacebookView.center.y - 40.0);
    [label setText:kConnectToFacebookMessage];
    [_connectToFacebookView addSubview:label];
    
    UIButton *button = [UIButton facebookButton];
    button.center = CGPointMake(_connectToFacebookView.center.x, _connectToFacebookView.center.y + 40.0);
    [button setTitle:@"Connect to Facebook" forState:UIControlStateNormal];
    [button addTarget:self
               action:@selector(facebookButtonTapped:)
     forControlEvents:UIControlEventTouchUpInside];
    [_connectToFacebookView addSubview:button];
    
    [self.view addSubview:_connectToFacebookView];
    
    // Register for facebook connect notification
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(facebookConnected:)
     name:kNotificationType_facebookConnected
     object:nil];
    
}

- (void)removeConnectToFacebookView {
    if (self.connectToFacebookView != nil) {
        [self.connectToFacebookView removeFromSuperview];
        self.connectToFacebookView = nil;        
    }
}

- (void)checkAndRemoveConnectToFacebookViewIfConnected {
    User *currentUser = [User currentUser];
    if (currentUser.facebookId == nil){
        if (self.connectToFacebookView ==nil) {
            [self showConnectToFacebookView];
        }
    }else{
        [self loadFriendRides];
        if (self.connectToFacebookView != nil) {
            [self removeConnectToFacebookView];
        }
    }
}
*/


@end
