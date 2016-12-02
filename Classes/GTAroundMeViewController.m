//
//  GTAroundMeAndSearchContainmentViewController.m
//  goTogether
//
//  Created by shirish on 18/06/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import "GTAroundMeViewController.h"
#import "goTogetherAppDelegate.h"
#import "GTRideDetailsViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "TALocationManager.h"
#import "GTSearchEntryViewController.h"
#import "GTMapAnnotationViewController.h"
#import "GTSearchResultsViewController.h"
#import "GTAnalyticsManager.h"
#import "GTNotificationsViewController.h"


@interface GTAroundMeViewController ()
<GMSMapViewDelegate>

@property (nonatomic, strong) IBOutlet GMSMapView *mapView;
@property (nonatomic, strong) IBOutlet UIView *locationServicesBanner;
// Data properties
@property (strong, nonatomic) Event *selectedRide;
@property (nonatomic) BOOL isLoading;

@property (nonatomic, strong) NSArray *aroundMeResults;
@property (nonatomic, readwrite) float radius;
@property (nonatomic, readwrite) float zoomLevel;

- (IBAction)notificationsButtonTouched;
- (IBAction)reloadAroundMeRides;
@end

@implementation GTAroundMeViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = YES;
    [self setupMap];
    [self setupNotificationHandlers];
    [self setTitleView];

    if ([User currentUser]!= nil){
        [self reloadAroundMeRides];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self trackScreenName:@"AroundMe"];
}

- (void)setTitleView{
    
    CGRect titleFrame = CGRectMake(0, 0, 200, 40);
    UIView *titleView = [[UIView alloc] initWithFrame:titleFrame];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setFont:kFont_alba_Regular_25];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setText:@"gotogether"];
    [titleView addSubview:titleLabel];
    
    self.navigationItem.titleView = titleView;
}

- (void)updateLocationServicesBanner{
    
    if([CLLocationManager locationServicesEnabled]) {
        CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
        if (authorizationStatus == kCLAuthorizationStatusAuthorized) {
            self.locationServicesBanner.hidden = YES;
        }else {
            self.locationServicesBanner.hidden = NO;
        }
    }else{
        self.locationServicesBanner.hidden = NO;
    }
}

#pragma mark - custom methods
- (IBAction)notificationsButtonTouched {
    GTNotificationsViewController *notificationsViewController = [[GTNotificationsViewController alloc] init];
    UINavigationController *notificationsNavController = [[UINavigationController alloc] initWithRootViewController:notificationsViewController];
    [self presentViewController:notificationsNavController animated:YES completion:nil];
}

- (IBAction)reloadAroundMeRides {
    CLLocation *currentLocation =
    [[TALocationManager sharedInstance] currentLocation];

    if (_isLoading == NO && currentLocation!= nil) {
        [self fetchRidesAroundLocation:currentLocation.coordinate
                            withRadius:self.radius
         ];
    }
}

- (void)reloadMarkers {
    [self clearMap];
    [self addMarkersOnMap:self.aroundMeResults];
}

- (void)setupNotificationHandlers {
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(eventUpdated:)
     name:kNotificaionType_eventUpdated
     object:nil];
    

    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(loggedInSuccessfully:)
     name:kNotificationType_loginSuccessful
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
     selector:@selector(newRideCreated:)
     name:kNotificaionType_newEventCreated
     object:nil
     ];
 
    [[NSNotificationCenter defaultCenter]
     addObserver: self
     selector: @selector(appDidBecomeActive:)
     name: UIApplicationDidBecomeActiveNotification
     object: nil
     ];
}

#pragma mark - Notification handlers

- (void)loggedInSuccessfully:(id)sender {
    [self setCameraToCurrentLocation];
    [self reloadAroundMeRides];
}

- (void)newRideCreated:(id)sender {
    [self reloadAroundMeRides];
}

- (void)locationUpdated:(id)sender {
    [self setCameraToCurrentLocation];
    if ([User currentUser]!=nil && self.aroundMeResults == nil) {
        [self reloadAroundMeRides];
    }
    [self updateLocationServicesBanner];
}

- (void)setCameraToCurrentLocation{
    CLLocation *currentLocation =
    [[TALocationManager sharedInstance] currentLocation];
    
    // Move camera towards the current location
    GMSCameraPosition *cameraPosition =
    [GMSCameraPosition cameraWithLatitude:currentLocation.coordinate.latitude
                                longitude:currentLocation.coordinate.longitude
                                     zoom:[[TALocationManager sharedInstance] defaultZoomLevel]];
    
    [_mapView setCamera:cameraPosition];
}

- (void)appDidBecomeActive:(id)sender {
    [self updateLocationServicesBanner];
}

#pragma mark - Map methods
- (void)setupMap{
    [_mapView setMyLocationEnabled:YES];
    [_mapView setDelegate:self];
    [_mapView.settings setMyLocationButton:YES];
    [_mapView setMapType:kGMSTypeNormal];
    
    self.zoomLevel = [[TALocationManager sharedInstance] defaultZoomLevel];
    self.radius = kNearByRadius;
}

- (void)clearMap{
    [_mapView clear];
}

- (void)addMarkersOnMap:(NSArray *)markers{
    for (Event *ride in markers) {
        [self addMarkerforRide:ride];
    }
    [TALocationManager fitBoundsForMarkersInMap:self.mapView];
}

- (void)addMarkerforRide:(Event *)ride{
    
    CLLocationCoordinate2D sourceCoordinate =
    CLLocationCoordinate2DMake(ride.sourceLatitudeValue,ride.sourceLongitudeValue);
    
    CLLocationCoordinate2D position = sourceCoordinate;
    GMSMarker *marker = [GMSMarker markerWithPosition:position];
    if (ride.userTypeValue == userType_driving) {
        marker.icon = [UIImage imageNamed:@"ico_mappin_car_gray"];
    }else{
        marker.icon = [UIImage imageNamed:@"ico_mappin_lyft_gray"];
    }
    marker.map = self.mapView;
    marker.userData = ride;
}

- (UIView *)mapView:(GMSMapView *)mapView
   markerInfoWindow:(GMSMarker *)marker{
    
    Event *rideInfo = marker.userData;
    TALog(@"ride Info: %@",rideInfo);

    GTMapAnnotationViewController *annotationController;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kStoryBoardIdentifier bundle:nil];
    annotationController = [storyboard instantiateViewControllerWithIdentifier:
                                 kViewControllerIdentifier_mapAnnotation];

    [annotationController setRideDetails:rideInfo];
    return annotationController.view;
}

- (void)mapView:(GMSMapView *)mapView
didTapInfoWindowOfMarker:(GMSMarker *)marker{
    
    if ([marker.userData isKindOfClass:[Event class]]) {
        Event *rideDetails = marker.userData;
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kStoryBoardIdentifier bundle:nil];
        
        GTRideDetailsViewController *rideDetailsViewController =
        [storyboard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_rideDetails];
        
        [rideDetailsViewController setEvent:rideDetails];
//        [rideDetailsViewController setRideDetailsVisibility:GTRideDetailsVisibility_searchEvent];
        [self.navigationController pushViewController:rideDetailsViewController animated:YES];
    }else{
        [self displayFailureMessage:@"Something went wrong :("];
    }
}

- (void)mapView:(GMSMapView *)mapView
didChangeCameraPosition:(GMSCameraPosition *)position{
    TALog(@"position: %@",position);
}

#pragma mark - action handlers
- (void)searchButtonTouched:(id)sender{
    [self performSegueWithIdentifier:kSegueIdentifier_searchToSearchEntry
                              sender:nil];
}

- (void)addButtonTouched:(id)sender{
    [self performSegueWithIdentifier:kSegueIdentifier_aroundMeToAdd
                              sender:nil];
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
            [self displayActivityIndicatorViewWithMessage:@"Looking for rides around you..."];

            [Event
             aroundMeForLatitude:currentLocation.coordinate.latitude
             longitude:currentLocation.coordinate.longitude
             date:[NSDate date]
             radius:radius
             sucess:^(NSArray *rides) {
                 [self hideStatusMessage];
                 [self clearMap];

                 if ([rides count] > 0) {
                     self.aroundMeResults = rides;
                     [self addMarkersOnMap:self.aroundMeResults];
                 }else{
                     [self displayFailureMessage:@"No Rides/Passengers around you!"];
                 }

                 _isLoading = NO;
             } failure:^(NSError *error) {
                 [self hideStatusMessage];
                 self.aroundMeResults = nil;
                 [self clearMap];
                 
                 _isLoading = NO;
             }];
        }
    }
    else {
        [self displayNoInternetMessage];
    }
}

- (void)setAroundMeResults:(NSArray *)aroundMeResults{
    _aroundMeResults = [Event sortEventsByLocation:aroundMeResults];
}

#pragma mark - event updated handler
- (void)eventUpdated:(id)sender{
    
    NSNotification *notification = sender;
    if ([[notification name] isEqualToString:kNotificaionType_eventUpdated])
    {
        NSDictionary* userInfo = [notification userInfo];
        Event *event= [userInfo objectForKey:kNotificaionObject_updatedEvent];
        self.aroundMeResults = [self replaceUpdatedEventInMyRides:event inArray:self.aroundMeResults];
        [self reloadMarkers];
    }
}

- (NSArray *)replaceUpdatedEventInMyRides:(Event *)updatedEvent inArray:(NSArray *)array{
    
    NSInteger index = NSIntegerMax;
    for (int i = 0; i< [array count]; i++) {
        Event *obj = [array objectAtIndex:i];
        if ([updatedEvent.eventId isEqualToString:obj.eventId]) {
            index = i;
        }
    }
    
    if (index != NSIntegerMax) {
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:array];
        [tempArray replaceObjectAtIndex:index withObject:updatedEvent];
        array = tempArray;
    }
    return array;
}

@end
