//
//  GTSearchMapViewController.m
//  goTogether
//
//  Created by shirish on 19/06/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "GTSearchMapViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "goTogetherAppDelegate.h"
#import "GTSearchGooglePlaceController.h"
#import "TALocationManager.h"
#import "TAGoogleAPIManager.h"
#import "GTMapAnnotationView.h"
#import "GTMapAnnotationViewController.h"
#import "GTRideDetailsViewController.h"
#import "PopoverView.h"
#import "GTSearchEntryViewController.h"
#import "GTFlurryConstants.h"
#import "GTFlurryManager.h"
#import "GTSearchResultsViewController.h"
#import "GTAroundMeAndSearchContainmentViewController.h"

@interface GTSearchMapViewController ()
<GMSMapViewDelegate,
GTSearchEntryViewController_delegate,
GTMapAnnotationViewController_delegate>

@property (nonatomic, strong) IBOutlet GMSMapView *mapView;
@property (nonatomic, strong) IBOutlet UIView *filterView;
@property (nonatomic, weak) IBOutlet UIButton *listButton;
@property (nonatomic, weak) IBOutlet UILabel *sourceLocationLabel;
@property (nonatomic, weak) IBOutlet UILabel *destinationLocationLabel;

// Data properties
@property (nonatomic, strong) GTSearchObject *searchObject;
@property (nonatomic, strong) NSArray *searchResults;
@end

@implementation GTSearchMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self setupMap];
    [self setupFilterView];
    [self.listButton setHidden:YES];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(locationUpdated:)
     name:kNotificationType_locationUpdated
     object:nil
     ];
}

#pragma mark - setup methods
- (void)setupFilterView{
    [self loadFilterViewWithSearchObject:self.searchObject];

    // Drawing border for the view
    self.filterView.layer.cornerRadius = 3.0;
    self.filterView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.filterView.layer.borderWidth = 0.75;
    
    // Adding drop shadow for the layer.
    [self.filterView.layer setShadowColor:[[UIColor grayColor] CGColor]];
    [self.filterView.layer setShadowOffset:CGSizeMake(0, 1)];
    [self.filterView.layer setShadowOpacity:1];
    [self.filterView.layer setShadowRadius:1.0];

    // setup action on touch
    UITapGestureRecognizer *tapGestureRecogniser =
    [[UITapGestureRecognizer alloc]
     initWithTarget:self
     action:@selector(filterViewTouched:)];
    [self.filterView addGestureRecognizer:tapGestureRecogniser];
}

- (void)loadFilterViewWithSearchObject:(GTSearchObject *)searchObject{
    if (searchObject!=nil) {
        [_sourceLocationLabel setText:searchObject.sourcePlace.placeName];
        [_destinationLocationLabel setText:searchObject.destinationPlace.placeName];
    }
}

- (void)setupMap{
   
    [_mapView setMyLocationEnabled:YES];
    [_mapView setDelegate:self];
    [_mapView.settings setMyLocationButton:YES];
    [_mapView setMapType:kGMSTypeNormal];
}

#pragma mark - location updates
- (void)locationUpdated:(id)sender{
    CLLocation *currentLocation =
    [[TALocationManager sharedInstance] currentLocation];
        
    // Move camera towards the current location
    GMSCameraPosition *cameraPosition =
    [GMSCameraPosition cameraWithLatitude:currentLocation.coordinate.latitude
                                longitude:currentLocation.coordinate.longitude
                                     zoom:[[TALocationManager sharedInstance] defaultZoomLevel]];
    
    [_mapView setCamera:cameraPosition];
}

#pragma mark - map related methods
- (void)loadRidesOnMap{
    for (Event *ride in self.searchResults) {
        [self addMarkerforRide:ride];
    }
    if ([self.searchResults count] > 0) {
        [self.listButton setHidden:NO];
    }else{
        [self.listButton setHidden:YES];
        [self displayFailureMessage:@"No results!"];
    }
}

- (void)addMarkerforRide:(Event *)ride{
    
    CLLocationCoordinate2D sourceCoordinate =
    CLLocationCoordinate2DMake(ride.sourceLatitudeValue,ride.sourceLongitudeValue);
    
    CLLocationCoordinate2D position = sourceCoordinate;
    GMSMarker *marker = [GMSMarker markerWithPosition:position];
    marker.title = @"London";
    if (ride.userTypeValue == userType_driving ) {
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
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kStoryBoardIdentifier bundle:nil];
	GTMapAnnotationViewController *mapAnnotationViewController =
    [storyboard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_mapAnnotation];
    [mapAnnotationViewController setDelegate:self];
    [mapAnnotationViewController setRideDetails:rideInfo];
    return mapAnnotationViewController.view;
}

- (void)mapView:(GMSMapView *)mapView
didTapInfoWindowOfMarker:(GMSMarker *)marker{
    
    if ([marker.userData isKindOfClass:[Event class]]) {
        Event *rideDetails = marker.userData;
        
        TALog(@"ride details: %@",marker.userData);
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kStoryBoardIdentifier bundle:nil];
        GTRideDetailsViewController *rideDetailsViewController =
        [storyboard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_rideDetails];
        [rideDetailsViewController setEvent:rideDetails];
        [rideDetailsViewController setRideDetailsVisibility:GTRideDetailsVisibility_searchEvent];
        [self.navigationController pushViewController:rideDetailsViewController animated:YES];
    }else{
        [self displayFailureMessage:@"Something went wrong with the marker"];
    }
}

#pragma mark - action handlers
- (void)filterViewTouched:(id)sender{
    [self performSegueWithIdentifier:kSegueIdentifier_searchMapToSearchEntry sender:nil];
}

- (IBAction)listViewButtonTouched:(id)sender{
    [self performSegueWithIdentifier:kSegueIdentifier_searchMapToSearchList sender:nil];
}

#pragma mark - search api call
- (void)searchEvents{
    
    [self logToFlurry:_searchObject];
    
    goTogetherAppDelegate *appDelegate = (goTogetherAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.netStatus != kNotReachable) {
        
        [self displayActivityIndicatorViewWithMessage:@"Searching for Rides..."];
        [Event
         searchEventForSearchType:_searchObject.userType
         withSource:_searchObject.sourcePlace
         destination:_searchObject.destinationPlace
         date:_searchObject.date
         sucess:^(NSArray *rides) {
             [self hideStatusMessage];
             self.searchResults = rides;
             [self loadRidesOnMap];
             
         } failure:^(NSError *error) {
             [self displayFailureMessage:@"Search Failed. Please try again!"];
         }];
    }
    else {
        [self displayNoInternetMessage];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:kSegueIdentifier_searchMapToSearchEntry]) {
        UINavigationController *searchEntryNavController =
        (UINavigationController *)segue.destinationViewController;
        GTSearchEntryViewController *searchEntryController = [searchEntryNavController.viewControllers objectAtIndex:0];
        searchEntryController.delegate = self;
    }else if ([segue.identifier isEqualToString:kSegueIdentifier_searchMapToSearchList]){
        GTSearchResultsViewController *searchResultsListViewController =
        (GTSearchResultsViewController *)segue.destinationViewController;
        [searchResultsListViewController setSearchResults:self.searchResults];
    }
}
#pragma mark - search filter delegate
- (void)searchRidesWithSearchObject:(GTSearchObject *)searchObject{
    if(searchObject !=nil){
        self.searchObject = searchObject;
        [self loadFilterViewWithSearchObject:self.searchObject];
        [self searchEvents];
    }
}

#pragma mark - annotation delegate
- (void)annotationSelectedForRideDetails:(Event *)rideDetails{
    if ([self.parentViewController isKindOfClass:[GTAroundMeAndSearchContainmentViewController class]]) {
        GTAroundMeAndSearchContainmentViewController *containerViewController =
        (GTAroundMeAndSearchContainmentViewController *)self.parentViewController;
        [containerViewController pushToRideDetailsControllerWithRideDetails:rideDetails];
    }
}

#pragma mark - Flurry
- (void)logToFlurry:(GTSearchObject *)searchObject{
    
    GTRequestType requestType;
    if(searchObject.userType == userType_passenger){
        requestType = GTRequestTypeAsk;
    }else{
        requestType = GTRequestTypeOffer;
    }
    [[GTFlurryManager sharedInstance] logSearchRideforRideType:requestType];
}
@end
