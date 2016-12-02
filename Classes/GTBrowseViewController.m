 //
//  TAHomeScreenViewController.m
//  TravelApp
//
//  Created by shirish on 23/11/12.
//  Copyright (c) 2012 mutualmobile. All rights reserved.
//

#import "GTBrowseViewController.h"
#import "goTogetherAppDelegate.h"
#import "GTRideDetailsViewController.h"
#import "Event.h"
#import "GTEventCell.h"
#import "GTGoogleMapsRouteViewController.h"
#import "TALocationManager.h"
#import "TAFacebookManager.h"
#import "GTHomeAndWorkPlaceViewController.h"
#import "TAGoogleAPIManager.h"
#import "GTAddViewController.h"
#import "GTSearchEntryViewController.h"

@interface GTBrowseViewController ()
<UITableViewDataSource,
UITableViewDelegate>

@property (strong, nonatomic) NSArray *ridesArray;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIView *connectToFacebookView;
@property (readwrite, nonatomic) BOOL reloading;
- (void)doneLoadingTableViewData;
@end

@implementation GTBrowseViewController

- (void)viewDidLoad{
    
    [super viewDidLoad];
    self.ridesArray = [NSMutableArray array];
    [self setupPullToRefresh];
    //[self homeWorkPlaceCheck];
    [self observeRelevantNotifications];
}

- (void)observeRelevantNotifications{
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
     selector:@selector(locationUpdated:)
     name:kNotificationType_locationUpdated
     object:nil
     ];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(addButtonTouched)
     name:kNotificationType_addTouched
     object:nil
     ];
}

- (BOOL)isalreadyLoggedIn{
    User *curentUser = [User currentUser];
    if (curentUser !=nil) {
        return YES;
    }else{
        return NO;
    }
}

- (void)locationUpdated:(id)sender{
    if ([self isalreadyLoggedIn]) {
        [self fetchRides];
    }
}
#pragma mark - fetch friend feed
- (void)fetchRides{
    
    goTogetherAppDelegate *appDelegate = (goTogetherAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.netStatus != kNotReachable) {
        
        [self displayActivityIndicatorViewWithMessage:@"Loading Rides..."];
        
        
        TALocationManager *locationManager = [TALocationManager sharedInstance];
        CLLocation *currentLocation = [locationManager currentLocation];
        
        
        
        TAGoogleAPIManager *googleApiManager = [TAGoogleAPIManager sharedInstance];
        [googleApiManager
         fetchLocationNameForLatitude:currentLocation.coordinate.latitude
         longitude:currentLocation.coordinate.longitude
         ifSucess:^(Place *place) {
             NSString *locality = place.subLocalityName;
             
             [Event
              browseRidesAtLocation:currentLocation
              locality:locality
              success:^(NSArray *rides) {
                  
                  if(rides.count == 0){
                      [self displayNoResultsLabelWithMessage:@"No Rides in your neighbourhood. Be the first person to add aride."];
                  }
                  else{
                      [self removeNoResultsLabel];
                      [self hideStatusMessage];
                  }
                  self.ridesArray = rides;
                  [self.tableView reloadData];
                  [self doneLoadingTableViewData];
                  [self hideStatusMessage];
                  
              } failure:^(NSError *error) {
                  [self hideStatusMessage];
                  [self doneLoadingTableViewData];
                  [self displayFailureMessage:@"Loading Rides failed. Pull to try again."];
              }];
             
             
         } ifFailure:^(NSError *error) {
             [self displayFailureMessage:@"Loading Rides failed. Pull to try again."];
         }];
        
    }
    else {
        [self displayNoInternetMessage];
    }
}

#pragma mark - PullToRefresh
- (void)refresh:(id)sender{
	_reloading = YES;
    [self fetchRides];
}

- (void)doneLoadingTableViewData{
    _reloading = NO;
    [self stopRefreshing];
}

#pragma Mark TableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    int count = [self.ridesArray count];
    return count;
}

- (void)configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath {
    
    Event *event = [self.ridesArray objectAtIndex:indexPath.row];
    [cell setEvent:event];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GTEventCell *cell = nil;
    cell = [self.tableView
                         dequeueReusableCellWithIdentifier:kCellIdentifier_friendFeed
                                            forIndexPath:indexPath
                            ];
    
    [cell setCellType:GTEventCellType_friendFeed];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 75.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Event *event = nil;
    event = [self.ridesArray objectAtIndex:indexPath.row];
    [self setEvent:event];
//    [self performSegueWithIdentifier:kSegueIdentifier_liveFeedToDetails sender:self];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
//    if ([segue.identifier isEqualToString:kSegueIdentifier_liveFeedToDetails]) {
//        
//        GTRideDetailsViewController *detailsViewController = (GTRideDetailsViewController *)segue.destinationViewController;
//        [detailsViewController setEvent:self.event];
//    }
}

#pragma mark - search delegate
- (void)addButtonTouched{
    UIStoryboard *storyboard =
    [UIStoryboard storyboardWithName:kStoryBoardIdentifier bundle:[NSBundle mainBundle]];
    
    GTAddViewController *addViewController = [storyboard instantiateViewControllerWithIdentifier:kNavControllerIdentifier_add];
    [self.navigationController presentViewController:addViewController animated:YES completion:nil];
}

#pragma mark - event updated handler

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
    for (int i = 0; i< [self.ridesArray count]; i++) {
        Event *obj = [self.ridesArray objectAtIndex:i];
        if ([updatedEvent.eventId isEqualToString:obj.eventId]) {
            index = i;
        }
    }
    
    if (index!=NSIntegerMax) {
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.ridesArray];
        [tempArray replaceObjectAtIndex:index withObject:updatedEvent];
        self.ridesArray = tempArray;
    }
}

#pragma mark - WorkHomePlacesCheck
- (void)homeWorkPlaceCheck{

    User *currentUser = [User currentUser];
    if ([currentUser isHomePlaceAvailable] == NO || [currentUser isWorkPlaceAvailable] == NO) {
        
        UIStoryboard *storyBoard  = [UIStoryboard storyboardWithName:kStoryBoardIdentifier
                                                              bundle:[NSBundle mainBundle]];
        
        GTHomeAndWorkPlaceViewController *workHomeController =
        [storyBoard instantiateViewControllerWithIdentifier:kNavControllerIdentifier_homeWorkPlace];
        [self.navigationController presentViewController:workHomeController
                                                animated:YES
                                              completion:nil];
        
    }
}



/*
 #pragma mark - Facebook methods
 - (void)loadRidesIfFacebookConnected{
 if ([User currentUser].facebookId !=nil) {
 [self fetchRides];
 }
 }
 - (void)handleButtons{
 if ([User currentUser].facebookId == nil) {
 [self showConnectToFacebookView];
 }
 }
 
 - (void)facebookButtonTapped:(id)sender{
 [[TAFacebookManager sharedInstance] connectToFacebook];
 }
 
 - (void)facebookConnected:(id)sender{
 
 NSNotification *notification = sender;
 if ([[notification name] isEqualToString:kNotificationType_facebookConnected])
 {
 NSDictionary* userInfo = [notification userInfo];
 TAFacebookUser *facebookUser= [userInfo objectForKey:kFacebookConnected_sendObject];
 NSLog (@"Successfully received the test notification! %@", facebookUser);
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
 
 - (void)facebookDetailsUpdatedOnGT:(id)sender{
 [[NSNotificationCenter defaultCenter]
 removeObserver:self name:kNotificationType_facebookDetailsUpdatedOnGT object:nil];
 [self checkAndRemoveConnectToFacebookViewIfConnected];
 }
 
 - (void)facebookFriendsUpdatedOnGT:(id)sender{
 [[NSNotificationCenter defaultCenter]
 removeObserver:self name:kNotificationType_facebookFriendsUpdatedOnGT object:nil];
 
 [self handleButtons];
 [self loadRidesIfFacebookConnected];
 }
 
 - (void)showConnectToFacebookView{
 
 self.connectToFacebookView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
 [_connectToFacebookView setBackgroundColor:[UIColor clearColor]];
 
 UILabel *label = [self noResultsLabel];
 label.center = CGPointMake(_connectToFacebookView.center.x, _connectToFacebookView.center.y - 40.0);
 [label setText:@"Connecting to Facebook lets you to see, your friends' rides."];
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
 - (void)removeConnectToFacebookView{
 [self.connectToFacebookView removeFromSuperview];
 self.connectToFacebookView = nil;
 }
 
 - (void)checkAndRemoveConnectToFacebookViewIfConnected{
 
 User *currentUser = [User currentUser];
 if (currentUser.facebookId == nil){
 if (self.connectToFacebookView ==nil) {
 [self showConnectToFacebookView];
 }
 }else{
 if (self.connectToFacebookView !=nil) {
 [self removeConnectToFacebookView];
 }
 }
 }
 */
@end
